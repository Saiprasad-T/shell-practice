#!/bin/bash

user_id=$(id -u)

if [[ $user_id -ne o ]]; then
 echo "please run with root user...."
 exit 1
fi

dnf install nginx -y

if [[ $? -ne 0 ]]; then
 echo "installation is succesfull"
 exit 1
else
 echo "not installed...."
fi