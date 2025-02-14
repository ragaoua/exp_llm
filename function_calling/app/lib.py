import ollama
from ollama import Message
from typing import Callable


def chat_with_tools(
    model: str,
    message: str,
    tools: [Callable[[], str]],
) -> str:
    """
    Prompts an LLM while providing it with tools (ie functions) it
    can decide to use to generate its answers

    Args:
        model (str): name of the model
        message (str): user prompt
        tools ([Callable[[], str]]): list of functions available for the LLM

    Returns:
        [str]: history of messages exchanged with the LLM
    """
    ollama.pull(model)
    messages = [Message(role='user', content=message)]

    while True:
        response = ollama.chat(
            model=model,
            messages=messages,
            tools=tools,
        )
        messages.append(response.message)

        if not response.message.tool_calls:
            break
        else:
            for tc in response.message.tool_calls:
                tc_function = next(
                    (func for func in tools if func.__name__ == tc.function.name)
                )
                args = tc.function.arguments

                # This is dangerous in real environments, since we're not checking
                # what function is executed or the parameters it is called with.
                tc_return = tc_function(**args)
                messages.append(Message(
                    role='tool',
                    name=tc.function.name,
                    content=tc_return
                ))

    return messages
