#!/bin/bash

#This script will display the file system and its usage which is more than threshold.

THRESHOLD=5
DISK_USAGE=$(df -hTP | grep -i xfs)

while IFS= read -r line
do
    USAGE=$(echo $line | awk -F " " '{print $6}' | cut -d "%" -f1)
    FILE_SYSTEM=$(echo $line | awk -F " " '{print $NF}')
    if [ $USAGE -gt $THRESHOLD ]
    then
        echo "The $FILE_SYSTEM usage is above $THRESHOLD, current usage is $USAGE"
    fi
done <<< $DISK_USAGE


#Steps:
#1. disaply all file systems
#2. show the usage in numbers without %, so that we can easily compare.
#3. sort out which is consuming and above threshold
#4. 