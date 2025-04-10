import streamlit as st
from huggingface_hub import InferenceClient

# Load Hugging Face API token from token.txt
try:
    with open("token.txt", "r") as file:
        API_TOKEN = file.read().strip()
except FileNotFoundError:
    st.error(
        "Error: token.txt not found. Please create a token.txt file with your Hugging Face API token."
    )
    st.stop()

# Initialize InferenceClient
client = InferenceClient(api_key=API_TOKEN)

st.set_page_config(page_title="🤗💬 HugChat")

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = [
        {"role": "assistant", "content": "How may I help you?"}
    ]

# Display chat messages
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.write(message["content"])


# Function to query Hugging Face API using InferenceClient
def generate_response(prompt):
    try:
        completion = client.chat.completions.create(
            model="mistralai/Mixtral-8x7B-Instruct-v0.1",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=100,
            temperature=0.7,
        )
        return completion.choices[0].message.content
    except Exception as e:
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
