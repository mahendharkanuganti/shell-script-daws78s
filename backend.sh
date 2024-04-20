#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "Enter the DB Passoword:"
read db_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2....$R FAILURE $N"
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
    echo -e "$G you're already super user $N"
fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default Nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs:20 Version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing Nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating Expense user"
else
    echo "Expense user was already created..$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading the backend code"

cd /app &>>$LOGFILE
VALIDATE $? "changing to /app directory"

rm -rf /app/* &>>$LOGFILE
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracting the code"

npm install &>>$LOGFILE
VALIDATE $? "Installing the nodejs dependencies"

cp /home/ec2-user/shell-script-daws78s/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copying the backend service file to ec2 instance"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Realoading Daemon"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting backend service"

systemctl enable backend &>>LOGFILE
VALIDATE $? "Enabling Backend service"

dnf install mysql -y &>>LOGFILE
VALIDATE $? "Installing Mysql Client"

mysql -h db.mahidevops.cloud -uroot -p${db_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Loading the schema"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting backend service"
