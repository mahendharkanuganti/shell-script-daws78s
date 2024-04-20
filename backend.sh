#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2.... FAILURE"
        exit 1
    else
        echo -e "$2... SUCCESS"
    fi
}

if [ $USERID -ne 0 ]
then   
    echo "Please run the script with root access"
    exit 1
else
    echo "you're already super user"
fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default Nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs:20 Version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing Nodejs"

useradd expense &>>$LOGFILE
VALIDATE $? "Creating Expense user"

mkdir /app &>>$LOGFILE
VALIDATE $? "Creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading the backend code"

cd /app &>>$LOGFILE
VALIDATE $? "chanding to /app directory"

unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracting the code"

npm install &>>$LOGFILE
VALIDATE $? "Installing the nodejs dependencies"

cp /d/devops-daws-78s/shell-script-daws78s/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copying the backend service file to ec2 instance"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Realoading Daemon"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting backend service"

systemctl enable backend &>>LOGFILE
VALIDATE $? "Enabling Backend service"

dnf install mysql -y &>>LOGFILE
VALIDATE $? "Installing Mysql Client"

mysql -h db.mahidevops.cloud -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Loading the schema"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting backend service"
