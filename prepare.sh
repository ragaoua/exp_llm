#!/bin/bash

readonly embedding_model="nextfire/paraphrase-multilingual-minilm"
readonly prompt_model="phi3"

podman exec -it otrs_ollama ollama pull "$embedding_model"
podman exec -it otrs_ollama ollama pull "$prompt_model"

readonly db="otrs"
readonly role="postgres"
readonly psql="psql -h localhost -U "$role" -d "$db""

curl -s https://raw.githubusercontent.com/pramsey/pgsql-openai/main/openai--1.0.sql | ${psql[@]}

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

CREATE EXTENSION http;

ALTER DATABASE $db SET openai.api_uri = 'http://otrs_ollama:11434/v1/';
ALTER DATABASE $db SET openai.api_key = 'none';
ALTER DATABASE $db SET openai.prompt_model = '$prompt_model';
ALTER DATABASE $db SET openai.embedding_model = '$embedding_model';
EOF
