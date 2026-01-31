#!/bin/bash

set -e

trap 'echo"error occured at line $LINENO command $BASH_COMMAND"' ERR

echo "my name is devops"
echo "my name is linux"
echooo "my name is red hat"
echo "my name is shell"

dnf install nginxxx -y