cp configs/mongo.repo /etc/yum.repos.d/mongo.repo
yum install mongodb-org -y
systemctl enable mongod
systemctl start mongod

# update /etc/mongod.conf file from 127.0.0.1 to 0.0.0.0
