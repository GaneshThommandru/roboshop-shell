#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .....$R FAILED $N"
        exit 1
    else
        echo -e "$2 .....$G SUCCESS $N"
    fi
}

#Validate the root user access
if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run as a root user $N"
    exit 1
else
    echo -e "$G You are root user $N"
fi

#Check & Copy the Mongodb repo file to repos directory
test -f /etc/yum.repos.d/mongo.repo &>> $LOGFILE

if [ $? -ne 0 ]
then    
    cp /home/centos/shell-script/mongo.repo /etc/yum.repos.d/mongo.repo  &>> $LOGFILE
    VALIDATE $? "Copying MongoDB repo"
else
    echo -e "mongo.repo file already exists in repos directory .....$Y SKIPPING $N"
fi

#Validate whether the Mongo
yum list installed mongodb-org &>> $LOGFILE

if [ $? -ne 0 ]
then
    yum install mongodb-org -y &>> $LOGFILE
else
    echo -e "Already installed .....$Y SKIPPING $N"
fi

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "Enabling mongod"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "Starting mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

VALIDATE $? "Adding remote access to MongoDB"

systemctl restart mongod

VALIDATE $? "Restarting the mongod service"