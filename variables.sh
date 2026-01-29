#!/bin/bash

if [ $(id -u) -ne 0 ]; then
 echo "you are not a root user"
else
 echo "you are root user starting the installing"
fi

dnf intall nginx -y