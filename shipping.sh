#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$LOGFILE.log"
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

