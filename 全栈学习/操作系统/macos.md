[TOC]

# 端口占用情况查询

```shell
# 查询端口8001使用进程
lsof -i tcp:8001
```

# Github访问

[参考链接1]: https://www.jianshu.com/p/b3559ac34590
[参考链接2]: https://www.cnblogs.com/wanpi/p/14668174.html
[修改Host]: https://blog.csdn.net/weixin_38629529/article/details/120788902

## 查询GitHub的IP地址

[网站IP地址查询1]: https://github.com.ipaddress.com
[网站IP地址查询2]: https://websites.ipaddress.com/github.global.ssl.fastly.net
[网站IP地址查询3]: https://websites.ipaddress.com/assets-cdn.github.com

- 140.82.112.3 github.com
- 199.232.69.194 github.global.ssl.fastly.net
- 185.199.108.153 assets-cdn.github.com
- 185.199.109.153 assets-cdn.github.com
- 185.199.110.153 assets-cdn.github.com
- 185.199.111.153 assets-cdn.github.com

## 将上面的Host添加到Mac Hosts配置文件

```shell
vim /etc/hosts
# 刷新DNS
killall -HUP mDNSResponder
```

