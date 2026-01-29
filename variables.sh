#!/bin/bash

userid=$(id -u)
if [ "$userid" -ne 0]; then
 echo "you are not a root user, please run this script with root user"
fi

VALIDATE(){
 if [ $1 -ne 0 ]; then
  echo "$2 .....failure"
else
 echo "$2 .....sucess"
} 

dnf install nginx -y
VALIDATE $? "nginx installation"

dnf install mysql-servert -y
VALIDATE $? "mysql-server installation"