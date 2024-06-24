#!/bin/bash

region="us-east-1"
vpc_cidr="10.0.0.0/16"
subnet1_id="10.0.1.0/24"

vpc_id=$(aws ec2 create-vpc --cidr-block $vpc_cidr --region $region --query Vpc.VpcId --output text)

subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet1_id --region $region --query Subnet.SubnetId --output text)

igw_id=$(aws ec2 create-internet-gateway --region $region --query InternetGateway.InternetGatewayId --output text)

aws ec2 attach-internet-gateway --vpc-id $vpc_id --region $region --internet-gateway-id $igw_id

rt_id=$(aws ec2 create-route-table --vpc-id $vpc_id --region $region --query RouteTable.RouteTableId --output text)

aws ec2 create-route --route-table-id $rt_id --destination-cidr-block 0.0.0.0/0 --gateway-id $igw_id --region $region

aws ec2 associate-route-table --subnet-id $subnet_id --route-table-id $rt_id --region $region

sg_id=$(aws ec2 create-security-group --group-name EC2SecurityGroup --description "Demo Security Group" --region $region --vpc-id $vpc_id  --query GroupId --output text)

aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $region
