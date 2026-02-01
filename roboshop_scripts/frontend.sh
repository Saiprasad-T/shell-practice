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

dnf module disable nginx -y &>>$LOGS_FILE
VALIDATE $? "nginx disable is"

dnf module enable nginx:1.24 -y &>>$LOGS_FILE
VALIDATE $? "ngnix version enabled 1.24"

dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "nginx installed"

systemctl enable nginx  &>>$LOGS_FILE
VALIDATE $? "enabling nginx is"

systemctl start nginx  &>>$LOGS_FILE
VALIDATE $? "starting nginx is"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "removed all the html files"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "copying files from s3"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "unzip completed"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "copying nginx.conf is" &>>$LOGS_FILE

systemctl restart nginx &>>$LOGS_FILE
VALIDATE $? "starting nginx"