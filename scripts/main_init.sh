#!/bin/bash

set -e

sudo yum update -y

sudo yum install -y curl git vim nginx

SSM_AGENT_URL="https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm"
sudo yum install -y "$SSM_AGENT_URL"

sudo systemctl enable amazon-ssm-agent --now