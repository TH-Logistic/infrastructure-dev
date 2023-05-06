#!/bin/bash

sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo yum install -y git


# Setup the docker-compose
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo mv /usr/local/bin/docker-compose /bin/docker-compose

export REPOSITORY_USER=REPOSITORY_USER
export REPOSITORY_TOKEN=REPOSITORY_TOKEN
export REPOSITORY_NAME=REPOSITORY_NAME

cd $HOME
sudo mkdir data
cd data