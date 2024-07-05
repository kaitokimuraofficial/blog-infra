#!/bin/bash

sudo yum update -y
sudo yum install -y curl git vim nginx
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent --now