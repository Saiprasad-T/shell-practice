#!/bin/bash

userid=$(id -u)
logs_folder="/var/log/shellscripts/"
logs_file="/var/log/shellscripts/$0.log"

if [ $userid -ne 0 ]; then
 echo"you are not a root user"
 exit 1
fi


VALIDATE(){
if [ $1 -ne 0 ]; then
 echo "$2 .....Failure"
 exit 1
else
 echo "$2....Sucess"
fi
}

for package in $@
do 
dnf install $package -y &>> $logs_file
VALIDATE $? "$pacakage installation"
done