#!/bin/bash

set -e

user_id=$(id -u)
#creating logs folder and logs file to store the logs
logs_folder="/var/log/shell-scripts/"
logs_file="/var/log/shell-scripts/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

exec &> >(tee -a "$logs_file")

if [ $user_id -ne 0 ]; then 
 echo -e " $R please run it as root user...$N" 
 exit 1
fi

mkdir -p $logs_folder

#written a function as this requried for everystep
verification () {    
if [ $1 -eq 0 ]; then
 echo -e "$G $2 installation is success $N" 
else
 echo -e "$R $2 not installed $N" 
fi
}

for pacakage in $@
do
    dnf list installed $pacakage
  if [ $? -ne 0 ]; then
     echo -e  "$R $pacakage not installed installing now $N"
     dnf install $pacakage -y
     verification $? $pacakage
  else 
     echo -e "$G $pacakage already installed $Y skipping now $N"
  fi
done