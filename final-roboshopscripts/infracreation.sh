#!/bin/bash

ami_id="ami-0220d79f3f480ecf5"
sg_id="sg-0f34bb41316585429"
instance_type="t3.micro"
ZONE_ID="Z054884433KSB5YRIKHVR"
DOMAIN_NAME="devopswiththota.online"

read -p "Enter instances names with separated spaces between them: " INSTANCES
for instance in $INSTANCES  #using for loop to create instances and storing intance_id in INSTANCE_ID varibale
do 
   INSTANCE_ID=$( aws ec2 run-instances \
    --image-id $ami_id \
    --instance-type $instance_type \
    --security-group-ids $sg_id \
    --query 'Instances[0].InstanceId' \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --output text )

    if [ "$instance" == "frontend" ]; then # with the help of instance_id, searching for public ip with aws command
       IP=$(
        aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[].Instances[].PublicIpAddress' \
        --output text
       )
       RECORD_NAME="$DOMAIN_NAME" #dns name will be devopswiththota.online
    else
        IP=$(
        aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[].Instances[].PrivateIpAddress' \
        --output text
        )
        RECORD_NAME="$instance.$DOMAIN_NAME" #dns name will be mongodb.devopswiththota.online
    fi
    echo "ip_adress: $IP" 

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Updating record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
    }
    '
   echo "record updated for $instance"
done
