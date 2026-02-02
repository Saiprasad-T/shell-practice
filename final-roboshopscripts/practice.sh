#!/bin/bash

CONFIG_FILE="/etc/mongod.conf"
SEARCH_PATTERN="bindIp: 127.0.0.1"
REPLACEMENT="bindIp: 0.0.0.0"

grep -qF "$REPLACEMENT" "$CONFIG_FILE"
if [ $? -ne 0 ]; then
    sed -i "s|$SEARCH_PATTERN|$REPLACEMENT|" "$CONFIG_FILE"
    echo "mongod.conf updated"
else
    echo "mongod.conf already correct"
fi