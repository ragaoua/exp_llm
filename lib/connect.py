import psycopg
from contextlib import contextmanager


@contextmanager
def get_pg_connection():
    host = "db"
    port = "5432"
    dbname = "otrs"
    dbrole = "postgres"

    try:
        connection = psycopg.connect(
            host=host,
            port=port,
            dbname=dbname,
            user=dbrole
        )
        yield connection
    finally:
        connection.close()
