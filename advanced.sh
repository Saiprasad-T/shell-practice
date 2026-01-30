#!/bin/bash

echo "plese provide the number"
read number

if [[ $number -le 10 ]]; then
 echo "number is to small...."
elif [[ $number -ge 10 && $number -le 50]]; then
 echo "good number....."
else
 echo "too big number...."
fi

