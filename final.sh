#!/bin/bash

set -e
trap 'echo"error has occured at lin $LINE_NO and at command $BASH_COMMAND"' ERR


user_id=$(id -u)

#creating logs folder and logs file to store the logs

logs_folder="/var/log/shell-scripts/"
logs_file="/var/log/shell-scripts/$0.log"

# for colour code

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#keeps all the logs on to the screen and also stores in the folder 
exec &> >(tee -a "$logs_file")

#checks if the user is root or not

if [ $user_id -ne 0 ]; then 
 echo -e " $R please run it as root user...$N" 
 exit 1
fi

# checks whther the log folder has created or not
mkdir -p $logs_folder

#for loop used for checking if the app is already installed it show throw an error
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