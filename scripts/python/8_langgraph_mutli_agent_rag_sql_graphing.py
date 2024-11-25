# -*- coding: utf-8 -*-
"""3_mutli_agent_rag_sql_GRAPHING.ipynb


# 1. Install and Import Libraries
"""

# Commented out IPython magic to ensure Python compatibility.
# %%capture --no-stderr
# ! pip install -U \
#     langchain_community tiktoken langchain-openai\
#         langchainhub chromadb langchain langgraph\
#         tavily-python pypdf pinecone-notebooks \
#         langchain-pinecone gradio langchain-experimental\
#         pandas matplotlib
#

import getpass
import os

# OpenAI
os.environ["OPENAI_API_KEY"] = YOUR KEY HERE

# Langchain
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = YOUR KEY HERE

# Wolfram
os.environ["WOLFRAM_ALPHA_APPID"] = YOUR KEY HERE

# define eBird API Key
api_key = "bc72m2723il0"

# define Tavily Key
tavily_key = YOUR KEY HERE
if not os.environ.get("TAVILY_API_KEY"):
    os.environ["TAVILY_API_KEY"] = getpass.getpass("Tavily API key:\n")

import os
from dotenv import load_dotenv, find_dotenv

"""# 2. Set up PDF and URL Index"""

# setup the pinecone api key
os.environ["PINECONE_API_KEY"] = YOUR KEY HERE
pinecone_api_key = os.environ.get("PINECONE_API_KEY")

import time

 from pinecone import Pinecone, ServerlessSpec
 pc = Pinecone(api_key=pinecone_api_key)

 index_name = "self-reflective-rag-birds"

 existing_indexes = [index_info["name"] for index_info in pc.list_indexes()]

 if index_name not in existing_indexes:
     pc.create_index(
         name=index_name,
         dimension=1536,
         metric="cosine",
         spec=ServerlessSpec(cloud="aws", region="us-east-1"),
     )
     while not pc.describe_index(index_name).status["ready"]:
         print("sleeping")
         time.sleep(1)

 index = pc.Index(index_name)

"""Create a multi source index"""

### Build Index

from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.document_loaders import WebBaseLoader
from langchain_openai import OpenAIEmbeddings
from langchain.document_loaders import PyPDFLoader
from langchain_pinecone import PineconeVectorStore


# Set embeddings
embd = OpenAIEmbeddings()

# Docs to index

# urls to index - can be added to in later iterations
urls = [
    "https://norfolknaturalists.org.uk/wp/publications/bird-and-mammal-report/",
    "https://norfolknaturalists.org.uk/wp/home/about-the-society/",
    "https://norfolknaturalists.org.uk/wp/recording/"
]

# pdf to index - historic birds 1955
pdf_loader = PyPDFLoader("YOUR PATH HERE/historic_birds_merged.pdf")

# Load
docs = [WebBaseLoader(url).load() for url in urls]
pdf_pages = pdf_loader.load()

docs_list = [item for sublist in docs for item in sublist] + pdf_pages



# split up pdf doc into digestable chunks
text_splitter = RecursiveCharacterTextSplitter.from_tiktoken_encoder(
    chunk_size=500,
    chunk_overlap=20,
    separators=["\n\n", "\n", "(?<=\. )", " ", ""]
)
doc_splits = text_splitter.split_documents(docs_list)

# Add to vectorstore
index_name = "self-reflective-rag-birds"
vectorstore = PineconeVectorStore.from_documents(
    documents=doc_splits,
    embedding=embd,
    index_name=index_name
)

# Setup Pinecone as the retriever
retriever = vectorstore.as_retriever(search_kwargs={"k": 3})

# Test the retriever
retriever.invoke("Describe a bird seen in 1985?")

"""# 3. Set up SQL and Python Agents"""

import pandas as pd

# Load data
df = pd.read_csv("YOUR PATH HERE/norfolk_habitat.csv")

# Drop irrelevant columns
columns_to_remove = ["GLOBAL UNIQUE IDENTIFIER", "LAST EDITED DATE", "COUNTRY CODE", "COUNTY CODE", "USFWS CODE",
                     "ATLAS BLOCK", "LOCALITY ID", "PROJECT CODE", "HAS MEDIA"]
df_cleaned = df.drop(columns=columns_to_remove)

# Save to SQL database
from langchain_community.utilities import SQLDatabase
from sqlalchemy import create_engine

engine = create_engine("sqlite:///norfolk_sample.db")
df_cleaned.to_sql("norfolk_sample", engine, index=False)
db = SQLDatabase(engine=engine)
print(db.dialect)
print(db.get_usable_table_names())
db.run("SELECT * FROM norfolk_sample WHERE APPROVED = 1;")

"""Make the SQL agent"""

from langchain_community.utilities import SQLDatabase
from langchain_community.agent_toolkits import create_sql_agent
from langchain_openai import ChatOpenAI
from langchain.prompts import PromptTemplate
from langchain_core.messages import SystemMessage


