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

dnf module disable nodejs -y
VALIDATE $? "MODULE DISABLED"

dnf module enable nodejs:20 -y
VALIDATE $? "MODULE ENABLED"

installation () {
dnf list installed nodejs
if [ $? -ne 0 ]; then
   dnf install nodejs -y
   VALIDATE $? "INSTALLING NODEJS APLLICATION"
else
   echo "ALREADY INSTALLED"
fi
}
installation

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "IF THERE ARE IS NO /APP IT WILL CREATE NEW DIRECTORY /APP"

copy () {
    if [ ! -f "/tmp/catalogue.zip" ]; then
      curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
      VALIDATE $? "COPYING DATA FROM S3"
    else 
       echo "DATA ALREADY COPIED TO TMP" | tee -a $LOGS_FILE
    fi
}
 
cd /app 
VALIDATE $? "moving to /app"

UNZIPPING () {
    if [ ! -d "/app/catalogue" ]; then
       unzip /tmp/catalogue.zip -d /app &>>$LOGS_FILE
       VALIDATE $? "UNZIPPING DATA is"
    else
       echo "FILE ALREADY UNZIPPED IN /APP"
    fi
}

cd /app/catalogue
npm install
VALIDATE $? "installing dependencies" 

updating_config_file() {
    if [ ! -f /etc/systemd/system/catalogue.service ]; then
      cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGS_FILE
      VALIDATE $? "SETTING UP CATALOGUE.SERVICE"
    else 
       echo -e "$G CATALOGUE.SERVICE ALREADY EXISTS $N" | tee -a $LOGS_FILE
    fi
}

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "RELOADING" 

systemctl enable catalogue &>>$LOGS_FILE
VALIDATE $? "ENABLING"

systemctl start catalogue &>>$LOGS_FILE
VALIDATE $? "STARTING CATALOGUE"

setting_repo() {
    if [ ! -f /etc/yum.repos.d/mongo.repo ]; then
      cp $SCRIPT_DIR mongodb.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
      VALIDATE $? "SETTING UP MONGODB REPO"
    else 
       echo -e "$G MONGODB REPO ALREADY EXISTS $N" | tee -a $LOGS_FILE
    fi
}

setting_repo

dnf install mongodb-mongosh -y &>>$LOGS_FILE
VALIDATE $? "INSTALLING MONGODB-MONGOSH"

INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -eq -1 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js
    VALIDATE $? "Loading products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue &>>$LOGS_FILE
VALIDATE $? "Restarting catalogue"