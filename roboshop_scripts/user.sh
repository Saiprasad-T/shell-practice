#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$pwd
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable nodejs -y
VALIDATE $? "disabling module"

dnf module enable nodejs:20 -y
VALIDATE $? "enabling module"

dnf install nodejs -y
VALIDATE $? "installing nodejs is"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "moving to /app"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
cd /app 
unzip /tmp/user.zip
VALIDATE $? "unzipping"

npm install
VALIDATE $? "installing dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>>$LOGS_FILE
VALIDATE $? "configuring systemd"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "reloading"

systemctl enable user &>>$LOGS_FILE
VALIDATE $? "enabling user"

systemctl start user &>>$LOGS_FILE
VALIDATE $? "starting user app"