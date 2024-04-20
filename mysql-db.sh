#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "Enter the Password for Mysql-DB"
read -s db_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please execute the script with root user"
    exit 1
else
    echo -e "$G You're already Super user $N"
fi


dnf install mysql-server -y &>>LOGFILE
VALIDATE $? "installing mysql server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling mysqld service"

systemctl start mysqld &>>LOGFILE
VALIDATE $? "Starting mysqld service"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>LOGFILE
#VALIDATE $? "Setting the root password for mysql"

mysql -h db.daws78s.online -uroot -p${db_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${db_root_password} &>>LOGFILE
    VALIDATE $? "Setting the root password for mysql"
else
    echo -e "Mysql DB root password is already setup..&Y SKIPPING &N"
fi
