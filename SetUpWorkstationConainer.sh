#!/bin/bash

#Constant
Image=bigdatalabs/workstation
#ContainerIp=10.0.7.49
#SshPort=35353
ContainerRestartPolicy=always
SwarmManagerIp=54.39.16.42
Network=ibd
DatasetsVol=/root/datasets
UserHome=$1
ContainerIp=$2
SshPort=$3
ip=172.26.201.1
# Remove Docker if exists
sudo apt-get purge -y docker-ce;sudo rm -rf /var/lib/docker

#Install docker-ce=18.06.0~ce~3-0~ubuntu
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update

sudo apt-get install -y docker-ce=18.06.0~ce~3-0~ubuntu

#Docker Pull ubuntu:16.04 image
docker pull  $Image

#Docker swarm join
IFS=$'\n'; arr=( $(docker -H tcp://$SwarmManagerIp:2375 swarm join-token worker) );eval ${arr[1]}

sleep 5s
#Docker create container
docker run -itd --restart $ContainerRestartPolicy --name workstation --network $Network --ip $ContainerIp -v $DatasetsVol:/root/Datasets -v $UserHome:/root/Workstation -p $SshPort:22 $Image

echo "Command to login into the container: ssh -p $SshPort root@$ip"
echo "Password is root@123"
