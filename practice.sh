#!/bin/bash

echo "please enter the number"
read number

if [ $number -le 10 ]; then
 echo "number is too small"
fi

if [ $number -ge 10 ]; then
 echo "number is good"
fi

if [ $number -gt 50 ]; then
 echo "number is too big"
fi
