
code_dir=$(pwd)
log_file=/tmp/roboshop.log
rm -f ${log_file}

print_head() {
  echo -e "\e[35m$1\e[0m"
}

status_check() {
  if [ $1 -eq 0 ]
  then
    echo Success
  else
    echo Failure
    echo "Read the log file ${log_file} for more information about error"
    exit 1
  fi
}

NODEJS() {
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
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log_file}
  cd /app
  status_check $?

  print_head "Extracting App content"
  unzip /tmp/${component}.zip &>>${log_file}
  status_check $?

  print_head "Installing NodeJS Dependencies"
  npm install &>>${log_file}
  status_check $?

  print_head "Copy Systemd Service file"
  cp ${code_dir}/configs/${component}.service /etc/systemd/system/${component}.service &>>${log_file}
  status_check $?

  print_head "Reload Systemd"
  systemctl daemon-reload &>>${log_file}
  status_check $?

  print_head "Enable ${component} service"
  systemctl enable ${component} &>>${log_file}
  status_check $?

  print_head "Start ${component} Service"
  systemctl start ${component} &>>${log_file}
  status_check $?

  print_head "Copy MongoDB Repo file"
  cp ${code_dir}/configs/mongo.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
  status_check $?

  print_head "Install MongoDB client"
  yum install mongodb-org-shell -y &>>${log_file}
  status_check $?

  print_head "Load Schema"
  mongo --host mongodb.parudevops.link </app/schema/${component}.js &>>${log_file}
  status_check $?

}