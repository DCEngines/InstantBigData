#!/bin/bash

#Constant
Image=bigdatalabs/workstation
ContainerRestartPolicy=always
SwarmManagerIp=10.196.0.2
Network=ibd
DatasetsVol=/root/datasets
UserHome=$1
ContainerName=$2
SshPort=$3
ip=10.196.0.1

if [ "$#" -ne 3 ]; then
	echo "Incorrect number of parameters"
	echo "Command: ./SetUpWorkstationConainer.sh <UserHomeLocation> <ContainerName> <SshPort>"
	exit 0
fi

docker version &> /dev/null
if [ $? -eq 0 ];
then
	echo "Docker Exists"
else
	#Install docker-ce=18.06.0~ce~3-0~ubuntu
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	sudo apt-get update
	sudo apt-get install -y docker-ce=18.06.0~ce~3-0~ubuntu
	echo "Docker Installed"
	#Docker swarm join
	IFS=$'\n'; arr=( $(docker -H tcp://$SwarmManagerIp:2375 swarm join-token worker) );eval ${arr[1]}
fi

#Docker Pull ubuntu:16.04 image
docker pull  $Image

sleep 5s
#Docker create container
docker run -itd --restart $ContainerRestartPolicy --name $ContainerName --network $Network -v $DatasetsVol:/root/Datasets -v $UserHome:/root/Workstation -p $SshPort:22 $Image

echo "Command to login into the container: ssh -p $SshPort root@$ip"
echo "Password is root@123"
