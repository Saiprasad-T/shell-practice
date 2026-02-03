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
    echo -e  "$R REMOVING EXISTING RABBITMQ.REPO $N"
    rm -f rabbitmq.repo &>>$LOGS_FILE
else
    echo -e "$Y NO EXISTING RABBITMQ.REPO, WILL CREATE NEW ONE $N"
fi

cp $SCRIPT_DIR/rabbitmq.repo //etc/yum.repos.d/rabbitmq.repo &>>$LOGS_FILE
VALIDATE $? "COPYING REPO"

installation () {
dnf list installed rabbitmq-server &>/dev/null
if [ $? -ne 0 ]; then
   dnf install rabbitmq-server -y &>>$LOGS_FILE
   VALIDATE $? "INSTALLING RABBITMQ-SERVER APLLICATION"
else
   echo  -e "$G RABBITMQ-SERVER ALREADY INSTALLED $N"
fi
}
installation

systemctl enable rabbitmq-server &>>$LOGS_FILE
VALIDATE $? "ENABLING SYSTEMCTL FOR RABBITMQ-SEVER"

systemctl start rabbitmq-server &>>$LOGS_FILE
VALIDATE $? "STARTING SYSTEMCTL RABBITMQ-SERVER"

rabbitmqctl list_users | grep -w roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>>$LOGS_FILE
    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>/dev/null
    VALIDATE $? "CREATING SYSTEM USER"
else
    echo -e "$G ROBOSHOP USER ALREADY EXIST $N ... $Y SKIPPING $N"
fi