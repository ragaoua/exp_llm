import ollama
from datetime import datetime
import json


def get_db_logs(server: str, range_start: str, range_end: str) -> str:
    """
    Get the logs from the database hosted on a server within a time range

    Args:
        server (str): The hostname or IP address of the database server.
        range_start (str): The start of the time range (formatted as YYYY-MM-DD HH:MM:SS).
        range_end (str): The end of the time range (formatted as YYYY-MM-DD HH:MM:SS).
    Returns:
        str: log entries within the specified time range.
    """
    with open("logs.json") as log_file:
        logs = json.load(log_file)
        dt_format = '%Y-%m-%d %H:%M:%S'
        range_start_dt = datetime.strptime(range_start, dt_format)
        range_end_dt = datetime.strptime(range_end, dt_format)

        return "\n".join([
            log
            for log_time, log in logs[server].items()
            if range_start_dt <= datetime.strptime(log_time, dt_format) <= range_end_dt
        ])


model = "llama3.1"
ollama.pull(model)

messages = [
    {
        'role': 'user',
        'content': "Can you tell me what major events happened around 9 AM on february 12th, 2025 on the database hosted on server DEA657FD ?"
    },
]
tools = [get_db_logs]

response = ollama.chat(
    model=model,
    messages=messages,
    tools=tools,
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
        tools=tools,
    )

print(response.message.content)
