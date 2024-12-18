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
      if [ ! -z "$ticket_number" ] ; then
        echo "Only one positional argument expected" >&2
        exit 1
      fi
      ticket_number="$1"
      shift
      ;;
  esac
done

if [ -z "$ticket_number" ] ; then
  echo "One positional argument expected" >&2
  exit 1
fi
[ -z "$nb_tickets" ] && nb_tickets=5
readonly ticket_number nb_tickets print_conversation

readonly db="otrs"
readonly role="postgres"
readonly psql="psql -h localhost -U "$role" -d "$db" --tuples-only --no-align"

${psql[@]} <<EOF
SELECT nn.tn $("$print_conversation" && echo ", nc.conversation")
FROM ticket_conversation_embeddings t
JOIN ticket tt ON tt.id = t.ticket_id
JOIN ticket_conversation_embeddings n ON t.ticket_id <> n.ticket_id
JOIN ticket_conversations nc ON n.ticket_id = nc.id
JOIN ticket nn ON nn.id = n.ticket_id
WHERE tt.tn = '$ticket_number'
ORDER BY t.embedding <-> n.embedding
LIMIT $nb_tickets;
EOF
