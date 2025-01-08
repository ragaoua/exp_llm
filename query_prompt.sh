#!/bin/bash

print_ticket=false
consider_full_ticket=false
nb_tickets=5

while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--limit)
      nb_tickets="$2"
      shift
      shift
      ;;
    -p|--print-ticket)
      print_ticket=true
      shift
      ;;
    -f|--consider-full-ticket)
      consider_full_ticket=true
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
readonly prompt nb_tickets print_ticket consider_full_ticket

readonly db="otrs"
readonly role="postgres"
readonly psql="psql -h localhost -U "$role" -d "$db" --tuples-only --no-align"

${psql[@]} --set prompt="$prompt" <<EOF
SELECT openai.vector(:'prompt')::vector as prompt_embedding \gset

SELECT t.id, t.tn $("$print_ticket" && echo ", tc.conversation")
FROM ticket t
JOIN ticket_embeddings te ON te.ticket_id = t.id
JOIN ticket_conversations tc ON tc.id = te.ticket_id
$(
if "$consider_full_ticket" ; then
  echo "ORDER BY te.conversation_embedding <-> :'prompt_embedding'"
else
  echo "ORDER BY te.first_article_embedding <-> :'prompt_embedding'"
fi
)
LIMIT $nb_tickets;
EOF
