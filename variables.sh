#!/bin/bash

read -p "enter the env where you want to push the files:" stage

if [ $stage==prod ]; then
 echo "be carefull as this the production"
else
 echo "safe to proceed"
fi