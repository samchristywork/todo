#!/bin/bash

filename="todo.txt"

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
