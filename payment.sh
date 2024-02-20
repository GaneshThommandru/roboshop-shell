#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$LOGFILE-$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ..... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ..... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "Please run as root user"
    exit 1
else
    echo -e "You are a root user"
fi

dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "Installing Python"

id roboshop &>> $LOGFILE

if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Creating roboshop user"
else
    echo -e "roboshop user already created..... $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating /app directory"

test -f /tmp/payment.zip &>> $LOGFILE

if [ $? -ne 0 ]
then
    curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
    VALIDATE $? "Downlading Payment.zip file"
else
    echo -e "Payment.zip already downloaded.... $Y SKIPPING $N"
fi

unzip -o /tmp/payment.zip -d /app &>> $LOGFILE

VALIDATE $? "Unzipping payment.zip"

pip3.6 install -t /app -r /app/requirements.txt &>> $LOGFILE

VALIDATE $? "Installing Dependencies"

test -f /etc/systemd/system/payment.service &>> $LOGFILE

if [ $? -ne 0 ]
then
    cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
    VALIDATE $? "Copying Payement.service file"
else
    echo -e "Payment.service file already exists..... $Y SKIPPING $N"
fi

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Deamon Reload"

systemctl enable payment &>> $LOGFILE

VALIDATE $? "Enabling Payment"

systemctl start payment &>> $LOGFILE

VALIDATE $? "Starting Payment"
