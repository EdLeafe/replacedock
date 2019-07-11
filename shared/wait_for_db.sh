#!/bin/sh
# wait-for-neo.sh

sleep 1

# This will return a non-zero value unless the port is accepting connections,
# which means that neo4j is running.
while ! nc -z neo4j 7687;
do
  echo waiting for the database to be ready;
  sleep 1;
done;
echo Connected!;
