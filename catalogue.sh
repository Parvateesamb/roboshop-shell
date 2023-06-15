source common.sh

print_head "Configure NodeJS Repo"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log_file}
status_check $?

print_head "Install NodeJS"
yum install nodejs -y &>>${log_file}
status_check $?

print_head "Create Roboshop user"
id roboshop &>>${log_file}
if [ $? -ne 0 ]; then
  useradd roboshop &>>${log_file}
fi
status_check $?

print_head "Create Application directory"
if [ ! -d /app ]; then
  mkdir /app &>>${log_file}
fi
status_check $?

print_head "Delete old content"
rm -fr /app/* &>>${log_file}
status_check $?

print_head "Downloading App content"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${log_file}
cd /app
status_check $?

print_head "Extracting App content"
unzip /tmp/catalogue.zip &>>${log_file}
status_check $?

print_head "Installing NodeJS Dependencies"
npm install &>>${log_file}
status_check $?

print_head "Copy Systemd Service file"
cp ${code_dir}/configs/catalogue.service /etc/systemd/system/catalogue.service &>>${log_file}
status_check $?

print_head "Reload Systemd"
systemctl daemon-reload &>>${log_file}
status_check $?

print_head "Enable Catalogue service"
systemctl enable catalogue &>>${log_file}
status_check $?

print_head "Start Catalogue Service"
systemctl start catalogue &>>${log_file}
status_check $?

print_head "Copy MongoDB Repo file"
cp ${code_dir}/configs/mongo.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
status_check $?

print_head "Install MongoDB client"
yum install mongodb-org-shell -y &>>${log_file}
status_check $?

print_head "Load Schema"
mongo --host mongodb.parudevops.link </app/schema/catalogue.js &>>${log_file}
status_check $?
