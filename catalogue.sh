#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript1-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)

R="\e[31m"
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


curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGFILE

VALIDATE $? "dowloading catalogue artifact"

cd /app &>>$LOGFILE

VALIDATE $? "moving in to app directory"

unzip /tmp/catalogue.zip &>>$LOGFILE

VALIDATE $? "unzipping catalogue folder"

cd /app &>>$LOGFILE

VALIDATE $? "moving back to app dir"

npm install &>>$LOGFILE

VALIDATE $? "Installing dependencies"

# give full path of catalog.service because we are inside /app dir

cp /home/devops/daws-74s/repos/roboshop-shell/catalog.service /etc/systemd/system/catalogue.service &>>$LOGFILE

VALIDATE $? "copying catalogue.service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon reload"

systemctl enable catalogue &>>$LOGFILE

VALIDATE $? "enable catalogue"


systemctl start catalogue &>>$LOGFILE

VALIDATE $? "start catalogue"


cp /home/devops/daws-74s/repos/roboshop-shell//etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "copying Mongo repo"

yum install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "installing mongo client"

mongo --host mongoDB.joindevops.online </app/schema/catalogue.js &>>$LOGFILE

VALIDATE $? "loading catalogue data in to mongodb"