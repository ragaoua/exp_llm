import ollama


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


model = "llama3.1"
ollama.pull(model)

messages = [
    {
        'role': 'user',
        'content': "What is the weather in Toronto ? What about Paris ?"
    },
]

response = ollama.chat(
    model=model,
    messages=messages,
    tools=[get_current_weather],
)

if response.message.tool_calls:
    messages.append(response.message)

    for tc in response.message.tool_calls:
        print(f"DEBUG - Executing tool call : {tc}")
        tc_function = eval(tc.function.name)
        args = tc.function.arguments

        # This is dangerous in real environments, since we're not checking what
        # function is executed or the parameters it is called with.
        tc_return = tc_function(**args)
        messages.append(
            {'role': 'tool', 'name': tc.function.name, 'content': tc_return}
        )
        print(f"DEBUG - Function returned with : {tc_return}")

    response = ollama.chat(
        model=model,
        messages=messages,
        tools=[get_current_weather],
    )

print(response.message.content)
