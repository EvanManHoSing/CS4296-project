import streamlit as st
import requests

st.set_page_config(page_title="🤗💬 HugChat")

# Backend URL (local Flask server)
BACKEND_URL = "http://localhost:5000/generate"

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = [
        {"role": "assistant", "content": "How may I help you?"}
    ]

# Display chat messages
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.write(message["content"])


# Function to call the backend
def generate_response(prompt):
    try:
        response = requests.post(BACKEND_URL, json={"prompt": prompt})
        response.raise_for_status()  # Raise an error for bad status codes
        return response.json()["response"]
    except requests.exceptions.RequestException as e:
        return f"Error: {str(e)}"


# Handle user input
if prompt := st.chat_input():
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.write(prompt)
    with st.spinner("Thinking..."):
        response = generate_response(prompt)
        st.session_state.messages.append({"role": "assistant", "content": response})
        with st.chat_message("assistant"):
            st.write(response)
