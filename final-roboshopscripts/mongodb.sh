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

setting_repo() {
    if [ ! -f /etc/yum.repos.d/mongo.repo ]; then
      cp $SCRIPT_DIR mongodb.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
      VALIDATE $? "setting up mongodb repo"
    else 
       echo "repo already created for mongo"
    fi
}

installing () {
    dnf list installed mongodb-org
    if [ $? -ne 0 ]; then
      dnf install mongodb-org -y &>>$LOGS_FILE
      VALIDATE $? "installing mongodb"
    else
      echo "mongodb-org has already installed"
    fi
}   

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "enabling mongod"

systemctl start mongod  &>>$LOGS_FILE
VALIDATE $? "starting mongod"

grep -q "127.0.0.1" /etc/mongod.conf
if [ $? ]
sed -i 's/127.0.0.1/0.0.0.0/g'  /etc/mongod.conf &>>$LOGS_FILE
VALIDATE $? "updating mongod.conf"

systemctl restart mongod &>>$LOGS_FILE
VALIDATE $? "restarting mongod"