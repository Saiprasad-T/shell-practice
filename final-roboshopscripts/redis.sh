#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
#the below files are for updating .conf file
CONFIG_FILE="/etc/redis/redis.conf" 
SEARCH_PATTERN="bindIp: 127.0.0.1"
REPLACEMENT="bindIp: 0.0.0.0"

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

dnf module disable redis -y &>>$LOGS_FILE
VALIDATE $? "DISABLING DONE"

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "ENABLING DONE"

installing () {
    dnf list installed redis &>/dev/null
    if [ $? -ne 0 ]; then
      dnf install redis -y &>>$LOGS_FILE
      VALIDATE $? "INSTALLING REDIS"
    else
      echo -e "$G REDIS  ALREADY INSTALLED $N" | tee -a $LOGS_FILE
    fi
}   
installing

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$LOGS_FILE
VALIDATE $? "UPDATED TO 0.0.0.0"

sed -i 's/protected-mode yes/protected-mode no/'  /etc/redis/redis.conf &>>$LOGS_FILE
VALIDATE $? "UPDATED TO NO"

systemctl enable redis &>>$LOGS_FILE
VALIDATE $? "enabling redis"

systemctl start redis &>>$LOGS_FILE
VALIDATE $? "Starting redis is"
