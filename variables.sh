#!/bin/bash

read -p "enter a number:" number

if [ "$number" -lt 10 ]; then
 echo "number is to small"
 exit 1
else 
 echo "Good number"
fi

echo "deploying the application"