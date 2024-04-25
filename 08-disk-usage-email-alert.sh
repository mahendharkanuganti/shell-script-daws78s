#!/bin/bash

#This script will display the file system and its usage which is more than threshold.
#Steps:
#1. disaply all file systems
#2. show the usage in numbers without %, so that we can easily compare.
#3. sort out which is consuming and above threshold

THRESHOLD=5
DISK_USAGE=$(df -hTP | grep -i xfs)
MESSAGE=""

while IFS= read -r line
do
    USAGE=$(echo $line | awk -F " " '{print $6}' | cut -d "%" -f1)
    FILE_SYSTEM=$(echo $line | awk -F " " '{print $NF}')
    if [ $USAGE -gt $THRESHOLD ]
    then
        MESSAGE="The $FILE_SYSTEM usage is above $THRESHOLD, current usage is $USAGE"
    fi
done <<< $DISK_USAGE




#Commands explanation:
# awk -F " " '{print $6}'  --> -F - is field separator, $6 is the 6th column from the output.
# $NF - nth column or the last column
# cut -d "%" -f1  --> -d is delimeter, We are removing the % from the output from the field 1.
# example if output is 32%, then after cut command it is just 32 only.
# IFS = Internal Field Separator
# -r: Prevents backslash escapes from being interpreted. Useful when reading file paths or lines that may contain backslashes.
# line: The variable where the read line is stored.
# done <<< $DISK_USAGE    --> The command output of variable $disk_usage will be injected to while loop as an input.