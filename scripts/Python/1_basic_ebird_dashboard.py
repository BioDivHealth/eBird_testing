# -*- coding: utf-8 -*-
"""1_basic_eBird_dashboard.ipynb

Install dependencies
"""

# Commented out IPython magic to ensure Python compatibility.
# %pip install -qU langchain langchain-openai langchain-community langchain-experimental pandas gradio

"""Link to openAI and langsmith keys"""

import getpass
import os

os.environ["OPENAI_API_KEY"] = YOUR KEY HERE

# Using LangSmith is recommended but not required. Uncomment below lines to use.
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = YOUR KEY HERE

"""Download eBird sample csv"""

import pandas as pd

df = pd.read_csv("YOUR PATH HERE/norfolk_ebird_metadata.csv", encoding="ISO-8859-1")
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

"""Save the model for use again

Ask a question
"""

agent_executor.invoke({"input": "what is the scientific name of the Little Egret?"})

agent_executor.invoke({"input": "Which observer has the highest overall duration?"})

agent_executor.invoke({"input": "what is most common protocol type?"})

agent_executor.invoke({"input": "what was the total OBSERVATION count?"})

agent_executor.invoke({"input": "Which exotic species were found?"})

agent_executor.invoke({"input": "which bird is the most rare in the dataset?"})

"""# Gradio App

Run this to generate the app
"""

import gradio as gr

def answer_question(question):
    # Use agent_executor to generate a response
    response = agent_executor.invoke(question)
    return response


gr.Interface(fn=answer_question, inputs = "text",
             outputs="text", title="Chat with Seamus",
             description="Ask a question about eBird matrix data.").launch()
