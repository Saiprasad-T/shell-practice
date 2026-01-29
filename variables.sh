#!/bin/bash

read -p "enter a number:" num

if [ $num -gt 10 ]; then
 echo "$num is greater than 10"
else 
 echo "$num is smaller than 10"
fi