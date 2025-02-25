#!/usr/bin/env bash

#if [ "$1" = "init" ]; then

 #   if [ -f "./tmp/minitwit.db" ]; then 
 #       echo "Database already exists."
 #       exit 1
 #   fi
 #   echo "Putting a database to ./tmp/minitwit.db..."
 #   ruby -r "./minitwit.rb" -e "init_db"
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
elif [ "$1" = "build" ]; then
    docker build . -t "test"
elif [ "$1" = "test" ]; then
    docker build -t testimage -f Dockerfile-tests .
    yes 2>/dev/null |  docker compose up -d
    docker exec -it minitwit bash -c "rspec"
else
  echo "I do not know this command..."
fi


