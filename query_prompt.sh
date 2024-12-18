#!/bin/bash

print_conversation=false
while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--limit)
      nb_tickets="$2"
      shift
      shift
      ;;
    -p|--print-conversation)
      print_conversation=true
      shift
      ;;
    -*|--*)
      echo "Unknown option $1" >&2
      exit 1
      ;;
    *)
      if [ ! -z "$prompt" ] ; then
        echo "Only one positional argument expected" >&2
        exit 1
      fi
      prompt="$1"
      shift
      ;;
  esac
done

if [ -z "$prompt" ] ; then
  echo "One positional argument expected" >&2
  exit 1
fi
[ -z "$nb_tickets" ] && nb_tickets=5
readonly prompt nb_tickets print_conversation

readonly db="otrs"
readonly role="postgres"
readonly psql="psql -h localhost -U "$role" -d "$db" --tuples-only --no-align"

${psql[@]} --set prompt="$prompt" <<EOF
SELECT openai.vector(:'prompt')::vector as prompt_embedding \gset

SELECT t.tn $("$print_conversation" && echo ", c.conversation")
FROM ticket_conversation_embeddings e
JOIN ticket_conversations c ON e.ticket_id = c.id
JOIN ticket t ON t.id = e.ticket_id
ORDER BY e.embedding <-> :'prompt_embedding'
LIMIT $nb_tickets;
EOF
