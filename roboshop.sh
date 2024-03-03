#!/bin/bash

AMI=ami-0f3c7d07486cad139
SG_ID=sg-0e3316d7c9d69c2ad
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")

ZONE_ID=Z10454783E1JILBVMFMWM
DOMAIN_NAME="ganeshthommandru.online"

PUBLIC_IP=$(aws ec2 describe-network-interfaces --query NetworkInterfaces[*].[Attachment.[InstanceId],Association.[PublicIp]] --output=json --output text | grep -v 'i-*')


for i in ${INSTANCES[@]};
do 
    echo "instance is : $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCES_TYPE="t3.small"
    else
        INSTANCES_TYPE="t2.micro"
    fi
    
    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --instance-type $INSTANCES_TYPE --security-group-ids sg-0e3316d7c9d69c2ad --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    #"$(aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --instance-type $INSTANCES_TYPE --security-group-ids sg-0e3316d7c9d69c2ad --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]")"
    echo "$i: $IP_ADDRESS"
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Testing creating a record set"
        ,"Changes": [{
        "Action"              : "CREATE"
        ,"ResourceRecordSet"  : {
            '
            if [ $i == "web" ]
            then
                "Name"              : "'$DOMAIN_NAME'"
            else
                "Name"              : "'$i'.'$DOMAIN_NAME'"
            fi
            '
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "'
                if [ $i == "web" ]
                then
                    "Value"         : "'$(aws ec2 describe-network-interfaces --query NetworkInterfaces[*].[Attachment.[InstanceId],Association.[PublicIp]] --output=json --output text | grep -v 'i-*')'"
                else
                    "Value"         : "'$IP_ADDRESS'"
                fi
                '"
            }]
        }
        }]
    }
    '
done
