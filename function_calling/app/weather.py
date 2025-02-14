from lib import chat_with_tools


def get_current_weather(city: str):
    """
    Get the current weather for a city

    Args:
        city: The name of the city

    Returns:
        str: the weather in the city
    """
    if city == 'Toronto':
        return "It's sunny out here !"
    return "It's raining today"


messages = chat_with_tools(
    model="llama3.1",
    message="What is the weather in Toronto ? What about Paris ?",
    tools=[get_current_weather]

)
print(messages[-1].content)
print("------ History :")
for message in messages:
    if message.tool_calls:
        print(f'{message.role} : {message.tool_calls}')
    else:
        print(f'{message.role} : {message.content}')
