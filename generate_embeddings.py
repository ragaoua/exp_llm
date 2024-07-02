from time import time  # For debugging purposes
from sentence_transformers import SentenceTransformer
from connect import get_pg_connection

DEBUG = True

model = SentenceTransformer("paraphrase-MiniLM-L3-v2", device="cuda")

# The first connection will be used to query the data
# The second will be used to insert the embeddings
# We need 2 distinct sessions here because the data will be pulled
# by batches to avoid overloading the memory of the client side
with get_pg_connection() as selection_connection:
    with get_pg_connection() as insertion_connection:
        with selection_connection.cursor(
            name="server-side cursor"
        ) as selection_cursor:
            # This is the number of rows we"ll be fetching at a time
            batch_size = 1000
            if DEBUG:
                batch_counter = 1

            if DEBUG:
                print("Querying data...")
                start = time()

            selection_cursor.execute("""
                SELECT id, conversation
                FROM ticket_conversations
            """)

            if DEBUG:
                end = time()
                print("Query done (time: %fs)" % (end - start))
                print("Fetching batch %d" % (batch_counter))
                start = time()

            rows = selection_cursor.fetchmany(batch_size)
            while rows:
                ticket_ids = [row[0] for row in rows]
                conversations = [row[1] for row in rows]

                if DEBUG:
                    end = time()
                    print("Fetching done (time: %fs)" % (end - start))
                    print("Processing embeddings...")
                    start = time()

                embeddings = model.encode(conversations)

                if DEBUG:
                    end = time()
                    print("Processing done (time: %fs)" % (end - start))
                    print("Inserting data...")
                    start = time()

                with insertion_connection.cursor() as insertion_cursor:
                    with insertion_cursor.copy("""
                        COPY ticket_conversation_embeddings(
                            ticket_id, embedding
                        ) FROM STDIN
                    """) as copy:
                        for i in range(len(rows)):
                            copy.write_row((
                                ticket_ids[i],
                                embeddings[i].tolist().__str__()
                            ))
                    insertion_connection.commit()

                    if DEBUG:
                        end = time()
                        print("Inserting done (time: %fs)" % (end - start))
                        batch_counter += 1
                        print("Fetching batch %d" % (batch_counter))
                        start = time()

                rows = selection_cursor.fetchmany(batch_size)
