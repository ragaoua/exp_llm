Experiment with function calling. This projects showcases the llms' ability
to determine which functions are relevant for execution with which arguments
given a prompt.

Run with :

~~~bash
APP=<app_name> podman-compose up
~~~

Where `app_name` is either "weather" or "logs". This defines which python file
will be executed (see [app](app)). Default is "weather".


# weather

The python container should print out something like :

~~~
[python] | Based on the tool call responses, I can provide you with the following information:
[python] |
[python] | * The weather in Toronto is sunny.
[python] | * The weather in Paris is rainy.
[python] | ------ History :
[python] | user : What is the weather in Toronto ? What about Paris ?
[python] | assistant : [ToolCall(function=Function(name='get_current_weather', arguments={'city': 'Toronto'})), ToolCall(function=Function(name='get_current_weather', arguments={'city': 'Paris'}))]
[python] | tool : It's sunny out here !
[python] | tool : It's raining today
[python] | assistant : Based on the tool call responses, I can provide you with the following information:
[python] |
[python] | * The weather in Toronto is sunny.
[python] | * The weather in Paris is rainy.
~~~


# logs

The python container should print out something like :

~~~
[python] | Based on the tool call output, around 9 AM on February 12th, 2025, on the database hosted on server DEA657FD, several events occurred. These include:
[python] |
[python] | 1. A user named 'admin' logged out at 09:02:28.
[python] | 2. A new user named 'mary_smith' was created at 09:07:15.
[python] | 3. A slow query was detected on the 'orders' table at 09:14:42, which might indicate performance issues with this query.
[python] | 4. The database optimization process started at 09:22:35 and completed successfully at 09:28:50.
[python] | ------ History :
[python] | user : Can you tell me what major events happened around 9 AM on february 12th, 2025 on the database hosted on server DEA657FD ?
[python] | assistant : [ToolCall(function=Function(name='get_db_logs', arguments={'range_end': '2025-02-12 09:59:59', 'range_start': '2025-02-12 09:00:00', 'server': 'DEA657FD'}))]
[python] | tool : 2025-02-12 09:02:28 INFO: User 'admin' logged out.
[python] | 2025-02-12 09:07:15 INFO: New user 'mary_smith' created.
[python] | 2025-02-12 09:14:42 WARNING: Slow query detected on 'orders' table.
[python] | 2025-02-12 09:22:35 INFO: Database optimization process started.
[python] | 2025-02-12 09:28:50 INFO: Optimization completed successfully.
[python] | assistant : Based on the tool call output, around 9 AM on February 12th, 2025, on the database hosted on server DEA657FD, several events occurred. These include:
[python] |
[python] | 1. A user named 'admin' logged out at 09:02:28.
[python] | 2. A new user named 'mary_smith' was created at 09:07:15.
[python] | 3. A slow query was detected on the 'orders' table at 09:14:42, which might indicate performance issues with this query.
[python] | 4. The database optimization process started at 09:22:35 and completed successfully at 09:28:50.
~~~
