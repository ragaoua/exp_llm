from datetime import datetime
import json
from lib import chat_with_tools


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


messages = chat_with_tools(
    model="llama3.1",
    message="Can you tell me what major events happened around 9 AM on february 12th, 2025 on the database hosted on server DEA657FD ?",
    tools=[get_db_logs]
)
print(messages[-1].content)
print("------ History :")
for message in messages:
    if message.tool_calls:
        print(f'{message.role} : {message.tool_calls}')
    else:
        print(f'{message.role} : {message.content}')
