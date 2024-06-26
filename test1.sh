#!/bin/bash

region="us-east-2"

vpc_cidr="10.0.0.0/16"

subnet1_id="10.0.1.0/24"

subnet2_id="10.0.2.0/24"

subnet3_id="10.0.3.0/24"

image_id="ami-07d7e3e669718ab45"

vpc_id=$(aws ec2 create-vpc --cidr-block $vpc_cidr --region $region --query Vpc.VpcId --output text)

subnet1_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet1_id --region $region --availability-zone ${region}a --query Subnet.SubnetId --output text)

subnet2_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet2_id --region $region --availability-zone ${region}b --query Subnet.SubnetId --output text)

subnet3_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet3_id --region $region --availability-zone ${region}c --query Subnet.SubnetId --output text)

igw_id=$(aws ec2 create-internet-gateway --region $region --query InternetGateway.InternetGatewayId --output text)

aws ec2 attach-internet-gateway --vpc-id $vpc_id --region $region --internet-gateway-id $igw_id

rt_id=$(aws ec2 create-route-table --vpc-id $vpc_id --region $region --query RouteTable.RouteTableId --output text)

aws ec2 create-route --route-table-id $rt_id --destination-cidr-block 0.0.0.0/0 --gateway-id $igw_id --region $region
aws ec2 associate-route-table --subnet-id $subnet1_id --route-table-id $rt_id --region $region
aws ec2 associate-route-table --subnet-id $subnet2_id --route-table-id $rt_id --region $region
aws ec2 associate-route-table --subnet-id $subnet3_id --route-table-id $rt_id --region $region

sg_id=$(aws ec2 create-security-group --group-name EC2SecurityGroup --description "Demo Security Group" --region $region --vpc-id $vpc_id  --query GroupId --output text)

aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $region

aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $region

aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 443 --cidr 0.0.0.0/0 --region $region

aws ec2 run-instances --image-id $image_id --instance-type t2.micro --key-name Proceed without key pair --security-group-ids $sg_id --subnet-id ("$subnet1_id" "$subnet2_id" "$subnet3_id") --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ec2-group-4}]' 


