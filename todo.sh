#!/bin/bash

filename="todo.txt"

if [ $# -eq 0 ]; then
  ./todo.sh add
fi

if [ "$1" = "help" ]; then
  echo "Usage: $0 <command>"
  echo "Commands:"
  echo "  add"
  echo "  show"
  echo "  edit"
  echo "  summary"
  echo "  help"
  exit 1
fi

case "$1" in
  add)
    DATE=$(date +%Y-%m-%d)

    echo "Status: todo
    Created: $DATE
    Name: " > /tmp/todo.txt

    $EDITOR /tmp/todo.txt

    if [ -s /tmp/todo.txt ]; then
      sed 's/.\+: //g' < /tmp/todo.txt | \
        tr '\n' '\t' | \
        sed 's/\t$/\n/g' >> $filename
              echo "Added to $filename"
            else
              echo "No changes made"
    fi

    exit 0
    ;;
  show)
    cat $filename
    exit 0
    ;;
  edit)
    $EDITOR $filename
    exit 0
    ;;
  summary)
    echo "Summary"
    echo "-------"
    echo "Total: $(wc -l < $filename)"
    echo "Completed: $(grep -c "Status: done" $filename)"
    echo "Pending: $(grep -c "Status: todo" $filename)"
    exit 0
    ;;
  *)
    echo "Invalid command"
    exit 1
    ;;
esac
