#!/bin/bash

set -e;

FILE=tmp/pids/server.pid
if [ -f "$FILE" ]; then
    echo "Removing tmp/pids/server.pid"
    rm tmp/pids/server.pid || true
fi

if [ "$1" ] && [ "$1" == "-d" ]; then
    echo "Launching docker-compose up --build -d"
    docker-compose up --build -d
else
    echo "Launching docker-compose up --build"
    docker-compose up --build
fi
