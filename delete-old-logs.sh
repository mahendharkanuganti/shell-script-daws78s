#!/bin/bash

#This script will delete the files which has extension .log and are more than 14 days old in the /tmp/app-logs directory.

SOURCE_DIRECTORY=/tmp/app-logs

if [ -d $SOURCE_DIRECTORY ]
then
    echo "Source directory $SOURCE_DIRECTORY exists"
else
    echo "Source Directory $SOURCE_DIRECTORY doesn't exists"
fi

FILES=$(find $SOURCE_DIRECTORY -name "*.log" -mtime +14)

while IFS= read -r line
do
    echo "Deleting $line"
    rm -rf $line
done <<< $FILES