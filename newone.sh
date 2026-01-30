#!/bin/bash

#checks for the user_id, if user is not super user it fails
user_id=$(id -u)
if [ $user_id -ne 0 ]; then
 echo "please run it as root user..."
 exit 1
fi
#written a function as this requried for everystep
verification () {
if [ $1 -eq 0 ]; then
 echo "$2 installation is success"
else
 echo "$2 not installed"
fi
}

#using dnf commanf for installing applications
dnf install nginx -y
verification $? "nginx"

dnf install mysql-server -y
verification $? "mysql-server"