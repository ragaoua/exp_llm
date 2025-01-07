#!/bin/bash

readonly db="otrs"
readonly role="postgres"
readonly psql="psql -h localhost -U "$role" -d "$db""

${psql[@]} <<EOF
TRUNCATE ticket_conversation_embeddings;

INSERT INTO ticket_conversation_embeddings
SELECT id, openai.vector(conversation)::vector, openai.vector(first_article)::vector FROM ticket_conversations;
EOF