# set up prompt
SQL_PREFIX = """You are an expert SQL agent adept at summarising and calculating matrix data.
        The sql_database contains data related to bird sightings collected by users in Norfolk.
         Use the SQL database for questions asking for calculations or quantitative summaries based on these topics.

          Here is the metadata for the columns in the SQL database:
          GLOBAL UNIQUE IDENTIFIER = A unique alphanumeric code assigned to each observation (of a single taxon within a single checklist) that stays with it through database revisions, updates, and edits. ,
          LAST EDITED DATE = The date and time of the most recent edit to any observation on the checklist (see SAMPLING EVENT IDENTIFIER below); this is useful for determining whether an observation should be updated if a copy of these data is being stored locally. Edits include changes to any of the following: Location: e.g., latitude, longitude, location name, county, state, or country. Submission: e.g., date, effort, complete checklist. Observation: e.g., species, count, review status, exotic code, or other edits made by user or editor.,
          TAXONOMIC ORDER = The numeric value assigned to this taxon in the eBird/Clements taxonomy to arrange the species in the latest taxonomic sequence.,
          CATEGORY = The category (e.g., species, hybrid, slash) assigned to this taxon in the eBird/Clements taxonomy.,
          TAXON CONCEPT ID = Unique taxonomic identifier meant to identify a specific taxonomic concept. The same English or scientific name may be applied to different populations over time, even across versions within a single taxonomy. A Taxon Concept ID refers to a population with shared characteristics and a specific range circumscription and not to the treatment of these populations within a specific taxonomy. For example, when well defined subspecies or subspecies groups are elevated to species level (i.e., a split), the Taxon Concept ID will not change even though the common and scientific names will change. A change to the genus or the spelling of a scientific name will not result in a change to the Taxonomic Concept ID. Taxon Concept IDs are the best way to track taxonomic changes through time or across datasets; note that the TAXON CONCEPT ID applies to the most specific identification offered, so if the SUBSPECIES COMMON NAME and SUBSPECIES SCIENTIFIC NAME fields are populated, the TAXON CONCEPT ID applies to those taxa; if not, TAXON CONCEPT ID applies to the COMMON NAME and SCIENTIFIC NAME fields. We use the Taxon Concept IDs developed and maintained by Avibase (https://avibase.bsc-eoc.org/) which also maintains linkages
          between taxonomic authorities and versions through time. Example: In 2021, eBird lumped Northwestern Crow (Corvus caurinus) with American Crow (Corvus brachyrhynchos), resulting in no name change for American Crow but a substantial change in the range of American Crow, since populations in coastal British Columbia and Alaska are now included in American Crow (Corvus brachrhynchos). Consequently, this split results in 1) deletion of Northwestern Crow (Corvus caurinus) from the dataset; 2) conversion of all those former Northwestern Crow records to American Crow (Corvus brachyrhynchos); 3) change in the TAXON CONCEPT ID for American Crow (Corvus brachyrhynchos) from avibase-9E9F2476 to avibase-69544B59. Thus, the TAXON CONCEPT ID helps to track taxonomic changes, including those where the name might not change, such as American Crow (Corvus brachyrhynchos).,
          COMMON NAME = The primary English common name of the bird species taxon in the eBird/Clements taxonomy.,
          SCIENTIFIC NAME = The scientific (or latin) name of the taxon in the eBird/Clements taxonomy.,
          SUBSPECIES SCIENTIFIC NAME = The scientific name of the subspecies or subspecies group in the eBird/Clements taxonomy. Certain other taxa (such as intergrades, and certain forms and domestics) also included here.,
          EXOTIC CODE = Exotic Codes are applied to eBird Observations (i.e., any unique GLOBAL UNIQUE IDENTIFIER) when the species is believed to be exotic (i.e., non-native); observations of taxa native to the region will have a null value in this field. The three Exotic Codes are: N (Naturalized), P (Provisional), and X (Escapee). Exotic Codes are
          defined by eBird and applied as part of the eBird Review Process by eBird reviewers, using both an automated and manual process. The full definitions of these Exotic Codes are as follows: • N (Naturalized): Exotic population is self-sustaining, breeding in the wild,
          persisting for many years, and not maintained through ongoing releases (including vagrants from naturalized populations). These count in official eBird totals and, where applicable, have been accepted by regional bird records committee(s).• P (Provisional): Either: 1) member of exotic population that is breeding in the wild, self-propagating, and has persisted for multiple years, but not yet Naturalized; 2) rarity of uncertain provenance, with natural vagrancy or captive
          provenance both considered plausible. When applicable, eBird generally defers to bird records committees for records formally considered to be of uncertain provenance. Provisional species count in official eBird totals. • X (Escapee): Exotic species known or suspected to be escaped or released,including those that have bred but don’t yet fulfill the criteria for Provisional.Escapee exotics do not count in official eBird totals.,
          OBSERVATION COUNT = The count of individuals of a given taxon/bird type (each with unique values for TAXON CONCEPT ID, COMMON NAME, and SCIENTIFIC NAME) made at the time of observation. If no count was made, an 'X' is used to indicate presence.,
          BREEDING CODE = The highest-level breeding information reported for the species on a given checklist. The Breeding Code will reflect the value entered by a user except in cases where reviewers of atlas data have deemed it a likely typo or other error; in those cases, the original Breeding Code will appear on the public eBird checklist, but the corrected code is provided in the data here. NY--Nest with Young – Nest with young seen or heard. Typically considered Confirmed.
          NE--Nest with Eggs – Nest with eggs. Typically considered Confirmed. FS--Carrying Fecal Sac – Adult carrying fecal sac. Typically considered Confirmed. FY--Feeding Young – Adult feeding young that have left the nest, but are not yet flying and independent (should not be used with raptors, terns, and other species that may move many miles from the nest site). Typically considered Confirmed. CF--Carrying Food – Adult carrying food for young (should not be used for corvids, raptors, terns, and certain other species that regularly carry food for courtship or other purposes). Typically considered Confirmed. FL--Recently Fledged young – Recently fledged or downy young observed while still dependent upon adults. Typically considered Confirmed. ON--Occupied Nest – Occupied nest presumed by parent entering and remaining, exchanging incubation duties, etc. Typically considered Confirmed. UN--Used nest – Unoccupied nest, typically with young already fledged and no longer active, observed and conclusively identified as belonging to the entered species; note that this breeding code may accompany a count of 0 if no live birds were seen/heard on the checklist. Typically considered Confirmed. DD--Distraction Display – Distraction display, including feigning injury. Typically considered Confirmed. NB--Nest Building – Nest building at apparent nest site (should not be used for certain wrens, and other species that build dummy nests). Typically considered Confirmed, sometimes Probable. CN--Carrying Nesting Material – Adult carrying nesting material; nest site not seen. Typically considered Confirmed, sometimes Probable. PE--Brood Patch and Physiological Evidence – Physiological evidence of nesting, usually a brood patch. This will be used only very rarely. Typically considered Confirmed. B--Woodpecker/Wren nest building – Nest building at apparent nest site observed in Woodpeckers (Family: Picidae) or Wrens (Family: Troglodytidae)—both species known to built dummy nests or roost cavities. Typically considered Probable. T--Territory held for 7+ days – Territorial behavior or singing male present at the same location 7+ days apart. Typically considered Probable. A--Agitated behavior – Agitated behavior or anxiety calls from an adult (ex. Pishing and strong tape responses). Typically considered Probable. N--Visiting probable Nest site – Visiting repeatedly probable nest site (primarily hole nesters). Typically considered Probable. C--Courtship, Display or Copulation – Courtship or copulation observed, including displays and courtship feeding. Typically considered Probable. T--Territory held for 7+ days – Territorial behavior or singing male present at the same location 7+ days apart. Typically considered Probable. P--Pair in suitable habitat – Pair observed in suitable breeding habitat within breeding season. Typically considered Probable. M--Multiple (7+) singing males. Count of seven or more signing males observed in a given area. Typically considered probable. S7--Singing male present 7+ days – Singing male, presumably the same individual, present in suitable nesting habitat during its breeding season and holding territory in the same area on visits at least 7 days apart. Typically considered probable. S--Singing male – Singing male present in suitable nesting habitat during its breeding season. Typically considered Possible. H--In appropriate habitat – Adult in suitable nesting habitat during its breeding season. Typically considered Possible. F--Flyover – Flying over only. This is not necessarily a breeding code, but can be a useful behavioral distinction.,
          BREEDING CATEGORY = Four categories used to describe a species' breeding status based on the 'BREEDING CODE' reported on the eBird checklist: C1 – Observed; C2 – Possible; C3 – Probable; C4 – Confirmed. In most cases, these are the default values corresponding with the breeding code reported by the observer. But in some cases reviewers of atlas data may reinterpret a breeding category, and that reinterpretation is reported here. For instance, a tern species might be seen carrying food (typically C4 – Confirmed), but since terns feed young away from the nesting area it would be reinterpreted as a lower breeding category.,
          BEHAVIOR CODE = The highest level behavior reported for the species on a given checklist. In most cases, this will match the BREEDING CODE, but it will differ when reviewers of atlas data have revised the data so that the reported code reflects a behavior code, with a lower code applied as the breeding code (e.g., a migrant songbird singing on migration in places where it doesn’t breed: would have S for BEHAVIOR
          CODE, but no BREEDING CODE). Note that atlas reviewers may also correct codes that are considered erroneous; in these cases this will show as a correction on the public eBirdchecklist but it is not captured.,
          AGE/SEX = The reported number of each age and sex combination for a species on a given checklist. Age categories are: adult, immature, and juvenile. Sex: male, female, and unknown.,
          COUNTRY = The country where the observation was made.,
          COUNTRY CODE = Abbreviation for country name.,
          IBA CODE = The alphanumeric code for an Important Bird Area. If an observation falls within an IBA, it is given this code.,
          BCR CODE = The alphanumeric code for a Bird Conservation Region.If an observation falls within a particular BCR, it is given this code.,
          USFWS CODE = The alphanumeric code for a United States Fish and Wildlife Service land holding. If an observation falls within a particular USFWS polygon, it is given this code.,
          ATLAS BLOCK = Sampling units called blocks have been established for specific atlas projects run within eBird. Blocks are established using a grid system (for example, in the United States these are based on 7.5-minute topographic quadrangle maps (quads) prepared by the U.S. Geological Survey). Each quad has a unique identifier. For atlasing purposes, each quad is divided into 6 blocks, each roughly 3 x 3 miles and encompassing about 23 sq km (9 sq mi). Each block has been coded with a 2-letter code: either northwest (NW), northeast (NE), center-west (CW), center-east (CE), southwest (SW), or southeast (SE). ATLAS BLOCK is only assigned to a record when an eBird Atlas PROJECT CODE (see below) is selected by the observer.,
          LOCALITY = The reported location name for the observation. Observers can give locations their own names, or choose from existing locations,
          LOCALITY ID = Unique alphanumeric code for a location.,
          LOCALITY TYPE = In some cases location names can be confusing. This code is meant to help define the type of location used, as participants in eBird can plot specific locations on a map (P), choose existing locations from a map (H), or choose to submit data for a town (T), postal code (PC), county (C), or state (S). Abbreviations: State (S), County (C), Postal/Zip Code (PC), Town (T), Hotspot (H), Personal (P).,
          LATITUDE = Latitude of the observation in decimal degrees.,
          LONGITUDE = Longitude of the observation in decimal degrees.,
          OBSERVER ID = Unique number associated with each eBird observer.,
          SAMPLING EVENT IDENTIFIER = The unique number associated with the sampling event/survey (eBird checklist). Each sampling event has a unique combination of location, date, observer, and start time. For a sampling event to exist in the EBD it must can contain observations of one or more taxa, all of which share this unique identifier.,
          PROTOCOL TYPE = The type of survey associated with this sampling event. The three main protocol types are:• Traveling Count• Stationary Count• Casual Observation/Incidental Observation,
          PROTOCOL CODE = This short alphanumeric code is used to identify the type of protocol. Each code is unique and used internally to identify the protocol. Each Protocol Code is tied to a unique Protocol Type.,
          PROJECT CODE = While all the data in this dataset come from eBird, this field is used to designate which portal the data came through. Portals can be regional (e.g., eBird Chile or aVerAves) or project-based (e.g., Wisconsin Breeding Bird Atlas, Bird Conservation Network eBird).,
          EFFORT DISTANCE KM = The distance traveled during the sampling event reported in kilometers.,
          EFFORT AREA HA = The area covered during the sampling event reported in hectares.,
          NUMBER OBSERVERS = The total number of observers participating the sampling event.,
          ALL SPECIES REPORTED = A critical field that separates eBird checklist data from most other observational datasets. Observers answer yes to this question when they are reporting all species detected by sight and by ear to the best of their ability on a given checklist (sampling event). Observers answer no to this question when they are only reporting a selection of species from an outing, usually the highlights or unusual birds. When observers report all species it allows one also to infer which species were not detected. Given sufficiently large samples of records with ALL SPECIES REPORTED in a
          region, it is possible to estimate the probability that a nondetection represents the true absence of a species. (1 = yes; 0 = no).,
          GROUP IDENTIFIER = When multiple observers participate in the same sampling event, they can share checklists. If a checklist is shared between multiple observers (i.e., multiple copies of the original checklist are created from the original checklist, with one copy for each observer with whom the original checklist is shared), this group of duplicate checklists is given a GROUP ID number. These checklists can be edited by each observer so may or may not be exact copies in terms of the taxa involved, counts, comments, or even effort. Use this number to eliminate duplicate data when multiple observers are sharing data.,
          HAS MEDIA = Indicates whether a particular observation of a taxon is supported by rich media stored at the Cornell Lab of Ornithology Macaulay Library,
          APPROVED = The status of the record within the eBird data quality process. If Accepted, the record is deemed acceptable.,
          REVIEWED = Not Reviewed means that the record passed through our automated filters without problems, that the species, date, and count were within expected levels, and that the record has otherwise not been reviewed by a reviewer. Reviewed means that the record triggered a higher-level review process, either through an automated or manual process, and that it was vetted by one of our regional editors. (1 = yes; 0 = no).",
          REASON = The reason the record was Not Confirmed. In this dataset, the only value that may appear is Species-Introduced/Exotic,
          TRIP COMMENTS = General comments about the sampling event (checklist) provided by the observer. Often includes information about the weather.,
          SPECIES COMMENTS = Comments about this particular species observation provided by the observer. Often includes elaboration about behaviour.
          HabitatRange = These are the habitat types where a particular species have been observed on a global scale. These can be interpreted as their standard habitats.
          Seasons = Indicates whether a particular observation uses the HabitatRange for breeding, non-breeding, or is a resident.
          ActualHabitat = This is the exact habitat type where the observation was observed. This is more precise than HabitatRange, though they will often be similar.

         In the data provided, there are three columns relevant to time,

         TIME OBSERVATIONS STARTED: This column indicates the time at which a survey began, represented in 24-hour clock format. For example, if the value is "14:40:00", it means the survey started at 2:40 PM.
         DURATION MINUTES: This column specifies the duration of the survey in minutes. For instance, if the value is "10", and the corresponding "TIME OBSERVATIONS STARTED" is "14:40:00", then the survey ended at "14:50:00".
         OBSERVATION DATE: This column represents the date of the observation in "DD/MM/YYYY" format. For example, "19/03/2022" denotes the 19th of March, 2022.
         When answering questions related to time or date from the data, please consider these columns for accurate interpretation and calculation of time intervals.

         In the data provided, there is a column named ActualHabitat. This refers to the actual IUCN habitat classification of the locality of the observation. The HabitatRange column instead refers to the habitats where the bird species could be observed, but not necessarily where they were observed for any given observation.

         In the data provided, there is a column named LOCALITY which contains information about the locality of the observation. It's important to note that sometimes the exact wording for a locality may not be present in the column, but a variation or a substring might exist.
         For example, if asked for "Cromer" but the entry in the LOCALITY column is "NWT Cromer", you should still consider this as a match.
         Therefore, when processing queries related to locality, if the exact wording cannot be found in the LOCALITY column, the language model should search for any occurrences of the specified word or substring within the column and consider those as matches.

         When referring to "birds observed together" in the dataset, it signifies birds sighted simultaneously within the same survey session.
         If the question is about number of birds in an observation, then look for column names with 'OBSERVATION COUNT' in the tables and use 'sum' function to find the total number of individual birds.
         If the question is about number of bird species, then look for column names with 'COMMON NAME' in the table and count distinct occurences to get the number of different species."""

