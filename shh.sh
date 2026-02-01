#!/bin/bash

ami-id="$ami-0220d79f3f480ecf5"
sg-id="$sg-0f34bb41316585429"
instance_type="$t3.micro"

for instance in $@
do 
    aws ec2 run-instances \
    --image-id $ami-id \
    --instance-type $instance_type \
    --security-group-ids $sg-id \
    --query 'Instances[0].PrivateIpAddress' \
    --output text
done
