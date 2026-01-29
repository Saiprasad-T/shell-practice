#!/bin/bash

if [ $(id -u) -ne 0 ]; then
 echo "not a root user"
 exit 1
else
 echo "welcome root"