system_message = SystemMessage(content=SQL_PREFIX)



# build sql agent to include prompt
llm = ChatOpenAI(model="gpt-4o-mini", temperature=0.5)
sql_agent = create_sql_agent(llm,db=db,
                             agent_type="openai-tools",
                             messages_modifier=system_message)
sql_agent.invoke({"input": "How many birds?"})["output"]

"""Make the Python agent using the csv version"""

from langchain.agents.agent_types import AgentType
from langchain_experimental.agents.agent_toolkits import create_csv_agent
import matplotlib.pyplot as plt

llm = ChatOpenAI(model="gpt-4o-mini", temperature=0.5)
python_agent = create_csv_agent(llm,
    "YOUR PATH HERE/norfolk_habitat.csv",
     prefix = "Assume 'df' is the dataframe provided and already loaded in the environment.",
    verbose=True,
    agent_type=AgentType.OPENAI_FUNCTIONS, allow_dangerous_code=True)

output = python_agent.invoke({"input": "Plot owl pie chart?"})["output"]

"""# 4. Build a query router

Set up chains. Here we set up the router which is responsible for selecting appropriate info
"""

### Router

from typing import Literal

from langchain_core.prompts import ChatPromptTemplate
from langchain_core.pydantic_v1 import BaseModel, Field
from langchain_openai import ChatOpenAI


