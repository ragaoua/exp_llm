#!/bin/bash

print_conversation=false
first_article_only=false
nb_tickets=5

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
    -f|--first-article-only)
      first_article_only=true
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
readonly prompt nb_tickets print_conversation first_article_only

readonly db="otrs"
readonly role="postgres"
readonly psql="psql -h localhost -U "$role" -d "$db" --tuples-only --no-align"

${psql[@]} --set prompt="$prompt" <<EOF
SELECT openai.vector(:'prompt')::vector as prompt_embedding \gset

SELECT t.tn $("$print_conversation" && echo ", tc.conversation")
FROM ticket t
JOIN ticket_embeddings te ON te.ticket_id = t.id
JOIN ticket_conversations tc ON tc.id = te.ticket_id
$(
if "$first_article_only" ; then
  echo "ORDER BY te.first_article_embedding <-> :'prompt_embedding'"
else
  echo "ORDER BY te.conversation_embedding <-> :'prompt_embedding'"
fi
)
LIMIT $nb_tickets;
EOF
