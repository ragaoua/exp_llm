en gros :

psql <<EOF
INSERT INTO ticket_conversation_embeddings
SELECT id, openai.vector(conversation) FROM ticket_conversations;
EOF
