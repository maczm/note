```shell
# 下载库
wget https://repo.mysql.com//mysql80-community-release-el7-6.noarch.rpm
# 安装库
sudo rpm -ivh xxx (mysql80-community-release-el7-6.noarch.rpm)
# 去除gpgKey验证 修改gpgcheck=0
vim /etc/yum.repos.d/mysql-community.repo
# 安装mysql
yum install mysql mysql-server
# 启动mysql
systemctl start mysql.service
# 查看mysql状态
systemctl status mysql.service
# 查看初始密码
cat /var/log/mysqld.log|grep password
# 更新密码
set password for 'root'@'localhost' = 'xxx';
# 查看用户信息
select user, host from mysql.user;
# 允许远程访问
update user set host = '%' where user = 'root';
# 刷新
flush privileges
```

