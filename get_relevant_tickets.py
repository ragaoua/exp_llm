from pgvector.psycopg import register_vector
from connect import get_pg_connection
import sys


def get_relevant_tickets(ticket_number: int):

    with get_pg_connection() as connection:
        register_vector(connection)
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT nn.tn, nc.conversation
                FROM ticket_conversation_embeddings t
                JOIN ticket tt ON tt.id = t.ticket_id
                JOIN ticket_conversation_embeddings n ON t.ticket_id <> n.ticket_id
                JOIN ticket_conversations nc ON n.ticket_id = nc.id
                JOIN ticket nn ON nn.id = n.ticket_id
                WHERE tt.tn = %s
                ORDER BY t.embedding <-> n.embedding
                LIMIT 5;
           """, (ticket_number,))
            return cursor.fetchall()


if __name__ == '__main__':
    ticket_number = sys.argv[1]

    debug = False
    try:
        debug = sys.argv[2] == "DEBUG"
    except IndexError:
        pass

    relevant_tickets = get_relevant_tickets(ticket_number)

    for ticket in relevant_tickets:
        if debug:
            print("-------------------------------------------------")
            print("-------------------------------------------------")
            print("-------------------------------------------------")
            print("-------------------------------------------------")
            print("-------------------------------------------------")
            print("-------------------------------------------------")

        print(ticket[0])

        if debug:
            print(ticket[1])
