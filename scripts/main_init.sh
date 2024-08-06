#!/bin/bash

set -e

sudo dnf update -y

sudo dnf -y install git vim mariadb105

SSM_AGENT_URL="https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm"
sudo dnf -y install "$SSM_AGENT_URL"

sudo systemctl enable amazon-ssm-agent --now