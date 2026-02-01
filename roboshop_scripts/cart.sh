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

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "disabling module"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "enabling module"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "installing nodejs is"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "create if folder doesnot exist"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
VALIDATE $? "unzipping pacakages"

cd /app 
unzip /tmp/cart.zip
VALIDATE $? "unzipping from tmp"

npm install  &>>$LOGS_FILE
VALIDATE $? "downloading dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "configuring systemd"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "reload is"

systemctl enable cart  &>>$LOGS_FILE
VALIDATE $? "enabling cart"

systemctl start cart &>>$LOGS_FILE
VALIDATE $? "starting cart"