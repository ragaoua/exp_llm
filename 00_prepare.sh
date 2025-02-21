#!/bin/bash

readonly embedding_model="nomic-embed-text"
readonly prompt_model="phi3"

podman exec -it otrs_ollama ollama pull "$embedding_model"
podman exec -it otrs_ollama ollama pull "$prompt_model"

readonly db="otrs"
readonly role="postgres"
readonly psql="psql -h localhost -U "$role" -d "$db""

readonly vector_size=768

${psql[@]} << EOF
CREATE EXTENSION IF NOT EXISTS vector;

CREATE SCHEMA aide;
CREATE TABLE IF NOT EXISTS aide.ticket_embeddings(
    ticket_id bigint PRIMARY KEY REFERENCES ticket(id),
	conversation_embedding VECTOR($vector_size),
	first_article_embedding VECTOR($vector_size)
);

CREATE MATERIALIZED VIEW IF NOT EXISTS aide.ticket_conversations AS
    WITH postgresql_articles AS (
        SELECT
            t.id as ticket_id,
            d.a_body as article
        FROM ticket t
        JOIN article a ON a.ticket_id = t.id
        JOIN article_data_mime d ON d.article_id = a.id
        WHERE article_sender_type_id <> 2 -- Ignorer les réponses automatiques
        AND t.queue_id = 116 -- PostgreSQl
        ORDER BY t.id, d.incoming_time
    )
    SELECT DISTINCT ON (ticket_id)
        ticket_id as id,
        string_agg(article, E'\n') OVER (PARTITION BY ticket_id) AS conversation,
        article as first_article
    FROM postgresql_articles
;

CREATE EXTENSION IF NOT EXISTS http;
EOF

curl -s https://raw.githubusercontent.com/pramsey/pgsql-openai/main/openai--1.0.sql | ${psql[@]}

${psql[@]} << EOF
ALTER DATABASE $db SET openai.api_uri = 'http://otrs_ollama:11434/v1/';
ALTER DATABASE $db SET openai.api_key = 'none';
ALTER DATABASE $db SET openai.prompt_model = '$prompt_model';
ALTER DATABASE $db SET openai.embedding_model = '$embedding_model';
EOF
