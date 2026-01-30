#!/bin/bash


read -p "please enter your marks:" marks

if [[ $marks -le 40 ]]; then
 echo "fail....."
elif [[ $marks -ge 40 && $marks -le 59 ]]; then
 echo "pass....."
elif [[ $marks -ge 60 && $marks -le 79 ]]; then
 echo "first class...."
elif [[ $marks -ge 80 && $marks -le 100 ]]; then
 echo "distinction...."
else 
 echo "invalid number"
fi