# Data model
class RouteQuery(BaseModel):
    """Route a user query to the most relevant datasource."""

    datasource: Literal["vectorstore", "web_search", "conversation", "sql_database", "csv_database"] = Field(
        ...,
        description="Given a user question choose to route it to sql database, csv database, web search, conversation or a vectorstore.",
    )


# LLM with function call
llm = ChatOpenAI(model="gpt-4o-mini", temperature=0.5)
structured_llm_router = llm.with_structured_output(RouteQuery)

# Prompt
system = """You are an expert at routing a user question to a vectorstore, conversation or web search.
The vectorstore contains documents related to birds in Norfolk in 1955, 1985, and 2005.
Use the vectorstore for questions on these topics only (i.e. historical bird sightings in Norfolk).
Use the vectorstore for questions asking about historical bird observations in any year prior to 2006.
Use the vectorstore for questions relating to the Norfolk Bird and Mammal Report.

The sql_database contains data related to bird sightings collected by users in Norfolk.
Use the SQL database for questions asking for calculations or quantitative summaries based on these topics.
Use the SQL database for questions asking about which species can be seen together.
Use the SQL database for questions asking about bird occurence in habitats across Norfolk.

The csv_database also contains data related to bird sightings collected by users in Norfolk.
Only use the CSV database for questions asking for a graph, plot, map, or visualisation based on this data, including where the user says "show me" or "plot" or refers to any specific type of data visualisation.

Preferentially use vectorstore, SQL database or CSV database.

If a user uses informal conversation, then use conversation. Otherwise, use web-search. """
route_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "{question}"),
    ]
)
# Router chain
question_router = route_prompt | structured_llm_router

