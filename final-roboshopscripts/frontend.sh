#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "$R PLEASE RUN THIS SCRIPT WITH ROOT USER ACCESS $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$G $2  SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable nginx -y &>>$LOGS_FILE
VALIDATE $? "MODULE DISABLED"

dnf module enable nginx:1.24 -y &>>$LOGS_FILE
VALIDATE $? "MODULE ENABLED"

installing () {
    dnf list installed nginx &>/dev/null
    if [ $? -ne 0 ]; then
      dnf install nginx -y &>>$LOGS_FILE
      VALIDATE $? "INSTALLING NGINX"
    else
      echo -e "$G NGINX  ALREADY INSTALLED $N" | tee -a $LOGS_FILE
    fi
} 
installing

systemctl enable nginx &>>$LOGS_FILE
VALIDATE $? "ENABLING NGINX IS"

systemctl start nginx &>>$LOGS_FILE
VALIDATE $? "STARTING NGINX IS"

rm -rf /usr/share/nginx/html/*  &>>$LOGS_FILE
VALIDATE $? "REMOVING HTML SCRIPTS"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "DOWNLOADING IT FROM S3"

cd /usr/share/nginx/html  &>>$LOGS_FILE

rm -rf /usr/share/nginx/html/*  &>>$LOGS_FILE
VALIDATE $? "REMOVING HTML SCRIPTS"

unzip /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "UNZIPPING INTO /USR/SHARE/NGINX/HTML"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "CONFIGURING NGINX.CONF FILE"

systemctl restart nginx &>>$LOGS_FILE
VALIDATE $? "RESTARTING NGINX"