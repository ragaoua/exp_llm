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
    -q|--prompt)
      if [ ! -z "$ticket_number" ] ; then
        echo "Only one of two options expected : -q|--prompt or -t|--ticket" >&2
        exit 1
      fi
      prompt="$2"
      shift
      shift
      ;;
    -t|--ticket)
      if [ ! -z "$prompt" ] ; then
        echo "Only one of two options expected : -q|--prompt or -t|--ticket" >&2
        exit 1
      fi
      ticket_number="$2"
      shift
      shift
      ;;
    -*|--*)
      echo "Unknown option $1" >&2
      exit 2
      ;;
    *)
      echo "No positional argument expected" >&2
      exit 3
      ;;
  esac
done

if [ -z "$prompt" ] && [ -z "$ticket_number" ] ; then
  echo "One of two options expected : -q|--prompt or -t|--ticket" >&2
  exit 4
fi
readonly ticket_number prompt nb_tickets print_ticket consider_full_ticket

readonly db="otrs"
readonly role="postgres"
readonly psql="psql -h localhost -U "$role" -d "$db" --tuples-only --no-align"

if [ ! -z "$prompt" ] ; then
  ${psql[@]} --set prompt="$prompt" <<EOF
  SET search_path=aide,public;
  
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
else
  ${psql[@]} <<EOF
  SET search_path=aide,public;

  SELECT t2.id, t2.tn $("$print_ticket" && echo ", t2c.conversation")
  FROM ticket t1
  JOIN ticket_embeddings t1e ON t1e.ticket_id = t1.id
  JOIN ticket t2 ON t2.id <> t1.id
  JOIN ticket_embeddings t2e ON t2e.ticket_id = t2.id
  JOIN ticket_conversations t2c ON t2c.id = t2e.ticket_id
  WHERE t1.tn = '$ticket_number'
  $(
  if "$consider_full_ticket" ; then
    echo "ORDER BY t1e.conversation_embedding <-> t2e.conversation_embedding"
  else
    echo "ORDER BY t1e.first_article_embedding <-> t2e.first_article_embedding"
  fi
  )
  LIMIT $nb_tickets;
EOF
fi