# Run test
print(question_router.invoke({"question": "Which bird watching sites are the easiest to get to in norfolk?"}))
print(question_router.invoke({"question": "How many birds are in the dataset?"}))
print(question_router.invoke({"question": "How are you?"}))
print(question_router.invoke({"question": "Plot the bird counts by day?"}))
print(question_router.invoke({"question": "Which birds could be seen in Norfolk in 1955?"}))

"""Grade the documents to see if they're relevant or not"""

### Retrieval Grader

# Data model
class GradeDocuments(BaseModel):
    """Binary score for relevance check on retrieved documents."""

    binary_score: str = Field(
        description="Documents are relevant to the question, 'yes' or 'no'"
    )


# LLM with function call
llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)
structured_llm_grader = llm.with_structured_output(GradeDocuments)

# Prompt
system = """You are a grader assessing relevance of a retrieved document to a user question. \n
    If the document contains keyword(s) or semantic meaning related to the user question, grade it as relevant. \n
    It does not need to be a stringent test. The goal is to filter out erroneous retrievals. \n
    Give a binary score 'yes' or 'no' score to indicate whether the document is relevant to the question."""
grade_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "Retrieved document: \n\n {document} \n\n User question: {question}"),
    ]
)

# Retriever grader chain
retrieval_grader = grade_prompt | structured_llm_grader

# Run test
question = "can i see birds in norfolk"
docs = retriever.invoke(question)
doc_txt = docs[0].page_content
res_retgr = retrieval_grader.invoke({"question": question, "document": doc_txt})

print(res_retgr)
res_retgr.binary_score

"""Build a generator responsible for generating the final query"""

### Generate

from langchain import hub
from langchain_core.output_parsers import StrOutputParser

# Prompt
prompt = hub.pull("rlm/rag-prompt")

# LLM
llm = ChatOpenAI(model_name="gpt-4o-mini", temperature=0.5)


# Post-processing
def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)


# Generate Chain
rag_chain = prompt | llm | StrOutputParser()

# Test Run
generation = rag_chain.invoke({"context": format_docs(docs), "question": question})
print(generation)

"""Create a fallback conversation chain"""

### Fallback Conversation
from langchain_core.output_parsers import StrOutputParser

