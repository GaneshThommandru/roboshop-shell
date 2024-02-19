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
        echo -e "$2 -----$G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo "$R ERROR:: Please run as a root user $N"
    exit 1
else
    echo "You are root user"
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling existing nodejs module"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling nodejs:18 module"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing nodejs" &>> $LOGFILE

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloading user.zip"

unzip -o /tmp/user.zip -d /app &>> $LOGFILE

VALIDATE $? "Unzipping user.zip in /app dir"

install npm --prefix /app &>> $LOGFILE

VALIDATE $? "Installing dependencies"

test -f /etc/systemd/system/user.service &>> $LOGFILE

if [ $? -ne 0 ]
then
    cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
    VALIDATE $? "Copying the user.service"
else
    echo -e "User service file already exists ....$Y SKIPPING $N"
fi

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon reload"

test -f /etc/yum.repos.d/mongo.repo &>> $LOGFILE
if [ $? -ne 0 ]
then
    cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
    VALIDATE $? "Copying Mongodb repo"
else
    echo -e "Mongodb repo already exists....$Y SKIPPING $N"
fi

mongo --host mongodb.ganeshthommandru.online < /app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading Users data"

systemctl restart user &>> $LOGFILE

VALIDATE $? "Restarting user service"