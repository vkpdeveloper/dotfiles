#!/bin/sh

STATUS="running exited dead"

for stat in $STATUS; do
    output="$output $(docker ps -qf status="$stat" | wc -l) |"
done

echo "|$output"
