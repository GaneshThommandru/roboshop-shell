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

dnf install maven -y &>> $LOGFILE

VALIDATE $? "Installing Maven"

id roboshop

if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Creating roboshop user"
else
    echo -e "User already exists..... $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating /app directory"

test -f /tmp/shipping.zip &>> $LOGFILE

if [ $? -ne 0 ]
then
    curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
    VALIDATE $? "Downloading Shipping.zip file"
else
    echo -e "Shipping.zip file downloaded already.... $Y SKIPPING $N"
fi

unzip -o /tmp/shipping.zip -d /app &>> $LOGFILE

VALIDATE $? "Unzipping shipping.zip file"

mvn -f /app clean package &>> $LOGFILE

VALIDATE $? "Installing Dependencies"

mv /app/target/shiping-1.0.jar /app/target/shipping.jar &>> $LOGFILE

VALIDATE $? "Renaming shipping.jar file"

test -f /etc/systemd/system/shipping.service &>> $LOGFILE

if [ $? -ne 0 ]
then
    cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
    VALIDATE $? "Copying Shipping service"
else
    echo -e "Shipping service file already copied....$Y SKIPPING $N"
fi

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Deamon Reload"

systemctl enable shipping.service &>> $LOGFILE

VALIDATE $? "Enabling Shipping Service"

systemctl start shipping.service &>> $LOGFILE

VALIDATE $? "Starting Shipping Service"

dnf install mysql -y &>> $LOGFILE

VALIDATE $? "Installing MySQL client"

mysql -h mysql.ganeshthommandru.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "Loading Schema Data"

systemctl restart shipping.service &>> $LOGFILE

VALIDATE $? "Restarting shipping service"