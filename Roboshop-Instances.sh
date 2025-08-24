#!/bin/bash
AMI_ID="ami-09c813fb71547fc4f" #replace with your AMI-ID
SG_ID="sg-0faec7651c2f9d221"   #replace with your Security Group ID
INSTANCES=("MONGODB" "REDIS" "MYSQL" "RABBITMQ" "CATALOUGUE" "USER" "CART" "SHIPPING" "PAYMENT" "DISPATCH" "FRONTEND")
ZONE_ID="Z08590672HICOEP27BESX" #replace with your Zone ID
DOMAIN_NAME="dive2devops.com" #replace with yoyr domain
for instances in ${INSTANCES[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg-0faec7651c2f9d221 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query "Instance[0].InstanceId" --output text)
    if [ $instances != "FRONTEND" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
        RECORD_NAME="$instances.$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        RECORD_NAME="$DOMAIN_NAME"
    fi
    echo "$instances IP address: $IP"
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating or Updating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$RECORD_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP'"
            }]
        }
        }]
    }'
done