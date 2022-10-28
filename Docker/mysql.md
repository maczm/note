```shell
# docker 中下载 mysql
docker pull mysql:5.7
#启动
docker run --name mysql-test -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -d mysql
docker run -itd --name mysql-test -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 mysql
#进入容器
docker exec -it mysql-test bash
#登录mysql
mysql -u root -p
ALTER USER 'root'@'localhost' IDENTIFIED BY 'maczm';
#添加远程登录用户
CREATE USER 'maczm'@'%' IDENTIFIED WITH mysql_native_password BY 'maczm'
GRANT ALL PRIVILEGES ON *.* TO 'maczm'@'%'
```

