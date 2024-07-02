#!/bin/bash

readonly db="otrs"
readonly role="postgres"
readonly psql="psql -h localhost -U "$role" -d "$db""

readonly vector_size=384

${psql[@]} << EOF
CREATE EXTENSION vector;

CREATE TABLE ticket_conversation_embeddings(
        ticket_id bigint PRIMARY KEY REFERENCES ticket(id),
	embedding VECTOR($vector_size)
);

CREATE MATERIALIZED VIEW ticket_conversations AS
        SELECT t.id, string_agg(d.a_body, '\n' ORDER BY d.incoming_time) as conversation
        FROM ticket t
        JOIN article a ON a.ticket_id = t.id
        JOIN article_data_mime d ON d.article_id = a.id
        WHERE article_sender_type_id <> 2 -- Ignorer les réponses automatiques
        AND t.queue_id = 116 -- PostgreSQl
        GROUP BY t.id
;
EOF
