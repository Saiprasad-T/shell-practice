#!/bin/bash

if [ $(id -u) -ne 0 ]; then
 echo "you are not a root user"
 exit 1
else
 echo "you are root user starting the installing"
fi

dnf install nginx -y