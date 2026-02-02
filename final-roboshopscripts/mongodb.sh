#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
#the below files are for updating .conf file
CONFIG_FILE="/etc/mongod.conf" 
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

# pre requisite - please mongodb.repo while you are running script
setting_repo() {
    if [ ! -f /etc/yum.repos.d/mongo.repo ]; then
      cp $SCRIPT_DIR mongodb.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
      VALIDATE $? "SETTING UP MONGODB REPO"
    else 
       echo -e "$G MONGODB REPO ALREADY EXISTS $N" | tee -a $LOGS_FILE
    fi
}
setting_repo

installing () {
    dnf list installed mongodb-org &>/dev/null
    if [ $? -ne 0 ]; then
      dnf install mongodb-org -y &>>$LOGS_FILE
      VALIDATE $? "INSTALLING MONGODB"
    else
      echo -e "$G MONGODB  ALREADY INSTALLED $N" | tee -a $LOGS_FILE
    fi
}   
installing
systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "ENABLING MONGOD"

systemctl start mongod  &>>$LOGS_FILE
VALIDATE $? "STARTING MONGOD"

updating_config_file () {
   grep -qF "$REPLACEMENT" "$CONFIG_FILE"
    if [ $? -ne 0 ]; then
      sed -i "s|$SEARCH_PATTERN|$REPLACEMENT|" "$CONFIG_FILE" &>>$LOGS_FILE
      VALIDATE $? "MONGOD.CONF UPDATED"

      systemctl restart mongod &>>$LOGS_FILE #restarts only when gets updated
      VALIDATE $? "RESTARTING MONGOD"
    else
        echo -e "$G CONFIG  ALREADY UPDATED $N" | tee -a $LOGS_FILE
    fi
}
updating_config_file