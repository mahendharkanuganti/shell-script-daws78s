#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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
    echo "Please run the script with root access"
    exit 1
else
    echo -e "$G You're already super user $N"
fi

dnf install nginx -y &>>LOGFILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>LOGFILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>LOGFILE
VALIDATE $? "Starting Nginx service"

rm -rf /usr/share/nginx/html/* &>>LOGFILE

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>LOGFILE
VALIDATE $? "Downloading the code"

cd /usr/share/nginx/html 

unzip /tmp/frontend.zip &>>LOGFILE
VALIDATE $? "Extracting the code"

cp /home/ec2-user/shell-script-daws78s/expense.conf /etc/nginx/default.d/expense.conf &>>LOGFILE
VALIDATE $? "Copying the code"

systemctl restart nginx &>>LOGFILE
VALIDATE $? "Restarting the Nginx service"