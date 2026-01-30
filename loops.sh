#!/bin/bash

user_id=$(id -u)
#creating logs folder and logs file to store the logs
logs_folder="/var/log/shell-scripts/"
logs_file="/var/log/shell-scripts/$0.log"

exec &> >(tee -a "$logs_file")

if [ $user_id -ne 0 ]; then 
 echo "please run it as root user..." 
 exit 1
fi

mkdir -p $logs_folder

#written a function as this requried for everystep
verification () {    
if [ $1 -eq 0 ]; then
 echo "$2 installation is success" 
else
 echo "$2 not installed" 
fi

for pacakage in $@
do
 dnf install $pacakage -y
 verification $? $pacakage
done
