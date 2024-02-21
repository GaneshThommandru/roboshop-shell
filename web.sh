#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE{
    if [ $1 -ne 0 ]
    then
        echo "$2 ..... $R FAILED $N"
        exit 1
    else
        echo "$2 ..... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: $N Please run as a root user"
    exit 1
else
    echo "You are root user"
fi

dnf install ngnix -y

VALIDATE $? "Installing ngnix"

systemctl enable ngnix

VALIDATE $? "Enabling ngnix"

systemctl start ngnix

VALIDATE $? "Starting ngnix"

rm -rf /usr/share/ngnix/html/*

VALIDATE $? "Removing default nginx html files"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip

VALIDATE $? "Downloading roboshop zip file"

unzip -o /tmp/web.zip -d /usr/share/ngnix/

VALIDATE $? "Extracting roboshop html files"

cp /home/centos/roboshop.conf /etc/ngnix/default.d/roboshop.conf

VALIDATE $? "Configuring Roboshop"

systemctl restart ngnix

VALIDATE $? "Restarting ngnix"