system = """You are a highly knowledgeable assistant called created by the Natural History Museum.
    Your name is Seamus. If a user ask you anything other than something related to birds or birds in Norfolk and greetings you must not reply to that
    and remind them that you are just an assistant and they should only ask something related to birds.
    """

conv_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "{question}")
    ]
)

# LLM
conv_llm = ChatOpenAI(model_name="gpt-4o-mini", temperature=0.5)


# Conversation Chain
conversation_chain = conv_prompt | conv_llm | StrOutputParser()

# Test Run
conv_test1 = conversation_chain.invoke({"question":"What is the latin name for barn owl"})
print(conv_test1)
conv_test2 = conversation_chain.invoke({"question":"What is your name?"})
print(conv_test2)
conv_test3 = conversation_chain.invoke({"question":"Do you know how many people work at Natural History Museum?"})
print(conv_test3)

"""Hallucination grader - this will check to see if the response is grounded or if Seamus is chatting shit"""

### Hallucination Grader


# Data model
class GradeHallucinations(BaseModel):
    """Binary score for hallucination present in generation answer."""

    binary_score: str = Field(
        description="Answer is grounded in the facts, 'yes' or 'no'"
    )


# LLM with function call
llm = ChatOpenAI(model="gpt-4o-mini", temperature=0.5)
structured_llm_grader = llm.with_structured_output(GradeHallucinations)

# Prompt
system = """You are a grader assessing whether an LLM generation is grounded in / supported by a set of retrieved facts. \n
     Give a binary score 'yes' or 'no'. 'Yes' means that the answer is grounded in / supported by the set of facts."""
hallucination_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "Set of facts: \n\n {documents} \n\n LLM generation: {generation}"),
    ]
)

# Hallucination chain
hallucination_grader = hallucination_prompt | structured_llm_grader

# Run test
print(hallucination_grader.invoke({"documents": docs, "generation": generation}))

"""# 4. Grade the answer based on if the answer is sufficiently answered or not"""

class GradeAnswer(BaseModel):
    """Binary score to assess answer addresses question."""

    binary_score: str = Field(
        description="Answer addresses the question, 'yes' or 'no'"
    )


# LLM with function call
llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)
structured_llm_grader = llm.with_structured_output(GradeAnswer)

# Prompt
system = """You are a grader assessing whether an answer addresses / resolves a question \n
     Give a binary score 'yes' or 'no'. Yes' means that the answer resolves the question."""
answer_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "User question: \n\n {question} \n\n LLM generation: {generation}"),
    ]
)

# Answer grader chain
answer_grader = answer_prompt | structured_llm_grader

# Run test
print(answer_grader.invoke({"question": question, "generation": generation}))

"""Rewrite the question if the LLM is unable to answer properly"""

llm = ChatOpenAI(model="gpt-4o-mini", temperature=0.5)

# Prompt
system = """You a question re-writer that converts an input question to a better version that is optimized \n
     for vectorstore retrieval. Look at the input and try to reason about the underlying semantic intent / meaning."""
re_write_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        (
            "human",
            "Here is the initial question: \n\n {question} \n Formulate an improved question.",
        ),
    ]
)

# Question rewriter chain
question_rewriter = re_write_prompt | llm | StrOutputParser()

# Run test
question_rewriter.invoke({"question": question})

"""Set up web search tool using tavily"""

from langchain_community.tools.tavily_search import TavilySearchResults

# web search tool
web_search_tool = TavilySearchResults(k=3,include_images=True)

test_search = web_search_tool.invoke({"query":"what is tyto alba"})
test_search[0]

"""Set up the graph with all of the pre-defined components"""

from typing import List

from typing_extensions import TypedDict


class GraphState(TypedDict):
    """
    Represents the state of our graph.

    Attributes:
        question: question
        generation: LLM generation
        documents: list of documents
    """

    question: str
    generation: str
    documents: List[str]

from langchain.schema import Document


def transform_query(state):
    """
    Transform the query to produce a better question.

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): Updates question key with a re-phrased question
    """

    print("---TRANSFORM QUERY---")
    question = state["question"]
    documents = state["documents"]

    # Re-write question
    better_question = question_rewriter.invoke({"question": question})
    return {"documents": documents, "question": better_question}

def retrieve(state):
    """
    Retrieve documents

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): New key added to state, documents, that contains retrieved documents
    """
    print("---RETRIEVE---")
    question = state["question"]

    # Retrieval
    documents = retriever.invoke(question)
    return {"documents": documents, "question": question}

def conversation(state):
    """
    Acts as a fall back conversation chain.

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): New key added to state, generation, that contains LLM generation
    """
    print("---CONVERSATION---")
    question = state["question"]

    # Conversation
    conversation = conversation_chain.invoke({"question": question})
    return { "question": question, "generation": conversation}

def query_sql(state):
    """
    Queries SQL database on the question.

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): New key added to state, generation, that contains LLM generation from SQL
    """
    print("---SQL DATABASE---")
    question = state["question"]

    # Conversation
    sql_results = sql_agent.invoke({"input": question})["output"]
    return { "question": question, "generation": sql_results}

def query_csv(state):
    print("---CSV DATABASE---")
    question = state["question"]

    # Conversation
    python_results = python_agent.invoke({"input": question})["output"]

    # Initialize plot_filepath in case there is no plot generated
    state['plot_filepath'] = None

    # Check if a plot was generated and save it
    try:
        # Save the plot to a file
        plot_filepath = 'YOUR PATH HERE/generated_plot.png'
        plt.savefig(plot_filepath)

        print(f"Plot saved successfully at {plot_filepath}")
        state['plot_filepath'] = plot_filepath  # Save plot path to state for reference
    except Exception as e:
        print(f"No plot to save or failed to save plot: {e}")

    return {"question": question, "generation": python_results, "plot_filepath": state.get('plot_filepath')}



