#!/bin/bash

user_id=$(id -u)

if [[ $user_id -ne o ]]; then
 echo "please run with root user...."
 exit 1
fi

validate(){
if [[ $1 -ne 0 ]]; then
 echo "$2 installation is succesfull"
 exit 1
else
 echo "$2 not installed...."
fi
}

dnf install nginx252 -y
validate $? "nginx"