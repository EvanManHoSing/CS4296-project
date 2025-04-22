import streamlit as st
import requests
import time
import logging
from pythonjsonlogger import jsonlogger
import os

# Backend URL (local Flask server)
BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:5000/generate") 

st.set_page_config(page_title="🤗💬 HugChat")

# Setting up the logger
logger = logging.getLogger()
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter("{message}", style="{")
logHandler.setFormatter(formatter)

logger.addHandler(logHandler)
logger.setLevel(logging.INFO)
logging.getLogger('werkzeug').disabled = True



# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = [
        {"role": "assistant", "content": "How may I help you?"}
    ]

# Display chat messages
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.write(message["content"])

# Function for loggin
def log_coldTime(start):
    end = time.time()
    duration = round(end -start,5)
    logger.info({
        "message": "Cold Time",
        "duration": duration,
    })
    return duration

# Function to call the backend
def generate_response(prompt):
    try:
        response = requests.post(BACKEND_URL, json={"prompt": prompt})
        response.raise_for_status()  # Raise an error for bad status codes
        data = response.json()
        return data["response"],data["duration"]
    except requests.exceptions.RequestException as e:
        return f"Error: {str(e)}"


# Handle user input
if prompt := st.chat_input():

    # Timer for cold start record
    start = time.time()

    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.write(prompt)
    with st.spinner("Thinking..."):
        response,responseTime = generate_response(prompt)

        # Displaying the logging data on frontend
        coldTime = log_coldTime(start)
        st.info(f"The cold time is {coldTime} seconds.", icon="⏱️")
        st.success(f"The response time is {responseTime} seconds.", icon="⏱️")

        st.session_state.messages.append({"role": "assistant", "content": response})
        with st.chat_message("assistant"):
            st.write(response)
