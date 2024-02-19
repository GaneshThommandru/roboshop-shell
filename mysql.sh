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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disabling existing MySQL module"

test -f /etc/yum.repos.d/mysql.repo &>> $LOGFILE

if [ $? -ne 0 ]
then
    cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
    VALIDATE $? "Copying MySQL repo file to repos directory"
else
    echo -e "MySQL repo file already exists.....$Y SKIPPING $N"
fi

dnf list installed mysql-community-server &>> $LOGFILE 
if [ $? -ne 0 ]
then
    dnf install mysql-community-server -y &>> $LOGFILE
    VALIDATE $? "Installing MySQL Community Server"
else
    echo -e "MySQL DB is already installed....$Y SKIPPING $N"
fi

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "Enabling MySQL DB"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "Start MySQL DB"

mysql_secure_installation --set-root-pass RoboShop@1

VALIDATE $? "Changing mysql root user password"