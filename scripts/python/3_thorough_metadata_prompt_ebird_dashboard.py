# -*- coding: utf-8 -*-
"""3_TIME_prompt_eBird_dashboard.ipynb

Install dependencies
"""

# Commented out IPython magic to ensure Python compatibility.
# %pip install -qU langchain langchain-openai langchain-community langchain-experimental pandas gradio

"""Link to openAI and langsmith keys"""

import getpass
import os

os.environ["OPENAI_API_KEY"] = INSERT KEY HERE

# Using LangSmith is recommended but not required. Uncomment below lines to use.
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = INSERT KEY HERE

"""Download eBird sample csv"""

import pandas as pd

df = pd.read_csv("INSERT PATH HERE/norfolk_ebird.csv")
print(df.shape)
print(df.columns.tolist())

"""Convert to SQL format"""

from langchain_community.utilities import SQLDatabase
from sqlalchemy import create_engine

engine = create_engine("sqlite:///norfolk_sample.db")
df.to_sql("norfolk_sample", engine, index=False)

"""Filter only for approved/moderated entries"""

db = SQLDatabase(engine=engine)
print(db.dialect)
print(db.get_usable_table_names())
#db.run("SELECT * FROM norfolk_sample WHERE APPROVED = 1;")

"""Create a SQL agent to interact with the data"""

from langchain_community.agent_toolkits import create_sql_agent
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0.5)
agent_executor = create_sql_agent(llm, db=db, agent_type="openai-tools", verbose=True)

"""Insert prompt for metadata"""

from langchain.prompts.chat import ChatPromptTemplate

final_prompt = ChatPromptTemplate.from_messages(
    [
        ("system",
         """
          You are a helpful AI assistant expert in querying SQL Database to find answers to user's question about bird sightings in Norfolk. Here is some useful metadata for the columns.
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

         In the SQL data provided, there are three columns relevant to time,

         TIME OBSERVATIONS STARTED: This column indicates the time at which a survey began, represented in 24-hour clock format. For example, if the value is "14:40:00", it means the survey started at 2:40 PM.
         DURATION MINUTES: This column specifies the duration of the survey in minutes. For instance, if the value is "10", and the corresponding "TIME OBSERVATIONS STARTED" is "14:40:00", then the survey ended at "14:50:00".
         OBSERVATION DATE: This column represents the date of the observation in "DD/MM/YYYY" format. For example, "19/03/2022" denotes the 19th of March, 2022.
         When answering questions related to time or date from the data, please consider these columns for accurate interpretation and calculation of time intervals.


         In the SQL data provided, there is a column named LOCALITY which contains information about the locality of the observation. It's important to note that sometimes the exact wording for a locality may not be present in the column, but a variation or a substring might exist.
         For example, if asked for "Cromer" but the entry in the LOCALITY column is "NWT Cromer", you should still consider this as a match.
         Therefore, when processing queries related to locality, if the exact wording cannot be found in the LOCALITY column, the language model should search for any occurrences of the specified word or substring within the column and consider those as matches.

         When referring to "birds observed together" in the dataset, it signifies birds sighted simultaneously within the same survey session.
         If the question is about number of birds in an observation, then look for column names with 'OBSERVATION COUNT' in the tables and use 'sum' function to find the total number of individual birds.
         If the question is about number of bird species, then look for column names with 'COMMON NAME' in the table and count distinct occurences to get the number of different species.
         """
         ),
        ("user", "{question}\n ai: "),
    ]
)

"""Ask a question"""

agent_executor.run(final_prompt.format(
        question="What was the most common bird sighted before 2pm?"
  ))

agent_executor.run(final_prompt.format(
        question="Which two species are most likely to be observed together in the same survey??"
  ))

agent_executor.run(final_prompt.format(
        question="How many unique bird species have been observed at Cromer Golf Course?"
  ))

agent_executor.run(final_prompt.format(
        question="which birds were seen in windy conditions?"
  ))

agent_executor.run(final_prompt.format(
        question="which bird species is the most rare in the dataset?"
  ))

agent_executor.invoke({"input": "which bird is the most rare in the dataset?"})

"""# Gradio App

Run this to generate the app
"""

import gradio as gr

def answer_question(question):
    # Use agent_executor to generate a response
    response = agent_executor.run(final_prompt.format(question=question))
    return response

gr.Interface(fn=answer_question, inputs="text",
             outputs="text", title="Chat with Seamus",
             description="Ask a question about eBird matrix data.").launch()
