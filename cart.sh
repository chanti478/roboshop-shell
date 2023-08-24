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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE


VALIDATE $? "setting up NPM source"

yum install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing nodejs"

# once the user is created, if you run this script 2nd time
#IMPROVEMENT: first check the user already exist or not, if not exist and then create

useradd roboshop &>>$LOGFILE

# write a condition to check directory already exist or not
mkdir /app &>>$LOGFILE


curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>$LOGFILE

VALIDATE $? "dowloading cart artifact"

cd /app &>>$LOGFILE

VALIDATE $? "moving in to app directory"

unzip /tmp/cart.zip &>>$LOGFILE

VALIDATE $? "unzipping cart folder"

cd /app &>>$LOGFILE

VALIDATE $? "moving back to app dir"

npm install &>>$LOGFILE

VALIDATE $? "Installing dependencies"

# give full path of catalog.service because we are inside /app dir

cp /home/devops/daws-74s/repos/roboshop-shell/ccart.service /etc/systemd/system/cart.service &>>$LOGFILE

VALIDATE $? "copying cart.service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon reload"

systemctl enable cart &>>$LOGFILE

VALIDATE $? "enable cart"

systemctl start cart &>>$LOGFILE

VALIDATE $? "start cart"
