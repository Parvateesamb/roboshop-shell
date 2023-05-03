
code_dir=$(pwd)
curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install nodejs -y
useradd roboshop
mkdir /app
rm -fr /app/*
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip
cd /app
unzip /tmp/catalogue.zip
cd /app
npm install
cp ${code_dir}/configs/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue
cp ${code_dir}/configs/mongo.repo /etc/yum.repos.d/mongo.repo

yum install mongodb-org-shell -y
mongo --host mongodb.parudevops.link </app/schema/catalogue.js