def grade_documents(state):
    """
    Determines whether the retrieved documents are relevant to the question.

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): Updates documents key with only filtered relevant documents
    """

    print("---CHECK DOCUMENT RELEVANCE TO QUESTION---")
    question = state["question"]
    documents = state["documents"]

    # Score each doc
    filtered_docs = []
    for d in documents:
        score = retrieval_grader.invoke(
            {"question": question, "document": d.page_content}
        )
        grade = score.binary_score
        if grade == "yes":
            print("---GRADE: DOCUMENT RELEVANT---")
            filtered_docs.append(d)
        else:
            print("---GRADE: DOCUMENT NOT RELEVANT---")
            continue
    return {"documents": filtered_docs, "question": question}


def web_search(state):
    """
    Web search based on the re-phrased question.

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): Updates documents key with appended web results
    """

    print("---WEB SEARCH---")
    question = state["question"]

    # Web search
    docs = web_search_tool.invoke({"query": question})
    web_results = "\n".join([d["content"] for d in docs])
    web_results = Document(page_content=web_results)

    return {"documents": web_results, "question": question}


def generate(state):
    """
    Generate answer

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): New key added to state, generation, that contains LLM generation
    """
    print("---GENERATE---")
    question = state["question"]
    documents = state["documents"]

    # RAG generation
    generation = rag_chain.invoke({"context": documents, "question": question})
    return {"documents": documents, "question": question, "generation": generation}


### Edges ###
def route_question(state):
    """
    Route question to web search, SQL database, CSV databse, conversation or RAG.

    Args:
        state (dict): The current graph state

    Returns:
        str: Next node to call
    """

    print("---ROUTE QUESTION---")
    question = state["question"]
    source = question_router.invoke({"question": question})
    if source.datasource == "web_search":
        print("---ROUTE QUESTION TO WEB SEARCH---")
        return "web_search"
    elif source.datasource == "vectorstore":
        print("---ROUTE QUESTION TO RAG---")
        return "vectorstore"
    elif source.datasource == "sql_database":
        print("--ROUTE QUESTION TO SQL DATABASE--")
        return "sql_database"
    elif source.datasource == "csv_database":
        print("--ROUTE QUESTION TO CSV DATABASE--")
        return "csv_database"
    elif source.datasource == "conversation":
        print("--ROUTE QUESTION TO CONVERSATION")
        return "conversation"


def decide_to_generate(state):
    """
    Determines whether to generate an answer, or re-generate a question.

    Args:
        state (dict): The current graph state

    Returns:
        str: Binary decision for next node to call
    """

    print("---ASSESS GRADED DOCUMENTS---")
    state["question"]
    filtered_documents = state["documents"]

    if not filtered_documents:
        # All documents have been filtered check_relevance
        # We will re-generate a new query
        print(
            "---DECISION: ALL DOCUMENTS ARE NOT RELEVANT TO QUESTION, TRANSFORM QUERY---"
        )
        return "transform_query"
    else:
        # We have relevant documents, so generate answer
        print("---DECISION: GENERATE---")
        return "generate"


def grade_generation_v_documents_and_question(state):
    """
    Determines whether the generation is grounded in the document and answers question.

    Args:
        state (dict): The current graph state

    Returns:
        str: Decision for next node to call
    """

    print("---CHECK HALLUCINATIONS---")
    question = state["question"]
    documents = state["documents"]
    generation = state["generation"]

    score = hallucination_grader.invoke(
        {"documents": documents, "generation": generation}
    )
    grade = score.binary_score

    # Check hallucination
    if grade == "yes":
        print("---DECISION: GENERATION IS GROUNDED IN DOCUMENTS---")
        # Check question-answering
        print("---GRADE GENERATION vs QUESTION---")
        score = answer_grader.invoke({"question": question, "generation": generation})
        grade = score.binary_score
        if grade == "yes":
            print("---DECISION: GENERATION ADDRESSES QUESTION---")
            return "useful"
        else:
            print("---DECISION: GENERATION DOES NOT ADDRESS QUESTION---")
            return "not useful"
    else:
        print("---DECISION: GENERATION IS NOT GROUNDED IN DOCUMENTS, RE-TRY---")
        return "not supported"

"""Build the graph"""

from langgraph.graph import END, StateGraph, START
from langgraph.checkpoint.memory import MemorySaver

memory = MemorySaver()


workflow = StateGraph(GraphState)

# Define the nodes
workflow.add_node("web_search", web_search)  # web search
workflow.add_node("retrieve", retrieve)  # retrieve
workflow.add_node("conversation", conversation)  # fallback conversation
workflow.add_node("query_sql", query_sql)  # query SQL database
workflow.add_node("query_csv", query_csv)  # query CSV database
workflow.add_node("grade_documents", grade_documents)  # grade documents
workflow.add_node("generate", generate)  # generate
workflow.add_node("transform_query", transform_query)  # transform_query

# Build graph
workflow.add_conditional_edges(
    START,
    route_question,
    {
        "conversation": "conversation",
        "web_search": "web_search",
        "vectorstore": "retrieve",
        "sql_database": "query_sql",
        "csv_database": "query_csv",

    },
)

