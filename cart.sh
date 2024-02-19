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

useradd roboshop

VALIDATE $? "Adding roboshop user"

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "Downloading cart.zip"

unzip -o /tmp/cart.zip -d /app &>> $LOGFILE

VALIDATE $? "Unzipping cart.zip in /app dir"

npm install --prefix /app &>> $LOGFILE

VALIDATE $? "Installing dependencies"

test -f /etc/systemd/system/cart.service &>> $LOGFILE

if [ $? -ne 0 ]
then
    cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
    VALIDATE $? "Copying the cart.service"
else
    echo -e "Cart service file already exists ....$Y SKIPPING $N"
fi

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon reload"

systemctl enable cart &>> $LOGFILE

VALIDATE $? "Enabling cart service"

systemctl start cart &>> $LOGFILE

VALIDATE $? "Starting cart service"