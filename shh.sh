#!/bin/bash

ami_id="ami-0220d79f3f480ecf5"
sg_id="sg-0f34bb41316585429"
instance_type="t3.micro"

for instance in $@
do 
   INSTANCE_ID=$( aws ec2 run-instances \
    --image-id $ami_id \
    --instance-type $instance_type \
    --security-group-ids $sg_id \
    --query 'Instances[0].InstanceId' \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --output text )

    if [ "$instance" == "frontend" ]; then
       IP=$(
        aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[].Instances[].PublicIpAddress' \
        --output text
       )
    else
        IP=$(
        aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[].Instances[].PrivateIpAddress' \
        --output text
        )
    fi
    echo "ip_adress: $IP"
done
