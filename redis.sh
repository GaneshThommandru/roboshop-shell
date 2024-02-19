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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

VALIDATE $? "Downloading Redis Remi Repo"

dnf module enable redis:remi-6.2 -y

VALIDATE $? "Enable Redis Remi 6.2 module"

dnf install redis -y

VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf

VALIDATE $? "Allowing remote users access"

systemctl enable redis

VALIDATE $? "Enabling Redis service"

systemctl start redis

VALIDATE $? "Starting Redis service"