#!/usr/bin/env bash

if [ "$1" = "start" ]; then
    echo "Starting minitwit..."
    nohup "$(which ruby)" minitwit.rb > ./tmp/out.log 2>&1 &
elif [ "$1" = "stop" ]; then
    echo "Stopping minitwit..."
    pkill -f minitwit
elif [ "$1" = "inspectdb" ]; then
    ./flag_tool -i | less
elif [ "$1" = "flag" ]; then
    ./flag_tool "${@:2}"
else
  echo "I do not know this command..."
fi


