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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash

VALIDATE $? "Downloading erlang repos for RabbitMQ"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash

VALIDATE $? "Downlaoding RabbitMQ repos"

dnf install rabbitmq-server -y

VALIDATE $? "Installing RabbitMQ Server"

systemctl enable rabbitmq-server

VALIDATE $? "Enabling RabbitMQ Server"

systemctl start rabbitmq-server

VALIDATE $? "Starting RabbitMQ Server"

rabbitmqctl authenticate_user roboshop roboshop123
if [ $? -ne 0 ]
then
    rabbitmqctl add_user roboshop roboshop123
    VALIDATE $? "Adding RabbitMQ User and password"

    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

    VALIDATE $? "Setting Permissions"
else 
    echo -e "User already created & configured permissions....$Y SKIPPING $N"
fi
