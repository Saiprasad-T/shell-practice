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
    VALIDATE $? "CREATING SYSTEM USER"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGS_FILE
VALIDATE $? "IF THERE ARE IS NO /APP IT WILL CREATE NEW DIRECTORY /APP"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip  &>>$LOGS_FILE
VALIDATE $? "DOWNLOADING USER CODE"
 
cd /app &>>$LOGS_FILE
VALIDATE $? "MOVING TO /APP DIRECTORY"

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "REMOVING EXISTING CODE"

unzip /tmp/cart.zip &>>$LOGS_FILE
VALIDATE $? "MOVING TO /APP"

npm install | tee -a $LOGS_FILE
VALIDATE $? "INSTALLING DEPENDENCIES"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service &>>$LOGS_FILE
VALIDATE $? "UPDATING .SERVICE FILE"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "RELOADING THE DAEMON"

systemctl enable cart  &>>$LOGS_FILE
VALIDATE $? "ENABLING THE CART"

systemctl start cart &>>$LOGS_FILE
VALIDATE $? "STARTING THE CART"
