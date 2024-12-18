#!/bin/bash

readonly db="otrs"
readonly role="postgres"
readonly psql="psql -h localhost -U "$role" -d "$db""

${psql[@]} <<EOF
INSERT INTO ticket_conversation_embeddings
SELECT id, openai.vector(conversation)::vector FROM ticket_conversations;
EOF
