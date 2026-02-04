#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysqld.devopswiththota.online

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

installing () {
    dnf list installed maven &>/dev/null
    if [ $? -ne 0 ]; then
      dnf install maven -y &>>$LOGS_FILE
      VALIDATE $? "INSTALLING MAVEN"
    else
      echo -e "$G MAVEN  ALREADY INSTALLED $N" | tee -a $LOGS_FILE
    fi
} 
installing

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "CREATING SYSTEM USER"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGS_FILE
VALIDATE $? "CREATING /APP DIRECTORY"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOGS_FILE
VALIDATE $? "DOWNLOADING IT FROM S3"

cd /app &>>$LOGS_FILE
VALIDATE $? "MOVING /APP DIRECTORY"

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "DELETING PREVIOS CODE FROM /APP FOLDER"

unzip /tmp/shipping.zip &>>$LOGS_FILE
VALIDATE $? "UNZIPPING INTO /APP FOLDER"

mvn clean package &>>$LOGS_FILE
VALIDATE $? "INSTALLING DEPENDENCIES"

mv target/shipping-1.0.jar shipping.jar &>>$LOGS_FILE
VALIDATE $? "MOVING 1.0 JAR to .JAR"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOGS_FILE
VALIDATE $? "COPYING .SERVICE FILE INTO SYSTEMD SERVICES"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "RELOADING DAEMON"

systemctl enable shipping &>>$LOGS_FILE
VALIDATE $? "ENABLING SHIPPING"

systemctl start shipping &>>$LOGS_FILE
VALIDATE $? "STARTING SHIPPING"

dnf install mysql -y &>>$LOGS_FILE

installing_my_sql () {
    dnf list installed mysql &>/dev/null
    if [ $? -ne 0 ]; then
      dnf install mysql  -y &>>$LOGS_FILE
      VALIDATE $? "INSTALLING MYSQL"
    else
      echo -e "$G MYSQL  ALREADY INSTALLED $N" | tee -a $LOGS_FILE
    fi
} 
installing_my_sql

MYSQL_HOST="mysqld.devopswiththota.online"

# Check if database exists
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then

    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOGS_FILE
    VALIDATE $? "Loaded data into MySQL"
else
    echo -e "data is already loaded ... $Y SKIPPING $N"
fi


systemctl restart shipping &>>$LOGS_FILE
VALIDATE $? "RESTARTING SHIPPING"

