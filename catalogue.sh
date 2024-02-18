#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#Validate funtion
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .....$R FAILED $N"
        exit 1
    else
        echo -e "$2 .....$G SUCCESS $N"
    fi
}

#Validate root user access
if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run as a root user $N"
    exit 1
else
    echo "You are root user"
fi

#Validate already installed nodejs version
#dnf list installed nodejs &>> $LOGFILE
#if [ $? -ne 0 ]
#then
#    echo -e "$R ERROR:: No nodejs version is available $N"
#    exit 1
#else
#    dnf module disable nodejs -y &>> $LOGFILE
#    VALIDATE $? "Disable existing nodejs module"
#fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disable existing nodejs module"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enablement of nodejs version-18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installation of nodejs version-18"

id roboshop

if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Adding roboshop user"
else
    echo -e "roboshop user already created.....$Y SKIPPING $N"
fi

test -d /app &>> $LOGFILE

if [ $? -ne 0 ]
then
    mkdir /app &>> $LOGFILE
    VALIDATE $? "Create an app directory as /app"
else
    echo -e "/app directory already created.....$Y SKIPPING $N"
fi

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloading catalogue.zip to /tmp directory"

unzip /tmp/catalogue.zip -d /app &>> $LOGFILE

VALIDATE $? "Unzipping catalogue.zip file in /app directory"

npm install &>> $LOGFILE

VALIDATE $? "Installing Dependencies"

test -f /etc/systemd/system/catalogue.service &>> $LOGFILE

if [ $? -ne 0 ]
then
    cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
    VALIDATE $? "Copying "
else
    echo -e "Catalogue.service file is already created .....$Y SKIPPING $N"
fi

sed -i 's/<MONGODB-SERVER-IPADDRESS>/mongodb.ganeshthommandru.online/g' /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "Updating MongoDB IP in catalogue.service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Running Daemon-reload command"

systemctl enable catalogue.service &>> $LOGFILE

VALIDATE $? "Enabling Catalogue Service"

systemctl start catalogue.service &>> $LOGFILE

VALIDATE $? "Start Catalogue Service"

test -f /etc/yum.repos.d/mongo.repo &>> $LOGFILE

if [ $? -ne 0 ]
then
    cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
    VALIDATE $? "Copying mongo.repo to repos directory"
else
    echo "Mongo.repo file exists already in repos directory.....$Y SKIPPING $N"
fi

dnf list installed mongodb-org-shell &>> $LOGFILE

if [ $? -ne 0 ]
then
    dnf install mongodb-org-shell -y &>> $LOGFILE
    VALIDATE $? "Installing MongoDB Client"
else
    echo "MongoDB Client is already installed.....$Y SKIPPING $N"
fi

mongo --host mongodb.ganeshthommandru.online < /app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading Catalogue Items"

systemctl restart catalogue &>> $LOGFILE

VALIDATE $? "Restarting Catalogue Service"