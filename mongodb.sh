#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 $R .....FAILED $N"
        exit 1
    else
        echo -e "$2 $G .....SUCCESS $N"
    fi
}

echo "Script started execution at $TIMESTAMP" &>> $LOGFILE

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run as a root user $N"
    exit 1
else
    echo -e "$G You are a root user $N"
fi

# Use Absolute path
cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copying MongoDB Repo"

dnf list installed mongodb-org

if [ $? -ne 0 ]
then
    dnf install mongodb-org -y &>> $LOGFILE
    VALIDATE $? "MongoDB Installation"
else
    echo -e "Already Installed......$Y SKIPPING $N"
fi

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "Enabling Mongo DB Service"

systemctl start mongod

VALIDATE $? "Starting Mongo DB Service"

