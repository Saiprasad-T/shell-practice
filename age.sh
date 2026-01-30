#!/bin/bash


read -p "please enter your age:" age

if [[ $age -lt 18 ]]; then
 echo "you are a minor"
elif [[ $age -ge 18 && $age -le 60 ]]; then
 echo "you are adult...."
else
 echo "you are citizen"
fi