import streamlit as st

st.title("My chatbot")

prompt = st.chat_input("Ask me anything")

if 'messages' not in st.session_state:
    st.session_state.messages = []

for message in st.session_state.messages:
    st.chat_message(message['role']).markdown(message['content'])

if prompt:
    st.chat_message('user').markdown(prompt)
    st.session_state.messages.append({
        'role': 'user',
        'content': prompt
    })
