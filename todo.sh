#!/bin/bash

filename="todo.txt"

if [ $# -eq 0 ]; then
  ./todo.sh add
fi

case "$1" in
  help)
    echo "Usage: $0 <command>"
    echo "Commands:"
    echo "  add"
    echo "  show"
    echo "  edit"
    echo "  summary"
    echo "  help"
    ;;
  add)
    DATE=$(date +%Y-%m-%d)

    echo "Status: todo" > /tmp/todo.txt
    echo "Created: $DATE" >> /tmp/todo.txt
    echo "Name: " >> /tmp/todo.txt

    $EDITOR /tmp/todo.txt

    if [ -s /tmp/todo.txt ]; then
      sed 's/.\+: //g' < /tmp/todo.txt | \
        tr '\n' '\t' | \
        sed 's/\t$/\n/g' >> $filename
              echo "Added to $filename"
            else
              echo "No changes made"
    fi
    ;;
  show)
    cat $filename
    ;;
  edit)
    $EDITOR $filename
    ;;
  summary)
    echo "Summary"
    echo "-------"
    echo "Total: $(wc -l < $filename)"
    echo "Completed: $(grep -c "Status: done" $filename)"
    echo "Pending: $(grep -c "Status: todo" $filename)"
    ;;
  *)
    echo "Invalid command"
    exit 1
    ;;
esac
