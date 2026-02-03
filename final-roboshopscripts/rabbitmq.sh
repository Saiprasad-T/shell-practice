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

cd /etc/yum.repos.d/
VALIDATE $? "MOVING TO YUM.REPOS.D DIRECTORY"

# Check if rabbitmq.repo exists
if [ -f "rabbitmq.repo" ]; then
    echo "Removing existing rabbitmq.repo"
    rm -f rabbitmq.repo
else
    echo "No existing rabbitmq.repo, will create new one"
fi

cp $SCRIPT_DIR/rabbitmq.repo //etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "COPYING REPO"

installation () {
dnf list installed rabbitmq-server
if [ $? -ne 0 ]; then
   dnf install rabbitmq-server -y
   VALIDATE $? "INSTALLING RABBITMQ-SERVER APLLICATION"
else
   echo "RABBITMQ-SERVER ALREADY INSTALLED"
fi
}
installation

systemctl enable rabbitmq-server
VALIDATE $? "ENABLING SYSTEMCTL FOR RABBITMQ-SEVER"

systemctl start rabbitmq-server
VALIDATE $? "STARTING SYSTEMCTL RABBITMQ-SERVER"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123
    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
    VALIDATE $? "CREATING SYSTEM USER"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi