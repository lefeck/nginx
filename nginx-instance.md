# nginx获取真正的ip

首先，一个请求肯定是可以分为请求头和请求体的，而我们客户端的IP地址信息一般都是存储在请求头里的。如果你的服务器有用Nginx做负载均衡的话，你需要在你的location里面配置X-Real-IP和X-Forwarded-For请求头：

```nginx
    location ^~ /your-service/ {
            proxy_set_header        X-Real-IP       $remote_addr;
            proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://localhost:60000/your-service/;
    }
```

**X-Real-IP**

经过反向代理后，由于在客户端和web服务器之间增加了中间层，因此web服务器无法直接拿到客户端的ip，通过$remote_addr变量拿到的将是反向代理服务器的ip地址。
这句话的意思是说，当你使用了nginx反向服务器后，在web端使用request.getRemoteAddr()（本质上就是获取$remote_addr），取得的是nginx的地址，即$remote_addr变量中封装的是nginx的地址，当然是没法获得用户的真实ip的。但是，nginx是可以获得用户的真实ip的，也就是说nginx使用$remote_addr变量时获得的是用户的真实ip，如果我们想要在web端获得用户的真实ip，就必须在nginx里作一个赋值操作，即我在上面的配置：

> proxy_set_header X-Real-IP $remote_addr;

$remote_addr 只能获取到与服务器本身直连的上层请求ip，所以设置$remote_addr一般都是设置第一个代理上面;但是问题是，有时候是通过cdn访问过来的，那么后面web服务器获取到的，永远都是cdn 的ip 而非真是用户ip,那么这个时候就要用到X-Forwarded-For 了，这个变量的意思，其实就像是链路反追踪，从客户的真实ip为起点，穿过多层级的proxy ，最终到达web 服务器，都会记录下来，所以在获取用户真实ip的时候，一般就可以设置成，proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; 这样就能获取所有的代理ip 客户ip。 

**X-Forwarded-For**

X-Forwarded-For变量，这是一个squid开发的，用于识别通过HTTP代理或负载平衡器原始IP一个连接到Web服务器的客户机地址的非rfc标准，如果有做X-Forwarded-For设置的话,每次经过proxy转发都会有记录,格式就是client1,proxy1,proxy2以逗号隔开各个地址，由于它是非rfc标准，所以默认是没有的，需要强制添加。在默认情况下经过proxy转发的请求，在后端看来远程地址都是proxy端的ip 。也就是说在默认情况下我们使用request.getAttribute("X-Forwarded-For")获取不到用户的ip，如果我们想要通过这个变量获得用户的ip，我们需要自己在nginx添加配置：

> proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

​		增加$proxy_add_x_forwarded_for到X-Forwarded-For里去，当然由于默认X-Forwarded-For值是空的，所以我们总感觉X-Forwarded-For的值就等于$proxy_add_x_forwarded_for的值，实际上当你搭建两台nginx在不同的ip上，并且都使用了这段配置，那你会发现在web服务器端通过命令获得的将会是客户端ip和第一台nginx的ip。

​		$proxy_add_x_forwarded_for变量包含客户端请求头中的X-Forwarded-For与$remote_addr两部分，它们之间用逗号分开。


## 配置示例

结构示意图:

![截屏2021-04-08 下午12.05.11](/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-04-08 下午12.05.11.png)

10.122 配置如下:

```nginx
    upstream testupstream {
        server 192.168.10.168:8025;
    }
    server {
        listen 8028;
        location / {
            proxy_pass http://testupstream;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
        }
    }
```

10.168 配置如下:

```nginx
upstream test141upstream {
    server 192.168.10.222:8028;
}
server {
        listen        8025;
        server_name primary.test8025.tech;
        location /  {
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_pass http://test141upstream;
        }
}
```

10.222 配置如下:

```nginx
upstream testupstream {
    server 192.168.10.141:80;
}
server {
    listen 8028;
    location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://testupstream;
    }
}
```

10.141 配置如下:

```nginx
#在10.141.上日志中设置打印$http_x_forwarded_for如下:
 log_format  main  '$http_x_forwarded_for|$http_x_real_ip|$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
http {
    server {
        listen 80;
        location / {
               return 200 "hello testapp 10.141\n
                  remote_addr : $remote_addr
                  host: $host
                  http_x_real_ip: $http_x_real_ip
                  http_x_forwarded_for : $http_x_forwarded_for
                  \n";
        }
    }
}
```

客户端测试:

```shell
rooot@xp-MBP ~ % curl 192.168.10.122:8028
hello testapp 10.141
                  remote_addr : 192.168.10.222
                  host: testupstream
                  http_x_real_ip: 192.168.2.27
                  http_x_forwarded_for : 192.168.2.27, 192.168.10.122, 192.168.10.168

10.141看日志如下:
[root@nginx141 ~]# tail -f /var/log/nginx/access.log
192.168.2.27, 192.168.10.122, 192.168.10.168|192.168.2.27|192.168.10.222 - - [08/Apr/2021:11:45:50 +0800] "GET / HTTP/1.0" 200 256 "-" "curl/7.64.1" "192.168.2.27, 192.168.10.122, 192.168.10.168"
```



# Nginx四层获取客户端真实ip地址



### 配置示例

上游http服务

```nginx
http {
......
    server {
        listen       8123  proxy_protocol;
        location / {
        return 200 'tcp app 10.141 vars:
                remote_addr : $remote_addr
                remote_port : $remote_port
                server_addr : $server_addr
                server_port : $server_port
                host: $host
                proxy_protocol_addr : $proxy_protocol_addr
                proxy_protocol_port : $proxy_protocol_port
                status : $status
                \n';
        }
    }
}
```

stream反向代理配置

```nginx
stream {
		upstream testupstream {
        server 192.168.10.141:8123;
		}
    server {
        listen 8721;
        proxy_pass testupstream;
        proxy_protocol on;
    }
}
```

结果测试

```nginx
jinhuaiwang@jinhuaiwang-MBP ~ % curl  192.168.10.122:8721
tcp app 10.141 vars:
                remote_addr : 192.168.10.122
                remote_port : 45738
                server_addr : 192.168.10.141
                server_port : 8123
                host: 192.168.10.122
                proxy_protocol_addr : 192.168.11.11
                proxy_protocol_port : 53955
                status : 200
```





# Nginx请求限制

## 基本原理

nginx的请求限制本质上是基于交换机上大量使用的QoS流量令牌桶技术做的流量整形。

令牌桶是衡量流量是否超过额定请求的。令牌桶中的每一个令牌都代表一个请求。如果令牌桶中存在令牌，则允许发送请求；而如果令牌桶中不存在令牌，则不允许发送请求。

令牌桶中的令牌不仅仅可以被移除，同样也可以往里添加，所以为了保证接口随时有数据通过，就必须不停地往桶里加令牌，由此可见，往桶里加令牌的速度，就决定了数据通过接口的速度。因此，我们通过控制往令牌桶里加令牌的速度从而控制用户流量的请求数。

设置的这个用户传输数据的速率被称为承诺信息速率（CIR），通常以秒为单位。

每秒钟需要往桶里加的令牌总数，能存在桶中，桶能保存的令牌数量被称为Burst size（峰值）

## 常规配置

在nginx.conf文件中的http模块下配置

```
limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;
```

说明：区域名称为one（自定义），占用空间大小为10m，平均处理的请求频率不能超过每秒一次。

`(binary_remote_addr`是`)remote_addr`（客户端IP）的二进制格式，固定占用4个字节。而`\(remote_addr`按照字符串存储，占用7-15个字节。用`\)binary_remote_addr`可以节省空间。

第二，在http模块的子模块server下面配置

```nginx
location ~* .htm$ {
limit_req zone=one burst=5 ;
proxy_pass http://backend_tomcat;
}
```

这里是对uri后缀为htm的请求限流，其中zone=one和前面的定义对应。

例子：

```nginx
limit_req zone=one burst=5 ;（漏桶）
burst=5表示桶的深度，此时可以有5个请求在桶中等待。超过桶的深度的返回503.

limit_req zone=one burst=5 nodelay;     （令牌桶）
表示超出的请求不延迟等待，直接响应。

limit_req zone=one burst=5  delay=3;  （混合桶）
最新版本的nginx 1.15 可以使用delay=3这样的语句，表示桶的深度是5，有三个延迟，2（+1）个马上处理。
```

## 在nginx后端的配置

有两种方法：

### 用x-forward-for代替$remote_addr

```nginx
## 这里取得原始用户的IP地址
map $http_x_forwarded_for  $clientRealIp {
"" $remote_addr;
~^(?P<firstAddr>[0-9\.]+),?.*$ $firstAddr;
}

## 针对原始用户 IP 地址做限制
limit_req_zone $clientRealIp zone=one:10m  rate=1r/s;

location ~* .htm$ {
limit_req zone=one burst=5 ;
proxy_pass http://backend_tomcat;
}

```

### key换成$server_name

```nginx
limit_req_zone $server_name_addr zone=one:10m rate=1r/s;
```

## 总结

- 我们的情况可能更适合server_name方式。
- 返回503有两种情况，key用完，桶用完





# 代理后端的Nginx 限制真实客户端IP访问

#### 1、正常情况，nginx 限制ip访问方式：

```sh
# nginx http\server 块中配置
allow 192.168.6.0/16;
# allow all;
deny 1.2.3.4/32;
# deny all;
```

#### 2、当nginx经过前端 elb（aws负载均衡）、cdn等代理后，来源IP总是elb、cdn等代理 IP地址

当 nginx处于前端负载均衡、cdn等代理后面，来源IP总是代理IP，这样就无法如上对来源IP进行限制访问。

如这里：可以获取到来源IP地址，不过只是显示看的，来源IP仍是elb、cdn等IP。

###  解决方案

既然已经拿到用户真实 IP 地址了，稍加配置，就可以了。

#### 1、在 Nginx 的 http 模块内加入如下配置：

```nginx
# 获取用户真实IP，并赋值给变量$clientRealIP
map $http_x_forwarded_for  $clientRealIp {
        ""      $remote_addr;
        ~^(?P<firstAddr>[0-9\.]+),?.*$  $firstAddr;
}

server {
......
#如果真实IP为 121.42.0.18、121.42.0.19，那么返回403
	if ($clientRealIp ~* "121.42.0.18|121.42.0.19") {
        #如果你的nginx安装了echo模块，还能如下输出语言，狠狠的发泄你的不满(但不兼容返回403,试试200吧)！
        #add_header Content-Type text/plain;
        #echo "son of a bitch,you mother fucker,go fuck yourself!";
        return 403;
        break;
	}
}
```

那么，`$clientRealIP` 就是用户真实 IP 了，其实就是匹配了 `$http_x_forwarded_for` 的第一个值.

把这个保存为 deny_ip.conf ，上传到 Nginx 的 conf 文件夹，然后在要生效的网站 server 模块中引入这个配置文件，并 Reload 重载 Nginx 即可生效：

```sh
#禁止某些用户访问
include deny_ip.conf;
```