workflow.add_edge("query_sql", END)
workflow.add_edge("query_csv", END)
workflow.add_edge("conversation", END)
workflow.add_edge("web_search", "generate")
workflow.add_edge("retrieve", "grade_documents")
workflow.add_conditional_edges(
    "grade_documents",
    decide_to_generate,
    {
        "transform_query": "transform_query",
        "generate": "generate",
    },
)
workflow.add_edge("transform_query", "retrieve")
workflow.add_conditional_edges(
    "generate",
    grade_generation_v_documents_and_question,
    {
        "not supported": "generate",
        "useful": END,
        "not useful": "transform_query",
    },
)


# Compile
app = workflow.compile(checkpointer=memory)

# and visualise as a workflow
from IPython.display import Image, display

try:
    display(Image(app.get_graph().draw_mermaid_png()))
except Exception:
    # This requires some extra dependencies and is optional
    pass

"""Test the graph"""

from pprint import pprint

# Run
inputs = {
    "question": "show me a pie chart of owls"
}
thread = {"configurable": {"thread_id": "1"}}
for output in app.stream(inputs,  thread):
    for key, value in output.items():
        # Node
        pprint(f"Node '{key}':")
        # Optional: print full state at each node
        #pprint.pprint(value["keys"], indent=2, width=80, depth=None)
    pprint("\n---\n")

# Final generation
pprint(value["generation"])

print(f"Current history: {memory}")  # Debugging line

import time

def inference(inputs, history, *args, **kwargs):
    """
    Inference Generator to support streaming

    Args:
        inputs (str): The input query for inference
        history (list[list] | list[tuple]): The chat history; internally managed by the gradio app
        args: additional arguments
        kwargs: additional keyword arguments

    Yields:
      str: A string containing a portion of the generated text, simulating a gradual generation process.
    """
    # thread is required for memory checkpoint
    thread = {"configurable": {"thread_id": "1"}}

    # input the graph
    inputs = {"question": inputs}

    # the output can be streamed but due to the print statements, I am using invoke
    output = app.invoke(inputs, thread)

    output_generation = output["generation"].split(" ")
    generated_text = ""

    if "show me" in inputs["question"].lower():
        image_generated = True
        # Replace with actual image generation logic
        output_image_path = "YOUR PATH HERE/example_plot.png"

    for i in  range(len(output_generation)):
        time.sleep(0.05)
        generated_text = ' '.join(output_generation[:i+1])

        yield generated_text

"""Set up Gradio"""

import gradio as gr

chat_interface = gr.ChatInterface(
    inference,
    chatbot=gr.Chatbot(height=300),
    textbox=gr.Textbox(placeholder="Chat to Seamus", container=True, scale=7),
    title="Chat to Seamus",
    description="Ask me anything about birds in Norfolk.",
    undo_btn=None,
    clear_btn="Clear",
)

demo = gr.TabbedInterface([chat_interface], ["Chat"])
demo.launch()

import gradio as gr
import pandas as pd
import matplotlib.pyplot as plt

# Example DataFrame for testing purposes
data = {
    'COMMON NAME': ['Barn Owl', 'Snowy Owl', 'Great Horned Owl', 'Eastern Screech Owl', 'Western Screech Owl'],
    'COUNT': [10, 5, 7, 3, 2],
}
df = pd.DataFrame(data)

# The query_csv function as previously defined
def query_csv(state):
    question = state["question"]

    if "pie chart" in question.lower():
        try:
            # Filter the DataFrame for owls
            owls_df = df[df['COMMON NAME'].str.contains('owl', case=False, na=False)]
            owl_counts = owls_df['COMMON NAME'].value_counts()

            # Create a pie chart
            plt.figure(figsize=(10, 6))
            plt.pie(owl_counts, labels=owl_counts.index, autopct='%1.1f%%', startangle=140)
            plt.title('Distribution of Owl Species Observations')
            plt.axis('equal')  # Equal aspect ratio ensures that pie chart is circular.

            # Save the plot to a file
            plot_filepath = 'YOUR PATH HERE/generated_plot.png'
            plt.savefig(plot_filepath)
            plt.close()  # Close the plot to free memory

            # Return output state
            return {
                "question": question,
                "generation": "Here is the pie chart showing the distribution of owl species.",
                "plot_filepath": plot_filepath
            }
        except Exception as e:
            return {
                "question": question,
                "generation": f"Error generating the plot: {e}",
                "plot_filepath": None
            }
    else:
        return {
            "question": question,
            "generation": "No valid query for pie chart found.",
            "plot_filepath": None
        }

# Gradio interface
def inference(inputs):
    state = {"question": inputs}
    output = query_csv(state)

    # Check if a plot file was generated
    if output['plot_filepath']:
        return output['generation'], output['plot_filepath']
    else:
        return output['generation'], None

# Setting up Gradio UI
with gr.Blocks() as app:
    gr.Markdown("## Owl Species Distribution Query")
    question_input = gr.Textbox(label="Ask about Owl Species (e.g., 'Show me a pie chart of owls')")
    submit_button = gr.Button("Submit")
    output_text = gr.Textbox(label="Response", interactive=False)
    output_image = gr.Image(label="Generated Pie Chart", type="filepath")

    # Set up the interaction
    submit_button.click(fn=inference, inputs=question_input, outputs=[output_text, output_image])

# Launch the app
app.launch()


