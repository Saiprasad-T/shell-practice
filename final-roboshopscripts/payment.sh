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
installing (){
 dnf list installed python3 gcc python3-devel
 if [ $? -ne 0 ]; then
   dnf install python3 gcc python3-devel -y
   VALIDATE $? "INSTALLING PYTHON3 GCC PYTHON3-DEVEL"
else
   echo "$G PYTHON3 GCC PYTHON3-DEVEL ALREADY INSTALLED $N ..$Y SKIPPING FOR NOW $N"
fi
}
installing

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "CREATING /APP DIRECTORY"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "COPYING DATA FROM S3"

cd /app 
VALIDATE $? "CHANGING DIRECTORY INTO /APP"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/payment.zip
VALIDATE $? "UNZIPPING THE DATA FROM /TMP to ?APP"

pip3 install -r requirements.txt
VALIDATE $? "INSTALLING DEPENDENCIES"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "COPYING .SERVICE TO SYSTEMD"

systemctl daemon-reload
VALIDATE $? "RELOADING DAEMON"

systemctl enable payment 
VALIDATE $? "ENABLING PAYMENT"

systemctl start payment
VALIDATE $? "STARTING PAYMENT"