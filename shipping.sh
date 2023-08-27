#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript1-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: please run this script with root access $N"
    exit 1
fi
VALIDATE()
{
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R failure $N"
        exit 1
    else
        echo -e "$2 ... $G success $N"
    fi
}

yum install maven -y

useradd roboshop

mkdir /app

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip

cd /app

unzip /tmp/shipping.zip

cd /app

mvn clean package

mv target/shipping-1.0.jar shipping.jar
