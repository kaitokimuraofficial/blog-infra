#!/bin/bash

sudo apt update
sudo apt install -y curl git vim

curl -LO https://go.dev/dl/go1.22.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz

mkdir $HOME/go

export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

source $HOME/.bashrc

go version
