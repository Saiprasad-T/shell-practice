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

installation () {
dnf list installed mysql-server &>/dev/null
if [ $? -ne 0 ]; then
   dnf install mysql-server -y
   VALIDATE $? "INSTALLING MYSQLD APLLICATION"
else
   echo -e "$G ALREADY INSTALLED $N"
fi
}
installation

systemctl enable mysqld
VALIDATE $? "ENABLING MYSQLD"

systemctl start mysqld  
VALIDATE $? "STARTING MYSQLD"

mysql_secure_installation (){
mysql -u root -pRoboShop@1 -e "SELECT 1;" &>>$LOGS_FILE
if [ $? -ne 0 ]; then
   mysql_secure_installation --set-root-pass RoboShop@1
   VALIDATE $? "MYSQL_SECURE_INSTALLATION"
else 
   echo "ALREADY INSTALLED MYSQL_SECURE_INSTALLATION AND UPDATED ROOT PASSWORD"
fi
}

mysql_secure_installation