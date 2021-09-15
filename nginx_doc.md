# nginx

## Nginx功能概述 

### HTTP基础功能:

* 处理静态文件，索引文件以及自动索引;
* 正向代理;
* SSL 和 TLS SNI 支持;
* IMAP/POP3 代理服务功能;
* 支持4/7层反向代理,其中4层在1.9版本之后引入;
* 引入[gRPC](https://my.oschina.net/xiaominmin/blog/1820371)支持在1.13.10版本之后;
* 动态模块编译;
* Lua脚本语言;
* 缓存静态和动态内容;
* 反向代理多种协议 :HTTP，gRPC，memcached，PHP‐FPM`(Fastcgi)`，SCGI，uwsgi`(python)`；
* 流HTTP视频: FLV，HDS，HLS，MP4等协议；

### 其他**HTTP**功能:

* 基于客户端 IP 地址和 HTTP 基本认证的访问控制;
* 基于 PCRE 的 rewrite 重写模块;
* 内嵌的 perl;
* 带宽限制;
* 基于IP 和名称的虚拟主机服务;
* 支持 keep-alive;
* 热升级无须中断工作进程;
* PUT, DELETE, 和 MKCOL 方法;
* 基 于IP地址的访问控制列表 (ACL)
* 请求和连接限制;
* 动态证书加载;



## 为什么选择Nginx

```
Nginx 是一个高性能的Web和反向代理服务器, 它具有有很多非常优越的特性:

作为Web服务器: 相比Apache，Nginx使用更少的资源，支持更多的高并发连接，体现更高的效率，尤其, NGINX解决了C10K服务问题,Nginx选择了epoll and kqueue 作为开发模型.

作为负载均衡服务器: Nginx既可以在内部直接支持 Rails 和 PHP，也可以支持作为HTTP代理服务器对外进行服务。Nginx用C编写, 不论是系统资源开销还是 CPU 使用效率都很可观。

作为邮件代理服务器: Nginx同时也是一个非常优秀的邮件代理服务器(最早开发这个产品的目的之一也是作为邮件代理服务器)。

Nginx 安装非常的简单，配置文件非常简洁(还能够支持perl语法)，Bugs非常少的服务器: Nginx启动特别容易，并且几乎可以做到7*24不间断运行，即使运行数个月也不需要重新启动。你还能够在不间断服务的情况下进行软件版本的升级。

NGINX支持几个知名度较高的网站，例如Netflix，Hulu，Pinterest，CloudFlare，Airbnb，WordPress.com，GitHub，SoundCloud，Zynga，Eventbrite，Zappos，Media Temple，Heroku，RightScale，Engine Yard，MaxCDN等。
```



## nginx安装



### **yum安装**

安装先决条件：
```
sudo yum install yum-utils
```

配置yum仓库，创建名为`/etc/yum.repos.d/nginx.repo`的文件，其内容如下:

```
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
```

默认情况下，使用稳定的nginx软件包的仓库。如果要使用主线nginx软件包，请运行以下命令:

```
yum-config-manager --enable nginx-mainline
```

列出Nginx主线软件包版本
```
yum --showduplicates list nginx | expand
```
安装nginx，请运行以下命令：
	
```
yum install nginx -y #安装最新版本
yum install nginx-1.18.0-2.el7.ngx -y #指定特定版本nginx安装
```
[nginx rpm包离线下载](https://nginx.org/packages/rhel/7/x86_64/RPMS/)
​	

### **编译安装**

下载[nginx二进制shell脚本](https://github.com/wangjinh/nginx.git])克隆到本地并运行脚本即可完成安装

`--add-module`是静态添加模块

> git clone https://github.com/wangjinh/nginx.git
>
> cd nginx
>
> chmod +x install_nginx.sh 
>
> ./install_nginx.sh 



#### 动态加载第三方模块

NGINX 1.9.11开始增加加载动态模块支持，从此不再需要替换nginx文件即可增加第三方扩展。通常我们要使用一个第三方模块，采用如下步骤：

- 获得当前你所运行nginx对应版本,看是否支持
- 获得第三方模块源代码[Hello World Module](https://github.com/perusio/nginx-hello-world-module.git)，并修改该模块对应的config文件
- 编译动态模块
- 加载动态模块

目前nginx官方只有几个模块支持动态加载, 通过以下命令获取：

```
./configure --help | grep dynamic
```

##### 示例

本示例使用一个简单的[Hello World Module](https://github.com/perusio/nginx-hello-world-module)来演示如何为一个module更新源代码并加载到nginx中。`Hello World`实现了一条简单的指令(**hello_world**)来响应客户端的请求。

1） **获得对应版本的nginx源代码**

```
# /usr/local/nginx/sbin/nginx -v
nginx version: nginx/1.10.3
```

这里我们采用nginx 1.10.3版本的源代码来编译我们的动态模块。

2) **获取模块源代码**

我们在nginx安装目录`nginx-inst`处下载我们的`Hello World`模块源代码：

```
# git clone https://github.com/perusio/nginx-hello-world-module.git
# ls
nginx-1.10.3  nginx-1.10.3.tar.gz  nginx-hello-world-module  pcre-8.40  pcre-8.40.tar.gz  zlib-1.2.11  zlib-1.2.11.tar.gz
```

源代码目录nginx-hello-world-module下的`config`脚本定义了如何进行编译。参看如下：

```
ngx_addon_name=ngx_http_hello_world_module

if test -n "$ngx_module_link"; then
  ngx_module_type=HTTP
  ngx_module_name=ngx_http_hello_world_module
  ngx_module_srcs="$ngx_addon_dir/ngx_http_hello_world_module.c"
  . auto/module
else
        HTTP_MODULES="$HTTP_MODULES ngx_http_hello_world_module"
        NGX_ADDON_SRCS="$NGX_ADDON_SRCS $ngx_addon_dir/ngx_http_hello_world_module.c"
fi
```

3） **编译动态模块**

这里可以先获取当前我们正在运行的nginx的一个编译参数：

```
# /usr/local/nginx/sbin/nginx -V
nginx version: nginx/1.10.3
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-28) (GCC) 
built with OpenSSL 1.0.2k-fips  26 Jan 2017
TLS SNI support enabled
configure arguments: --prefix=/usr/local/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --with-http_ssl_module \
--with-pcre=../pcre-8.40 --with-zlib=../zlib-1.2.11
```

这里因为我们的`Hello World`要工作在该环境下，因此编译时最好保持参数完全一致，以减少不必要的麻烦：

```
# cd nginx-1.10.3
# make clean
# ./configure \
--prefix=/usr/local/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log  \
--http-log-path=/var/log/nginx/access.log  \
--pid-path=/var/run/nginx.pid  \
--lock-path=/var/run/nginx.lock  \
--with-http_ssl_module \
--with-pcre=../pcre-8.40 \
--with-zlib=../zlib-1.2.11 \
--add-dynamic-module=../nginx-hello-world-module
# make modules
# ls objs/
addon         Makefile           ngx_auto_headers.h                     ngx_http_hello_world_module_modules.o  ngx_modules.c
autoconf.err  ngx_auto_config.h  ngx_http_hello_world_module_modules.c  ngx_http_hello_world_module.so         src
```

上面我们可以看到编译出了一个`.so`的动态链接库文件。

4）**加载并使用模块**

我们将上述生成的`.so`动态链接库文件拷贝到nginx的安装目录下的`modules`文件夹：

```
#  mkdir -p /usr/local/nginx/modules
# cp objs/ngx_http_hello_world_module.so /usr/local/nginx/modules/
# chmod 777 /usr/local/nginx/modules/ngx_http_hello_world_module.so
# ls /usr/local/nginx/modules/
ngx_http_hello_world_module.so
```

修改nginx配置文件(/etc/nginx/nginx.conf)，使用`load_module`指令在top-level(main)加载该动态链接库：

```
# vi /etc/nginx/nginx.conf
worker_processes  1;

load_module modules/ngx_http_hello_world_module.so;

events {
    worker_connections  1024;
}
```

然后再修改nginx配置文件，在**http**上下文添加一个**location**块，并使用`Hello World`模块的**hello_world**指令：

```
server {
    listen 80;

    location / {
         hello_world;
    }
}
```

最后重新加载nginx，发送请求进行验证：

```
# /usr/local/nginx/sbin/nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

# /usr/local/nginx/sbin/nginx -s reload
# curl -X GET http://127.0.0.1:80/
hello world
```



### **Docker安装**

[官网镜像](https://hub.docker.com/nginx/)

下载Nginx镜像: 

> docker pull nginx:latest

 启动容器:

> docker run --name nginx -p 80:80 -v /data/docker/nginx/logs:/var/log/nginx -v /data/docker/nginx/conf/nginx.conf:/etc/nginx/nginx.conf:ro -d nginx

停止服务:

> docker exec -it nginx nginx -s stop 或者: docker stop nginx 

重启服务: 

> docker restart nginx	



程序环境
			配置文件的组成部分：
			主配置文件：nginx.conf
					include conf.d/*.conf
				fastcgi， uwsgi，scgi等协议相关的配置文件
				mime.types：支持的mime类型
			主程序文件：/usr/sbin/nginx
			Unit File：nginx.service
		
		配置：
			主配置文件的配置指令：
				directive value [value2 ...];
				
				注意：
					(1) 指令必须以分号结尾；
					(2) 支持使用配置变量；
						内建变量：由Nginx模块引入，可直接引用；
						自定义变量：由用户使用set命令定义；
							set variable_name value;
							引用变量：$variable_name


主配置文件结构：

nginx配置文件主要分为五个部分：

	main{ #（全局设置）
			event { #事件驱动相关的配置；
				...
			}
		
			http{ #服务器
				upstream{ #（负载均衡服务器设置：主要用于负载均衡和设置一系列的后端服务器）
					...
				} 
				server{ #（主机设置：主要用于指定主机和端口）
					location{ #（URL匹配特点位置的设置）
						...
					} 
				}
			}
	}



nginx 配置文件结构图:


<div align="center">
    <a href="https://scikit-learn.org.cn/">
    	<img src="/Users/jinhuaiwang/Desktop/3eb78a5509282becf126c001cc82b852.jpg" style="zoom:67%;">  
    </a>
</div>

**配置指令：**
	

main配置段常见的配置指令：

分类：

* 正常运行必备的配置
* 优化性能相关的配置
* 用于调试及定位问题相关的配置
* 事件驱动相关的配置



**正常运行必备的配置：**

1、user
	Syntax:	user user [group];
	Default:	user nobody nobody;
	Context:	main
	

	Defines user and group credentials used by worker processes. If group is omitted, a group whose name equals that of user is used.

2、pid /PATH/TO/PID_FILE;
	指定存储nginx主进程进程号码的文件路径；
	
3、include file | mask;
	指明包含进来的其它配置文件片断；
	
4、load_module file;
						指明要装载的动态模块；
						
**性能优化相关的配置：**

1、worker_processes number | auto;
	worker进程的数量；通常应该等于小于当前主机的cpu的物理核心数；
	auto：当前主机物理CPU核心数；
	
2、worker_cpu_affinity cpumask ...;
	worker_cpu_affinity auto [cpumask];
	

	CPU MASK：
		00000000：
		00000001：0号CPU
		00000010：1号CPU
		... ...
3、worker_priority number;
	指定worker进程的nice值，设定worker进程优先级；[-20,20]
	
4、worker_rlimit_nofile number;
	worker进程所能够打开的文件数量上限；
						
调试、定位问题：

1、daemon on|off;	
	是否以守护进程方式运行Nignx；
	
2、master_process on|off;
	是否以master/worker模型运行nginx；默认为on；
	
3、error_log file [level];
	定义错误日志级别，
						
事件驱动相关的配置:

events {
	...
}

1、worker_connections number;
	每个worker进程所能够打开的最大并发连接数数量；
	
	worker_processes * worker_connections

2、use method;
	指明并发连接请求的处理方法；
		
		use epoll;

3、accept_mutex on | off; 是否开启互斥锁功能
	处理新的连接请求的方法；on意味着由各worker轮流处理新请求，Off意味着每个新请求的到达都会通知所有的worker进程；
	
http协议的相关配置：

	http {
		... ...
		server {
			...
			server_name
			root
			location [OPERATOR] /uri/ {
				...
			}
		}
		server {
			...
		}
	}				
与套接字相关的配置：

	server { ... }
		配置一个虚拟主机；
			
		server {
			listen address[:PORT]|PORT;
			server_name SERVER_NAME;
			root /PATH/TO/DOCUMENT_ROOT;							
		}
		
	listen PORT|address[:port]|unix:/PATH/TO/SOCKET_FILE
	      listen address[:port] [default_server] [ssl] [http2 | spdy]  [backlog=number] [rcvbuf=size] [sndbuf=size]
		
		default_server：设定为默认虚拟主机；
		ssl：限制仅能够通过ssl连接提供服务；
		backlog=number：后援队列长度；
		rcvbuf=size：接收缓冲区大小；
		sndbuf=size：发送缓冲区大小；
		
	server_name name ...;
		指明虚拟主机的主机名称；后可跟多个由空白字符分隔的字符串；
			支持*通配任意长度的任意字符；server_name *.magedu.com  www.magedu.*
			支持~起始的字符做正则表达式模式匹配；server_name ~^www\d+\.magedu\.com$
			
		匹配机制：
			(1) 首先是字符串精确匹配;
			(2) 左侧*通配符；
			(3) 右侧*通配符；
			(4) 正则表达式；
		
		练习：定义四个虚拟主机，混合使用三种类型的虚拟主机；
			仅开放给来自于本地网络中的主机访问；
		
	tcp_nodelay on | off;
		在keepalived模式下的连接是否启用TCP_NODELAY选项；
		
		tcp_nopush on|off;
		在sendfile模式下，是否启用TCP_CORK选项；
		
	sendfile on | off;
		是否启用sendfile功能；

定义路径相关的配置：

	root path; 
		设置web资源路径映射；用于指明用户请求的url所对应的本地文件系统上的文档所在目录路径；可用的位置：http, server, location, if in location；
		
	location [ = | ~ | ~* | ^~ ] uri { ... }
		Sets configuration depending on a request URI. 
		
		http://nginx.org/en/docs/http/ngx_http_core_module.html#listen
		在一个server中location配置段可存在多个，用于实现从uri到文件系统的路径映射；ngnix会根据用户请求的URI来检查定义的所有location，并找出一个最佳匹配，而后应用其配置；
		
		=：对URI做精确匹配；例如, http://www.magedu.com/（匹配）, http://www.magedu.com/index.html（不匹配）必须是/，/以外的内容不做匹配
			location  =  / {
				...
			}
		~：对URI做正则表达式模式匹配，区分字符大小写；
		~*：对URI做正则表达式模式匹配，不区分字符大小写；
		^~：对URI的左半部分做匹配检查，不区分字符大小写；
		不带符号：匹配起始于此uri的所有的url；
		
		匹配优先级从高到低次序：=, ^~, ～/～*，不带符号；
		
		root /vhosts/www/htdocs/
			http://www.magedu.com/index.html --> /vhosts/www/htdocs/index.html
			
		server {
			root  /vhosts/www/htdocs/
			
			location /admin/ {
				root /webapps/app1/data/
			}
		}
		location 中定义的root是继承server段中的root
		
	alias path;
		定义路径别名，文档映射的另一种机制；仅能用于location上下文；
		
		注意：location中使用root指令和alias指令的意义不同；
			(a) root，给定的路径对应于location中的/uri/左侧的/；
			(b) alias，给定的路径对应于location中的/uri/右侧的/；
			
	index file ...;
		默认资源；http, server, location；
		
	error_page code ... [=[response]] uri;
		Defines the URI that will be shown for the specified errors. 
		
	try_files file ... uri;

定义客户端请求的相关配置

	12、keepalive_timeout timeout [header_timeout];
		设定保持连接的超时时长，0表示禁止长连接；默认为75s；
		
	13、keepalive_requests ;
		在一次长连接上所允许请求的资源的最大数量，默认为100; 
		
	14、keepalive_disable none | browser ...;
		对哪种浏览器禁用长连接；
		
	15、send_timeout time;
		向客户端发送响应报文的超时时长，此处，是指两次写操作之间的间隔时长；
		
	16、client_body_buffer_size size;
		用于接收客户端请求报文的body部分的缓冲区大小；默认为16k；超出此大小时，其将被暂存到磁盘上的由client_body_temp_path指令所定义的位置；
		
	17、client_body_temp_path path [level1 [level2 [level3]]];
		设定用于存储客户端请求报文的body部分的临时存储路径及子目录结构和数量；
		
			16进制的数字；
			
			client_body_temp_path   /var/tmp/client_body  2 1 1 
				1：表示用一位16进制数字表示一级子目录；0-f
				2：表示用2位16进程数字表示二级子目录：00-ff
				2：表示用2位16进程数字表示三级子目录：00-ff

对客户端进行限制的相关配置：

	18、limit_rate rate;
		限制响应给客户端的传输速率，单位是bytes/second，0表示无限制；
		
	19、limit_except method ... { ... }
		限制对指定的请求方法之外的其它方法的使用客户端；
		
		limit_except GET {
			allow 192.168.1.0/24;
			deny  all;
		}

 文件操作优化的配置

	20、aio on | off | threads[=pool];
		是否启用aio功能；
		
	21、directio size | off;
		在Linux主机启用O_DIRECT标记，此处意味文件大于等于给定的大小时使用，例如directio 4m;
		
	22、open_file_cache off;
		open_file_cache max=N [inactive=time];
			nginx可以缓存以下三种信息：
				(1) 文件的描述符、文件大小和最近一次的修改时间；
				(2) 打开的目录结构；
				(3) 没有找到的或者没有权限访问的文件的相关信息；
			
			max=N：可缓存的缓存项上限；达到上限后会使用LRU算法实现缓存管理；
			
			inactive=time：缓存项的非活动时长，在此处指定的时长内未被命中的或命中的次数少于open_file_cache_min_uses指令所指定的次数的缓存项即为非活动项；
			
	23、open_file_cache_valid time;
		缓存项有效性的检查频率；默认为60s; 
		
	24、open_file_cache_min_uses number;
		在open_file_cache指令的inactive参数指定的时长内，至少应该被命中多少次方可被归类为活动项；
		
	25、open_file_cache_errors on | off;
		是否缓存查找时发生错误的文件一类的信息；



## nginx模块详解



### ngx_http_access_module

实现基于ip的访问控制功能

> allow address | CIDR | unix: | all;
> deny address | CIDR | unix: | all;



### ngx_http_auth_basic_module

实现基于用户的访问控制，使用basic机制进行用户认证；

> auth_basic string | off;
> auth_basic_user_file file;

配置示例:

	location /admin/ {
			alias /webapps/app1/data/;
			auth_basic "Admin Area";
			auth_basic_user_file /etc/nginx/.ngxpasswd;
	}

​	注意：htpasswd命令由httpd-tools所提供；





### ngx_http_stub_status_module

> 用于输出nginx的基本状态信息；

```	
	Active connections: 291 
	server accepts handled requests
		16630948 16630948 31070465 
	Reading: 6 Writing: 179 Waiting: 106 	
```
参数详解:

> 	Active connections: 活动状态的连接数；
> 	accepts：已经接受的客户端请求的总数；
> 	handled：已经处理完成的客户端请求的总数；
> 	requests：客户端发来的总的请求数；
> 	Reading：处于读取客户端请求报文首部的连接的连接数；
> 	Writing：处于向客户端发送响应报文过程中的连接数；
> 	Waiting：处于等待客户端发出请求的空闲连接数；

> stub_status

配置示例：

```
	location  /basic_status {
		stub_status;
	}
```



### ngx_http_log_module

​		ngx_http_log_module module writes request logs in the specified format.

> log_format name string ...;
	string可以使用nginx核心模块及其它模块内嵌的变量；

	课外作业：为nginx定义使用类似于httpd的combined格式的访问日志；

> access_log path [format [buffer=size] [gzip[=level]] [flush=time] [if=condition]];
	access_log off;

	访问日志文件路径，格式及相关的缓冲的配置；
		buffer=size
		flush=time 

> open_log_file_cache max=N [inactive=time] [min_uses=N] [valid=time];
	open_log_file_cache off;
	缓存各日志文件相关的元数据信息；

		max：缓存的最大文件描述符数量；
		min_uses：在inactive指定的时长内访问大于等于此值方可被当作活动项；
		inactive：非活动时长；
		valid：验正缓存中各缓存项是否为活动项的时间间隔；



### ngx_http_gzip_module


​	ngx_http_gzip_module模块是使用“ gzip”方法压缩响应的过滤器。这通常有助于将传输数据的大小减少一半甚至更多.



> gzip on | off;		

启用或禁用响应gzip功能。

> gzip_comp_level level;

设置响应的gzip压缩级别。可接受的值在1到9之间。值越大压缩越明显。

> gzip_disable regex ...;

禁用“User-Agent”头字段匹配任何指定正则表达式的请求的响应的压缩。

> gzip_min_length length;

启用压缩功能的响应报文大小阈值；

> gzip_buffers number size;

支持实现压缩功能时为其配置的缓冲区数量及每个缓存区的大小；

> gzip_proxied off | expired | no-cache | no-store | private | no_last_modified | no_etag | auth | any ...;

​	nginx作为代理服务器接收到从被代理服务器发送的响应报文后，在何种条件下启用压缩功能的；
​		off：对代理的请求不启用
​		no-cache, no-store，private：表示从被代理服务器收到的响应报文首部的Cache-Control的值为此三者中任何一个，则启用压缩功能；
​		

> gzip_types mime-type ...;

压缩过滤器，仅对此处设定的MIME类型的内容启用压缩功能,请参考[mime-type](https://www.nginx.com/resources/wiki/start/topics/examples/full/#mime-types)；



**示例：**

```
	gzip  on;
	gzip_comp_level 6;
	gzip_min_length 64;
	gzip_proxied any;
	gzip_types text/xml text/css  application/javascript;						
```



### ngx_http_ssl_module

> ssl on | off;

为给定的虚拟服务器启用HTTPS协议。

> ssl_certificate file;

当前虚拟主机使用PEM格式的证书文件；

> ssl_certificate_key file;

当前虚拟主机上与其证书匹配的私钥文件；

> ssl_protocols [SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2];

支持ssl协议版本，默认为后三个；

> ssl_session_cache off | none | [builtin[:size]] [shared:name:size];

builtin[:size]：使用OpenSSL内建的缓存，此缓存为每worker进程私有；

[shared:name:size]：在各worker之间使用一个共享的缓存；

> ssl_session_timeout time;

客户端一侧的连接可以复用ssl session cache中缓存的ssl参数的有效时长；



**配置示例：**

```
http {
    ssl_session_cache   shared:SSL:10m; # ssl_session_cache 会话存储在工作进程之间共享的SSL会话缓存中，一兆字节的缓存包含大约4000个会话。默认的缓存超时为5分钟。
    ssl_session_timeout 10m; #增加会话缓存时长

    server {
        listen              443 ssl;
        server_name         www.example.com;
        keepalive_timeout   70;

        ssl_certificate     www.example.com.crt;
        ssl_certificate_key www.example.com.key;
        ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers         HIGH:!aNULL:!MD5;
    }
}					
```





SSL证书链配置实例:



一些浏览器可能会抱怨由知名证书颁发机构签署的证书，而其他浏览器可能会毫无问题地接受该证书。发生这种情况是因为颁发机构已使用中间证书签署了服务器证书，该中间证书在特定浏览器中分布的知名可信证书颁发机构的基础中不存在。在这种情况下，授权机构提供应链接到已签名服务器证书的捆绑证书链。服务器证书必须出现在组合文件中的链接证书之前：

```
$ cat www.example.com.crt bundle.crt > www.example.com.chained.crt
```

The resulting file should be used in the [`ssl_certificate`](https://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_certificate) directive:

```
server {
    listen              443 ssl;
    server_name         www.example.com;
    ssl_certificate     www.example.com.chained.crt;
    ssl_certificate_key www.example.com.key;
}
```



**单个HTTP/HTTPS配置实例:**

```
server {
    listen              80;
    listen              443 ssl;
    server_name         www.example.com;
    ssl_certificate     www.example.com.crt;
    ssl_certificate_key www.example.com.key;
    #...
}
```



**基于名称的HTTPS配置实例:**

将两个或多个HTTPS服务器配置为侦听单个IP地址时，会出现一个常见问题：使用此配置，浏览器将接收默认服务器的证书。在这种情况下，`www.example.com`无论请求的服务器名称是什么。这是由SSL协议本身的行为引起的。在浏览器发送HTTP请求之前，已建立SSL连接，NGINX不知道所请求服务器的名称。因此，它可能仅提供默认服务器的证书。

解决此问题的最佳方法是为每个HTTPS服务器分配一个单独的IP地址：

```
server {
    listen          192.168.1.1:443 ssl;
    server_name     www.example.com;
    ssl_certificate www.example.com.crt;
    #...
}

server {
    listen          192.168.1.2:443 ssl;
    server_name     www.example.org;
    ssl_certificate www.example.org.crt;
    #...
}
```



**单SSL证书多名称服务:**

```
ssl_certificate     common.crt;
ssl_certificate_key common.key;

server {
    listen          443 ssl;
    server_name     www.example.com;
    #...
}

server {
    listen          443 ssl;
    server_name     www.example.org;
    #...
}
```





### ngx_http_rewrite_module

​	ngx_http_rewrite_module模块用于使用PCRE正则表达式更改请求URI，返回重定向以及有条件地选择配置。

**rewrite**

```
syntax: rewrite regex replacement [flag]
Default: —
Context: server, location, if
```

- 如果正则表达式（*regex*）匹配到了请求的URI（request URI），这个URI会被后面的*replacement*替换

- *rewrite*的定向会根据他们在配置文件中出现的顺序依次执行

- 通过使用*flag*可以终止定向后进一步的处理

- 如果replacement以“http://”, “https://”, or “$scheme”开头，处理将会终止，请求结果会以重定向的形式返回给客户端（client）

- 如果replacement字符串里有新的request参数，那么之前的参数会附加到其后面，如果要避免这种情况，那就在replacement字符串后面加上“？”，eg：

  ```
   rewrite ^/users/(.*)$ /show?user=$1? last;=
  ```

- 如果正则表达式（*regex*）里包含“}” or “;”字符，需要用单引号或者双引号把正则表达式引起来

可选的*flag*参数如下：

- last

	1. 结束当前的请求处理，用替换后的URI重新匹配location；
	2. 可理解为重写（rewrite）后，发起了一个新请求，进入server模块，匹配location；
	3. 如果重新匹配循环的次数超过10次，nginx会返回500错误；
	4. 返回302 http状态码 ；
	5. 浏览器地址栏显示重地向后的url

- break

	1. 结束当前的请求处理，使用当前资源，不在执行location里余下的语句；
	2. 返回302 http状态码 ；
	3. 浏览器地址栏显示重地向后的url

-  redirect

	1. 临时跳转，返回302 http状态码；
	2. 浏览器地址栏显示重地向后的url

- permanent

	1. 永久跳转，返回301 http状态码；
	2. 浏览器地址栏显示重定向后的url

> return

	return code [text];
	return code URL;
	return URL;
	
	Stops processing and returns the specified code to a client. 

> rewrite_log on | off;

是否开启重写日志；
	
> if (condition) { ... }

引入一个新的配置上下文 ；条件满足时，执行配置块中的配置指令；server, location；

```
condition：
		比较操作符：
			==
			!=
			~：模式匹配，区分字符大小写；
			~*：模式匹配，不区分字符大小写；
			!~：模式不匹配，区分字符大小写；
			!~*：模式不匹配，不区分字符大小写；
		文件及目录存在性判断：
			-e, !-e
			-f, !-f
			-d, !-d
			-x, !-x
```



> set $variable value;

用户自定义变量 ；				



### ngx_http_referer_module

​		ngx_http_referer_module模块用于阻止对“Referer”标头字段中具有无效值的请求的站点访问。

> valid_referers none | blocked | server_names | string ...;

定义referer首部的合法可用值；
	none：请求报文首部没有referer首部；
	blocked：请求报文的referer首部没有值；
	server_names：参数，其可以有值作为主机名或主机名模式；
		arbitrary_string：直接字符串，但可使用\*作通配符；
		regular expression：被指定的正则表达式模式匹配到的字符串；要使用~打头，例如 ~.*\.magedu\.com；



**配置示例：**

```
	valid_referers none block server_names *.magedu.com *.mageedu.com magedu.* mageedu.* ~\.magedu\.;
	
	if($invalid_referer) {
		return http://www.magedu.com/invalid.jpg;
	}
```

Nginx反向代理	
​		nginx只能做反向代理服务，httpd既能做正向又能做反向代理
​		反向代理时，必须有反向代理相关的模块
​					
​		从httpd服务端取到内容--->放在nginx proxy cache--->返回给客户端
​		
​		nginx通常用来做proxy，做httpd很少，
​		下面来介绍一下nginx做反向代理模块相关参数：



### ngx_http_proxy_module

ngx_http_proxy_module模块允许将请求传递到后端服务器。

**proxy_pass**

```
Syntax:    proxy_pass URL;
Default:    —
Context:    location, if in location, limit_except
```

- 不影响浏览器地址栏的url

- 设置被代理server的协议和地址，URI可选（可以有，也可以没有）

- 协议可以为http或https

- 地址可以为域名或者IP，端口可选；eg：

  ```
   proxy_pass http://localhost:8000/uri/;
  ```

* proxy_pass后面的路径不带uri时，其会将location的uri传递给后端主机；

第一种情况:
```
server {
	...
	server_name HOSTNAME;
	location /uri/ {
		proxy_pass http://host[:port];
	}
	...
}
```
> 请求：http://HOSTNAME/uri 会被代理到 http://host/uri 

* proxy_pass后面的路径是`/`时, location的uri就是proxy_pass的`/`；

第二种情况:

```
server {
	...
	server_name HOSTNAME;
	location /uri/ {
		proxy_pass http://host[:port]/;
	}
	...
}
```
> 请求：http://HOSTNAME/uri/ 会被代理到 http://host/uri/

* proxy_pass后面的路径是一个uri时，其会将location的uri替换为proxy_pass的uri；

第三种情况:
```
server {
	...
	server_name HOSTNAME;
	location /uri/ {
		proxy_pass http://host/new_uri/;
	}
	...
}
```
> ```
> 请求：http://HOSTNAME/uri/ 会被代理到 http://host/new_uri/
> ```

* 如果location定义其uri时使用了正则表达式的模式，或在if语句或limt_execept中使用proxy_pass指令，则proxy_pass之后必须不能使用uri; 用户请求时传递的uri将直接附加代理到的服务的之后；

第四种情况:

```
server {
	...
	server_name HOSTNAME;
	location ~|~* /uri/ {
		proxy http://host;
	}
	...
}
```
> 请求: http://HOSTNAME/uri/ 会被代理到 http://host/uri/；


> proxy_set_header field value;

设定发往后端服务器的请求报文的请求首部的值；Context:	http, server, location
```
proxy_set_header X-Real-IP  $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```



| Syntax:  | `proxy_cache_path *path* [levels=*levels*] [use_temp_path=on|off] keys_zone=*name*:*size* [inactive=*time*] [max_size=*size*] [min_free=*size*] [manager_files=*number*] [manager_sleep=*time*] [manager_threshold=*time*] [loader_files=*number*] [loader_sleep=*time*] [loader_threshold=*time*] [purger=on|off] [purger_files=*number*] [purger_sleep=*time*] [purger_threshold=*time*];` |
| :------- | ------------------------------------------------------------ |
| Default: | —                                                            |
| Context: | http                                                         |

设置缓存的路径和其他参数。缓存空间必须先定义后使用。`levels`参数定义高速缓存的层次结构级别：从1到3，每个级别接受值1或2，`keys_zone`参数定义缓存空间的名称和大小。



> proxy_cache zone（名字） | off;

指明要调用的缓存，或关闭缓存机制；Context:	http, server, location

> proxy_cache_key string;

缓存中用于“键”的内容；
默认值：proxy_cache_key $scheme $proxy_host $request_uri;

> proxy_cache_valid [code ...] time;

定义对特定响应码的响应内容的缓存时长；

	定义在http{...}中；
	proxy_cache_path /var/cache/nginx/proxy_cache levels=1:1:1 keys_zone=pxycache:20m max_size=1g;
	
	定义在需要调用缓存功能的配置段，例如server{...}；
	proxy_cache pxycache;
	proxy_cache_key $request_uri;
	proxy_cache_valid 200 302 301 1h;
	proxy_cache_valid any 1m;

> proxy_cache_use_stale

确定在与代理服务器通信期间发生错误时，可以在哪些情况下使用陈旧的缓存响应。

	proxy_cache_use_stale error | timeout | invalid_header | updating | http_500 | http_502 | http_503 | http_504 | http_403 | http_404 | off ...;

> proxy_cache_methods GET | HEAD | POST ...;

如果客户端请求方法在代理缓存方法中定义，那么响应将被缓存。 

> proxy_hide_header field;

默认情况下，nginx不会传递头字段“Date”、“Server”、“X-Pad”和“X-Accel-…”从代理服务器到客户机的响应。proxy_hide_header指令设置不会传递的其他字段。

> proxy_connect_timeout time;

定义客户端与代理服务器建立连接的超时。应该注意，这个超时通常不能超过75秒。默认为60s；最长为75s；

> proxy_read_timeout time; 

定义客户端从代理服务器读取响应的超时。超时仅在两个连续的读取操作之间设置，而不用于传输整个响应。

> proxy_send_timeout time;

设置客户端向代理服务器传输请求的超时。超时仅在两个连续的写操作之间设置，而不用于传输整个请求。如果代理服务器在此期间没有接收到任何内容，则关闭连接。

> proxy_pass_request_body on | off;

是否将原始请求体传递给代理服务器。默认是开启状态。



### Nginx配置proxy_pass转发的/路径问题

在nginx中配置proxy_pass时，如果是按照^~匹配路径时,要注意proxy_pass后的url最后的/,当加上了/，相当于是绝对根路径，则nginx不会把location中匹配的路径部分代理走;如果没有/，则会把匹配的路径部分也给代理走。

```
location ^~ /static_js/ 
{ 
proxy_cache js_cache; 
proxy_set_header Host js.test.com; 
proxy_pass http://js.test.com/; 
}

如上面的配置，如果请求的url是http://servername/static_js/test.html
会被代理成http://js.test.com/test.html

而如果这么配置

location ^~ /static_js/ 
{ 
proxy_cache js_cache; 
proxy_set_header Host js.test.com; 
proxy_pass [http://js.test.com](http://js.test.com/); 
}

则会被代理到http://js.test.com/static_js/test.htm

当然，我们可以用如下的rewrite来实现/的功能

location ^~ /static_js/ 
{ 
proxy_cache js_cache; 
proxy_set_header Host js.test.com; 
rewrite /static_js/(.+)$ /$1 break; 
proxy_pass [http://js.test.com](http://js.test.com/); 
} 
```

​		nginx与web结合只有一种方式，由于php没办法编译成nginx模块，并直接内置在nginx上自己处理动态内容，因此处理niginx处理动态页面方式：nginx+php（fpm server），nginx需要装fastcgi_module，基于此模块作为协议的客户端（fastcgi协议）

	fastcgi协议对用户并发请求的资源响应能力很有限，为了避免fcgi的局限性，将fastcgi_module换成AP（apache）对于静态资源的请求，由nginx响应；动态资源请求交给AP来处理



### ngx_http_headers_module

​		The ngx_http_headers_module module allows adding the “Expires” and “Cache-Control” header fields, and arbitrary fields, to a response header.

​		由代理服务器响应给客户端的响应报文添加自定义首部，或修改指定首部的值；

> add_header name value [always];

添加自定义首部；

实例：

	add_header X-Via  $server_addr;
	add_header X-Accel $server_name;
> expires [modified] time;

expires epoch | max | off;
用于定义Expire或Cache-Control首部的值；



实例：

```
			expires @15h30m;						
		  expires    24h;
			expires    modified +24h;
			expires    @24h;
			expires    0;
			expires    -1;
			expires    epoch;
			expires    $expires;
```





### ngx_http_fastcgi_module

​		Nginx用来处理FastCGI的模块。现在LNMP架构里面，PHP一般是以PHP-CGI的形式在运行，它就是一种FastCGI，我们在进程中看到的PHP-FPM是PHP-CGI的管理调度器。

​		The ngx_http_fastcgi_module module allows passing requests to a FastCGI server.

> fastcgi_pass address;

地址为fastcgi server的地址，地址可以指定为域名或IP地址，以及端口；location, if in location；
			

				http://www.ilinux.io/admin/index.php --> /admin/index.php (uri)
					/data/application/admin/index.php			


> fastcgi_index name;

fastcgi默认的主页资源; 
​				

> fastcgi_param parameter value [if_not_empty];

Sets a parameter that should be passed to the FastCGI server. The value can contain text, variables, and their combination.
​				
配置示例1：
前提：配置好fpm server和mariadb-server服务；

					location ~* \.php$ {
						root           /usr/share/nginx/html;
						fastcgi_pass   127.0.0.1:9000;
						fastcgi_index  index.php;
						fastcgi_param  SCRIPT_FILENAME  /usr/share/nginx/html$fastcgi_script_name;
						include        fastcgi_params;
					}					
配置示例2：

通过/pm_status和/ping来获取fpm server状态信息；

				location ~* ^/(pm_status|ping)$ {
					include        fastcgi_params;
					fastcgi_pass 127.0.0.1:9000;
					fastcgi_param  SCRIPT_FILENAME  $fastcgi_script_name;
				}			
​					

> fastcgi_cache_path path [levels=levels] [use_temp_path=on|off] keys_zone=name:size [inactive=time] [max_size=size] [manager_files=number] [manager_sleep=time] [manager_threshold=time] [loader_files=number] [loader_sleep=time] [loader_threshold=time] [purger=on|off] [purger_files=number] [purger_sleep=time] [purger_threshold=time];

定义fastcgi的缓存；缓存位置为磁盘上的文件系统，节约网络IO资源，降低瓶颈，由path所指定路径来定义；
```	
					levels=levels：缓存目录的层级数量，以及每一级的目录数量；levels=ONE:TWO:THREE
						leves=1:2:2
					keys_zone=name:size
						k/v映射的内存空间的名称及大小
					inactive=time
						非活动时长
					max_size=size
						磁盘上用于缓存数据的缓存空间上限
```
> fastcgi_cache zone | off;

调用指定的缓存空间来缓存数据；http, server, location
	
> fastcgi_cache_key string;

定义用作缓存项的key的字符串；
	
> fastcgi_cache_methods GET | HEAD | POST ...;

为哪些请求方法使用缓存；
	
> fastcgi_cache_min_uses number;

缓存空间中的缓存项在inactive定义的非活动时间内至少要被访问到此处所指定的次数方可被认作活动项；
	

> fastcgi_cache_valid [code ...] time;

不同的响应码各自的缓存时长；

示例：

```			
http {
		...
		fastcgi_cache_path /var/cache/nginx/fastcgi_cache levels=1:2:1 keys_zone=fcgi:20m inactive=120s;
		...
		server {
			...
			location ~* \.php$ {
				...
				fastcgi_cache fcgi;
				fastcgi_cache_key $request_uri;
				fastcgi_cache_valid 200 302 10m;
				fastcgi_cache_valid 301 1h;
				fastcgi_cache_valid any 1m;	
				...
			}
			...
		}
		...
	}
```

> fastcgi_keep_conn on | off;

默认情况下，FastCGI服务器将在发送响应后立即关闭连接。但是，当这个指令被设置为on时，nginx将指示FastCGI服务器保持连接打开

> fastcgi_store on | off | string;

启用将文件保存到磁盘。on参数保存具有与指令别名或对应路径的文件。off参数禁止保存文件。此外，可以使用带变量的字符串显式地设置文件名，默认是关闭状态。

> fastcgi_temp_path path [level1 [level2 [level3]]];

定义一个目录，用于存储从FastCGI服务器接收到的数据的临时文件。在指定的目录下可以使用多达三层的子目录层次结构。

例如，在下面的配置中

```
 fastcgi_temp_path /spool/nginx/fastcgi_temp 1 2;
```

> fastcgi_temp_file_write_size size;

当启用FastCGI服务器对临时文件的响应进行缓冲时，限制一次写入临时文件的数据的大小。临时文件的最大大小由fastcgi_max_temp_file_size指令设置。

> fastcgi_store_access users:permissions ...;

为新创建的文件和目录设置访问权限，

例如:

```
fastcgi_store_access user:rw group:rw all:r;
```

示例：
```
location /fetch/ {

    fastcgi_pass         127.0.0.1:9000;
    ...

    fastcgi_store        on;
    fastcgi_store_access user:rw group:rw all:r;
    fastcgi_temp_path    /data/temp;

    alias                /data/www/;
}
```

​		
### ngx_http_upstream_module

​		ngx_http_upstream_module模块用于定义可以由proxy_pass、fastcgi_pass、uwsgi_pass、scgi_pass和memcached_pass指令引用的服务器组。

> upstream name { ... }

定义后端服务器组，会引入一个新的上下文；Context: http
```
upstream httpdsrvs {
	server ...
	server...
	...
}
```

> server address [parameters];

在upstream上下文中server成员，以及相关的参数；Context:	upstream

> address的表示格式：
		unix:/PATH/TO/SOME_SOCK_FILE
		IP[:PORT]
		HOSTNAME[:PORT]

> parameters：
		weight=number
			权重，默认为1；
		max_fails=number
			失败尝试最大次数；超出此处指定的次数时，server将被标记为不可用；
		fail_timeout=time
			设置将服务器标记为不可用状态的超时时长；
		max_conns
			当前的服务器的最大并发连接数；
		backup
			将服务器标记为“备用”，即所有服务器均不可用时此服务器才启用；
		down
			标记为“不可用”；

> least_conn;

指定一个组应该使用负载平衡方法，将请求传递给活动连接最少的服务器那一台。

> ip_hash;

源地址hash调度方法。指定一个组应该使用负载平衡方法，其中请求基于客户机IP地址分布在服务器之间。客户端IPv4地址的前三个八位，或整个IPv6地址，用作散列键。该方法确保来自同一客户机的请求总是传递到同一服务器，除非该服务器不可用。在后一种情况下，客户机请求将被传递到另一台服务器。很可能，它也总是相同的服务器；

> hash key [consistent];

基于指定的key的hash表来实现对请求的调度，此处的key可以直接文本、变量或二者的组合；
			
作用：将请求分类，同一类请求将发往同一个upstream server；

If the consistent parameter is specified the ketama consistent hashing method will be used instead.
	
示例：
```
	hash $request_uri consistent;
	hash $remote_addr;
```

> keepalive connections;

设置每个worker进程到上游服务器的空闲长连接的最大数量，为每个worker进程保留的空闲的长连接数量，当超过此数量时，最近最少使用的连接将被关闭。


> least_time header | last_byte [inflight];

指定一个组应该使用负载平衡方法，将请求传递给服务器的平均响应时间和活动连接数最少那一台。
	
示例：
```
upstream backend {
    server backend1.example.com       weight=5;
    server backend2.example.com:8080;
    server unix:/tmp/backend3;

    server backup1.example.com:8080   backup;
    server backup2.example.com:8080   backup;

    keepalive 32;
}

server {
    location / {
        proxy_pass http://backend;
    }
}
```



此外，以下参数是[商业订购](http://nginx.com/products/)一部分 ：

> resolve

监视与服务器域名对应的IP地址的更改，并自动修改上游配置，而无需重新启动nginx（1.5.12）。服务器组必须驻留在共享内存中。



> route`=`**string**

设置服务器路由名称。

> service`=`*name*

启用DNS [SRV](https://tools.ietf.org/html/rfc2782) 记录的解析并设置服务`name`（1.9.13）。为了使该参数起作用，必须为服务器指定[resolve](https://nginx.org/en/docs/http/ngx_http_upstream_module.html#resolve)参数，并指定不带端口号的主机名。



> slow_start`=`*time*

设置`*time*`服务器不正常运行时，或者在一段时间后服务器变为不可用时，服务器将其权重从零恢复到标称值的时间。默认值为零，即禁用慢速启动。



> drain

将服务器置于“排水”模式（1.13.6）。在这种模式下，仅绑定到服务器的请求将被代理到该服务器。



| 句法： | zone name [size]; |
| :----- | ----------------- |
| 默认： | —                 |
| 内容： | `upstream`        |

定义共享内存区域的**name**和**size**，以保留在工作进程之间共享组的配置和运行时状态。几个组可以共享同一区域。



| 句法： | resolver address ... [valid=*time*] [ipv6=on\|off] [status_zone=*zone*]; |
| :----- | ------------------------------------------------------------ |
| 默认： | —                                                            |
| 内容： | `upstream`                                                   |

配置用于将上游服务器的名称解析为地址的名称服务器，

| 句法： | resolver_timeout time; |
| :----- | ---------------------- |
| 默认： | resolver_timeout 30s； |
| 内容： | upstream               |

设置名称解析超时时间。



**配置实例:**

```
http {
	resolver 10.0.0.1 valid=30s status_zone=server_backend;
	resolver_timeout 40s;
	
	upstream dynamic {
	    zone upstream_dynamic 64k;
	
	    server backend1.example.com      weight=5;
	    server backend2.example.com:8080 fail_timeout=5s slow_start=30s;
	    server 192.0.2.1                 max_fails=3;
	    server backend3.example.com      resolve;
	    server backend4.example.com      service=http resolve;
	
	    server backup1.example.com:8080  backup;
	    server backup2.example.com:8080  backup;
	}
	
	server {
	    listen 80;
      server_name  myapp.example.com;
	    location / {
	        proxy_pass http://dynamic;
	        status_zone server_backend;
	        health_check;
	    }
	}
}

```



**http upstream ssl加密:**

```
http {
    #...
    upstream backend.example.com {
        server backend1.example.com:443;
        server backend2.example.com:443;
   }

    server {
        listen      80;
        server_name www.example.com;
        #...

        location /upstream {
            proxy_pass                    https://backend.example.com;
            proxy_ssl_certificate         /etc/nginx/client.pem;
            proxy_ssl_certificate_key     /etc/nginx/client.key;
            proxy_ssl_protocols           TLSv1 TLSv1.1 TLSv1.2;
            proxy_ssl_ciphers             HIGH:!aNULL:!MD5;
            
            #文件CA证书用于在上游证书验证
            proxy_ssl_trusted_certificate /etc/nginx/trusted_ca_cert.crt;

						#检查证书链中的两个证书,验证证书的有效性
            proxy_ssl_verify        on;
            proxy_ssl_verify_depth  2;
            #每个新的SSL连接都需要在客户端和服务器之间进行完整的SSL握手，这会占用大量CPU。下次NGINX将连接传递到上游服务器时，由于proxy_ssl_session_reuse指令，会话参数将被重用，并且安全连接的建立速度更快。
            proxy_ssl_session_reuse on;
        }
    }

    server {
        listen      443 ssl;
        server_name backend1.example.com;

        ssl_certificate        /etc/ssl/certs/server.crt;
        ssl_certificate_key    /etc/ssl/certs/server.key;
        ssl_client_certificate /etc/ssl/certs/ca.crt;
        ssl_verify_client      optional;

        location /yourapp {
            proxy_pass http://url_to_app.com;
        #...
        }

    server {
        listen      443 ssl;
        server_name backend2.example.com;

        ssl_certificate        /etc/ssl/certs/server.crt;
        ssl_certificate_key    /etc/ssl/certs/server.key;
        ssl_client_certificate /etc/ssl/certs/ca.crt;
        ssl_verify_client      optional;

        location /app {
            proxy_pass http://url_to_app.com;
        #...
        }
    }
}
```







### ngx_stream_core_module

​		ngx_stream_core_module模块在1.9.0版本之后就可用了。默认情况下不构建此模块，编译安装nginx应该使用—with-stream配置参数启用它
​	
​		模拟反代基于tcp或udp的服务连接，即工作于传输层的反代或调度器；

> stream { ... }

定义stream相关的服务；Context:main

实例:
```
stream {
	upstream sshsrvs {
		server 192.168.22.2:22; 
		server 192.168.22.3:22; 
		least_conn;
	}

server {
		listen 10.1.0.6:22022;
		proxy_pass sshsrvs;
	}
}
```

> listen address:port [ssl] [udp] [proxy_protocol] [backlog=number] [bind] [ipv6only=on|off] [reuseport] [so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];


	思考：
		(1) 动态资源存储一组服务器、图片资源存在一组服务器、静态的文本类资源存储在一组服务器；如何分别调度？
		(2) 动态资源基于fastcgi或http协议（ap）?
			lnamp



### ngx_stream_ssl_module



| 句法： | `**ssl_certificate** *file*;` |
| :----- | ----------------------------- |
| 默认： | -                             |
| 内容： | `stream`， `server`           |

`*file*`为给定服务器 指定一个带有PEM格式证书的证书。如果除主要证书之外还应指定中间证书，则应按以下顺序在同一文件中指定它们：首先是主要证书，然后是中间证书。PEM格式的密钥可以放在同一文件中。



从1.15.9版开始，`*file*`使用OpenSSL 1.0.2或更高版本时，可以在名称中使用变量：

> ```
> ssl_certificate $ssl_server_name.crt;
> ssl_certificate_key $ssl_server_name.key;
> ```

请注意，使用变量意味着每次SSL握手都会加载一个证书，这可能会对性能产生负面影响。



可以指定 值 `data`：`*$variable*`而不是`*file*`（1.15.10），后者从变量加载证书而不使用中间文件。请注意，不当使用此语法可能会带来安全隐患，例如将密钥数据写入 [错误日志](https://nginx.org/en/docs/ngx_core_module.html#error_log)。



| 句法： | `**ssl_certificate_key** *file*;` |
| :----- | --------------------------------- |
| 默认： | -                                 |
| 内容： | `stream`， `server`               |

`*file*`用给定服务器的PEM格式的密钥 指定一个。

值 `engine`：`*name*`：`*id*` 可以指定代替`*file*`，它加载了指定的密钥`*id*` 由OpenSSL的引擎`*name*`。



可以指定 值 `data`：`*$variable*`而不是`*file*`（1.15.10），后者从变量加载秘密密钥，而无需使用中间文件。请注意，不当使用此语法可能会带来安全隐患，例如将密钥数据写入 [错误日志](https://nginx.org/en/docs/ngx_core_module.html#error_log)。

从1.15.9版开始，`*file*`使用OpenSSL 1.0.2或更高版本时，可以在名称中使用变量。



| 句法： | `**ssl_ciphers** *ciphers*;`        |
| :----- | ----------------------------------- |
| 默认： | `ssl_ciphers HIGH：！aNULL：！MD5;` |
| 内容： | `stream`， `server`                 |

指定启用的密码。密码以OpenSSL库可以理解的格式指定



可以使用“ `openssl ciphers`”命令查看完整列表。

| 句法： | `**ssl_client_certificate** *file*;` |
| :----- | ------------------------------------ |
| 默认： | -                                    |
| 内容： | `stream`， `server`                  |

指定`*file*`带有用于[验证](https://nginx.org/en/docs/stream/ngx_stream_ssl_module.html#ssl_verify_client)客户端证书的PEM格式的受信任CA证书的。



证书列表将发送给客户端。如果不希望这样做， 则可以使用ssl_trusted_certificate指令。

| 句法： | `**ssl_conf_command** *command*;` |
| :----- | --------------------------------- |
| 默认： | -                                 |
| 内容： | `stream`， `server`               |



`ssl_conf_command`可以在同一级别上指定几个指令：

> ```
> ssl_conf_command Options PrioritizeChaCha;
> ssl_conf_command Ciphersuites TLS_CHACHA20_POLY1305_SHA256;
> ```

当且仅当`ssl_conf_command`当前级别上未定义任何指令时，这些指令才从先前的配置级别继承。



> 请注意，直接配置OpenSSL可能会导致意外行为。

| 句法： | `**ssl_crl** *file*;` |
| :----- | --------------------- |
| 默认： | -                     |
| 内容： | `stream`， `server`   |

`*file*`以PEM格式指定具有已吊销证书（CRL）的证书，用于[验证](https://nginx.org/en/docs/stream/ngx_stream_ssl_module.html#ssl_verify_client) 客户端证书。



| 句法： | `**ssl_dhparam** *file*;` |
| :----- | ------------------------- |
| 默认： | -                         |
| 内容： | `stream`， `server`       |

`*file*`为DHE密码 指定一个带有DH参数的参数。

默认情况下，未设置任何参数，因此将不使用DHE密码。

> 在1.11.0版之前，默认情况下使用内置参数。

| 句法： | `**ssl_ecdh_curve** *curve*;` |
| :----- | ----------------------------- |
| 默认： | `ssl_ecdh_curve auto;`        |
| 内容： | `stream`， `server`           |

`*curve*`为ECDHE密码 指定一个。

> ```
> ssl_ecdh_curve prime256v1：secp384r1;
> ```

特殊值`auto`（1.11.0）指示nginx在使用OpenSSL 1.0.2或更高`prime256v1`版本或较旧版本时使用内置在OpenSSL库中的列表。



| 句法： | `**ssl_handshake_timeout** *time*;` |
| :----- | ----------------------------------- |
| 默认： | `ssl_handshake_timeout 60s;`        |
| 内容： | `stream`， `server`                 |

指定SSL握手完成的超时时间。



| 句法： | `**ssl_password_file** *file*;` |
| :----- | ------------------------------- |
| 默认： | -                               |
| 内容： | `stream`， `server`             |

`*file*`为[私钥](https://nginx.org/en/docs/stream/ngx_stream_ssl_module.html#ssl_certificate_key) 指定一个带有密码短语的密码， 其中每个密码短语都在单独的行上指定。加载密钥时依次尝试使用密码短语。

例：

```
stream {
    ssl_password_file /etc/keys/global.pass;
    ...

    server {
        listen 127.0.0.1:12345;
        ssl_certificate_key /etc/keys/first.key;
    }

    server {
        listen 127.0.0.1:12346;

        # named pipe can also be used instead of a file
        ssl_password_file /etc/keys/fifo;
        ssl_certificate_key /etc/keys/second.key;
    }
}
```



| 句法： | `**ssl_prefer_server_ciphers** on | off;` |
| :----- | ----------------------------------------- |
| 默认： | `ssl_prefer_server_ciphers关闭；`         |
| 内容： | `stream`， `server`                       |

指定当使用SSLv3和TLS协议时，服务器密码应优先于客户端密码。



| 句法： | `**ssl_protocols** [SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2] [TLSv1.3];` |
| :----- | ------------------------------------------------------------ |
| 默认： | `ssl_protocols TLSv1 TLSv1.1 TLSv1.2;`                       |
| 内容： | `stream`， `server`                                          |

启用指定的协议。





| 句法： | `**ssl_session_cache** off | none | [builtin[:*size*]] [shared:*name*:*size*];` |
| :----- | ------------------------------------------------------------ |
| 默认： | `ssl_session_cache none;`                                    |
| 内容： | `stream`， `server`                                          |

设置存储会话参数缓存的类型和大小。高速缓存可以是以下任何类型：

- `off`

  禁止使用会话缓存：nginx明确告知客户端不得重复使用会话。

- `none`

  禁止使用会话缓存：nginx告诉客户端会话可以被重用，但实际上并没有在缓存中存储会话参数。

- `builtin`

  内置OpenSSL的缓存；仅由一个工作进程使用。缓存大小在会话中指定。如果未提供大小，则等于20480个会话。使用内置缓存可能导致内存碎片。

- `shared`

  所有工作进程之间共享的缓存。缓存大小以字节为单位；一兆字节可以存储大约4000个会话。每个共享缓存应具有任意名称。具有相同名称的缓存可以在多个服务器中使用。



两种缓存类型可以同时使用，例如：

> ```
> ssl_session_cache内置：1000共享：SSL：10m;
> ```

但仅使用共享缓存而不使用内置缓存应该会更有效率。



| 句法： | `**ssl_session_ticket_key** *file*;` |
| :----- | ------------------------------------ |
| 默认： | -                                    |
| 内容： | `stream`， `server`                  |

设置`*file*`带有用于加密和解密TLS会话票证的密钥。如果必须在多个服务器之间共享同一密钥，则该指令是必需的。默认情况下，使用随机生成的密钥。

如果指定了多个密钥，则仅第一个密钥用于加密TLS会话票证。这允许配置键旋转，例如：

> ```
> ssl_session_ticket_key current.key;
> ssl_session_ticket_key previous.key;
> ```



在`*file*`必须含有80或48个字节的随机数据，并且可以使用下面的命令创建：

> ```
> openssl rand 80> ticket.key
> ```

根据文件大小，可以使用AES256（对于80字节密钥为1.11.8）或AES128（对于48字节密钥）进行加密。



| 句法： | `**ssl_session_tickets** on | off;` |
| :----- | ----------------------------------- |
| 默认： | `ssl_session_tickets;`              |
| 内容： | `stream`， `server`                 |

通过TLS会话票证启用或禁用会话恢复 。



配置实例:

```
server {
    #...
    ssl_session_tickets on;
    ssl_session_ticket_key /etc/ssl/session_ticket_keys/current.key;
    ssl_session_ticket_key /etc/ssl/session_ticket_keys/previous.key;
}
```



| 句法： | `**ssl_session_timeout** *time*;` |
| :----- | --------------------------------- |
| 默认： | `ssl_session_timeout 5m;`         |
| 内容： | `stream`， `server`               |

指定客户端可以重用会话参数的时间。



| 句法： | `**ssl_trusted_certificate** *file*;` |
| :----- | ------------------------------------- |
| 默认： | -                                     |
| 内容： | `stream`， `server`                   |

指定`file`带有用于验证客户端证书的PEM格式受信任的CA证书。这些证书的列表不会发送给客户端。



| 句法： | `**ssl_verify_client** on | off | optional | optional_no_ca;` |
| :----- | ------------------------------------------------------------ |
| 默认： | `ssl_verify_client off；`                                    |
| 内容： | `stream`， `server`                                          |

启用客户端证书的验证。验证结果存储在 [$ ssl_client_verify](https://nginx.org/en/docs/stream/ngx_stream_ssl_module.html#var_ssl_client_verify)变量中。如果在客户端证书验证期间发生错误，或者客户端未提供所需的证书，则连接将关闭。

该`optional`参数请求客户端证书，并验证该证书是否存在。

该`optional_no_ca`参数请求客户端证书，但不需要由受信任的CA证书对其进行签名。这用于在nginx外部的服务执行实际证书验证的情况下使用。可通过[$ ssl_client_cert](https://nginx.org/en/docs/stream/ngx_stream_ssl_module.html#var_ssl_client_cert)变量访问证书的内容 。



| 句法： | `**ssl_verify_depth** *number*;` |
| :----- | -------------------------------- |
| 默认： | `ssl_verify_depth 1;`            |
| 内容： | `stream`， `server`              |

设置客户端证书链中的验证深度。



配置实例:

```
stream {
    upstream stream_backend {
         server backend1.example.com:12345;
         server backend2.example.com:12345;
         server backend3.example.com:12345;
    }

    server {
        listen                12345 ssl; #启用SSL
        proxy_pass            stream_backend; 
        
				# 添加SSL证书
        ssl_certificate       /etc/ssl/certs/server.crt;
        ssl_certificate_key   /etc/ssl/certs/server.key;
        
        #ssl_protocols and ssl_ciphers指令可用于限制连接并仅包括SSL/TLS的强版本和密码
        ssl_protocols         SSLv3 TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers           HIGH:!aNULL:!MD5;
        
        # SSL/TLS连接的会话参数的缓存可以减少握手次数，从而可以显着提高性能。
        # shared在所有工作进程之间共享缓存，这可以加快以后的连接速度，因为连接设置信息是已知的, 一个1 MB的共享缓存可以容纳大约4,000个会话
        ssl_session_cache     shared:SSL:20m;
        
        # 默认情况下，NGINX Plus将缓存的会话参数保留五分钟。将的值ssl_session_timeout增加到几个小时可以提高性能，因为重新使用缓存的会话参数可以减少耗时的握手次数。当您增加超时时，缓存需要更大，以容纳产生的更多缓存参数。对于以下示例中的4小时超时，适合使用20 MB的缓存：
        ssl_session_timeout   4h;
        
        # SSL握手操作会占用大量CPU。SSL握手的默认超时为60秒,不建议将此值设置得太低或太高
        ssl_handshake_timeout 30s;
        #...
     }
}
```





### ngx_stream_proxy_module



`ngx_stream_proxy_module`模块（1.9.0）允许在TCP，UDP（1.9.13）和UNIX域套接字进行代理数据流。

| 句法： | `proxy_bind *address* [transparent] | off;` |
| :----- | ------------------------------------------- |
| 默认： | -                                           |
| 内容： | `stream`， `server`                         |

使到代理服务器的传出连接源自指定的本地IP `address`。参数值可以包含变量（1.11.2）。该特殊值`off`取消了`proxy_bind`从先前配置级别继承的指令的效果，这使系统可以自动分配本地IP地址。



| 句法： | `**proxy_buffer_size** *size*;` |
| :----- | ------------------------------- |
| 默认： | `proxy_buffer_size 16k;`        |
| 内容： | `stream`， `server`             |

设置`*size*`用于从代理服务器读取数据的缓冲区大小。还设置`*size*`用于从客户端读取数据的缓冲区的。



| 句法： | `**proxy_connect_timeout** *time*;` |
| :----- | ----------------------------------- |
| 默认： | proxy_connect_timeout 60s；         |
| 内容： | `stream`， `server`                 |

定义用于与代理服务器建立连接的超时时间。



| 句法： | `**proxy_download_rate** *rate*;` |
| :----- | --------------------------------- |
| 默认： | `proxy_download_rate 0;`          |
| 内容： | `stream`， `server`               |

限制从代理服务器读取数据的速度。在`*rate*`被以每秒字节数指定。零值禁用速率限制。该限制是针对每个连接设置的，因此，如果nginx同时打开与代理服务器的两个连接，则总速率将是指定限制的两倍。



| 句法： | `**proxy_next_upstream** on | off;` |
| :----- | ----------------------------------- |
| 默认： | `proxy_next_upstream on;`           |
| 内容： | `stream`， `server`                 |

如果无法建立与代理服务器的连接，请确定是否将客户端连接传递给下一个服务器。



| 句法： | `**proxy_next_upstream_timeout** *time*;` |
| :----- | ----------------------------------------- |
| 默认： | `proxy_next_upstream_timeout 0;`          |
| 内容： | `stream`， `server`                       |

限制将连接传递到下一个服务器所允许的时间 。该`0`值将关闭此限制。



| 句法： | `**proxy_next_upstream_tries** *number*;` |
| :----- | ----------------------------------------- |
| 默认： | `proxy_next_upstream_tries 0;`            |
| 内容： | `stream`， `server`                       |

限制将连接传递到下一个服务器的可能尝试次数 。该`0`值将关闭此限制。



| 句法： | `**proxy_pass** *address*;` |
| :----- | --------------------------- |
| 默认： | -                           |
| 内容： | `server`                    |

设置代理服务器的地址。该地址可以指定为域名或IP地址以及端口：

| 句法： | `**proxy_protocol** on | off;` |
| :----- | ------------------------------ |
| 默认： | `proxy_protocol关闭；`         |
| 内容： | `stream`， `server`            |

启用proxy协议以连接到代理服务器。



| 句法： | `**proxy_requests** *number*;` |
| :----- | ------------------------------ |
| 默认： | `proxy_requests 0;`            |
| 内容： | `stream`， `server`            |

设置丢弃客户端和现有UDP流会话之间的绑定的客户端数据报的数量。收到指定数量的数据报后，来自同一客户端的下一个数据报将启动一个新会话。当所有客户端数据报都发送到代理服务器并接收到预期的[响应](https://nginx.org/en/docs/stream/ngx_stream_proxy_module.html#proxy_responses)数时，或者达到[超时](https://nginx.org/en/docs/stream/ngx_stream_proxy_module.html#proxy_timeout)时，会话终止 。



| 句法： | `**proxy_responses** *number*;` |
| :----- | ------------------------------- |
| 默认： | -                               |
| 内容： | `stream`， `server`             |

如果使用[UDP](https://nginx.org/en/docs/stream/ngx_stream_core_module.html#udp) 协议，则设置代理服务器响应客户端数据报而期望的数据报数。该数字用作会话终止的提示。默认情况下，数据报的数量不受限制。

如果指定零值，则不会响应。但是，如果收到响应并且会话仍未完成，则将处理该响应。



| 句法： | `**proxy_session_drop** on | off;` |
| :----- | ---------------------------------- |
| 默认： | `proxy_session_drop;`              |
| 内容： | `stream`， `server`                |

在将代理服务器从组中删除或标记为永久不可用后，可以终止与代理服务器的所有会话。可能由于 [重新解析](https://nginx.org/en/docs/stream/ngx_stream_core_module.html#resolver) 或使用API [`DELETE`](https://nginx.org/en/docs/http/ngx_http_api_module.html#deleteStreamUpstreamServer) 命令而发生。如果服务器[不正常](https://nginx.org/en/docs/stream/ngx_stream_upstream_hc_module.html#health_check) 或使用API [`PATCH`](https://nginx.org/en/docs/http/ngx_http_api_module.html#patchStreamUpstreamServer) 命令，则可以将其标记为永久不可用 。当为客户端或代理服务器处理下一个读取或写入事件时，每个会话都会终止。

> 该指令可作为我们的[商业订阅的](http://nginx.com/products/)一部分 。



| 句法： | `**proxy_socket_keepalive** on | off;` |
| :----- | -------------------------------------- |
| 默认： | `proxy_socket_keepalive off;`          |
| 内容： | `stream`， `server`                    |

为与代理服务器的传出连接配置“ TCP保持活动”行为。默认情况下，操作系统的设置对套接字有效。如果伪指令设置为值“ `on`”，则将为 `SO_KEEPALIVE`套接字打开套接字选项。



配置实例:

```
stream {
    resolver 192.168.10.142 status_zone=server_backend;

    upstream backend {
        zone stream_backend 64k;
        server mytest.nginx.com:80 resolve; 
        server 192.168.10.132:80;
    }
	   server {
	       listen 12345;
	       proxy_connect_timeout 1s;
	       proxy_timeout 1m;
	       proxy_pass example.com:12345;
	   }
	   
	   server {
	       listen 53 udp reuseport;
	       proxy_timeout 20s;
	       proxy_pass unix:/tmp/stream.socket;
	   }

    server {
        listen      192.168.10.153:1234;
        proxy_next_upstream on;
        proxy_pass  backend;
        status_zone server_backend;
        health_check;
    }
}
```





| 句法： | `**proxy_ssl** on | off;` |
| :----- | ------------------------- |
| 默认： | `proxy_ssl关闭；`         |
| 内容： | `stream`， `server`       |

启用SSL/TLS协议以连接到代理服务器。



| 句法： | `**proxy_ssl_certificate** *file*;` |
| :----- | ----------------------------------- |
| 默认： | -                                   |
| 内容： | `stream`， `server`                 |

`file`使用用于对代理服务器进行身份验证的PEM格式的证书。



| 句法： | `**proxy_ssl_certificate_key** *file*;` |
| :----- | --------------------------------------- |
| 默认： | -                                       |
| 内容： | `stream`， `server`                     |

指定`file`带有PEM格式的私钥，用于对代理服务器进行身份验证。



| 句法： | `**proxy_ssl_ciphers** *ciphers*;` |
| :----- | ---------------------------------- |
| 默认： | `proxy_ssl_ciphers默认值；`        |
| 内容： | `stream`， `server`                |

指定用于连接到代理服务器的启用密码。密码以OpenSSL库可以理解的格式指定。

可以使用“ `openssl ciphers`”命令查看完整列表。



| 句法： | `**proxy_ssl_conf_command** *command*;` |
| :----- | --------------------------------------- |
| 默认： | -                                       |
| 内容： | `stream`， `server`                     |

与代理服务器建立连接时 设置任意的OpenSSL配置 [命令](https://www.openssl.org/docs/man1.1.1/man3/SSL_CONF_cmd.html)。

> 使用OpenSSL 1.0.2或更高版本时支持该指令。



`proxy_ssl_conf_command`可以在同一级别上指定 多个指令。当且仅当`proxy_ssl_conf_command`当前级别上未定义任何指令时，这些指令才从先前的配置级别继承。



> 请注意，直接配置OpenSSL可能会导致意外行为。



| 句法： | `**proxy_ssl_crl** *file*;` |
| :----- | --------------------------- |
| 默认： | -                           |
| 内容： | `stream`， `server`         |

`*file*`以PEM格式 指定具有已吊销证书（CRL） 的证书，用于[验证](https://nginx.org/en/docs/stream/ngx_stream_proxy_module.html#proxy_ssl_verify)代理服务器的证书。



| 句法： | `**proxy_ssl_name** *name*;`       |
| :----- | ---------------------------------- |
| 默认： | `proxy_pass的proxy_ssl_name主机；` |
| 内容： | `stream`， `server`                |

允许覆盖用于[验证](https://nginx.org/en/docs/stream/ngx_stream_proxy_module.html#proxy_ssl_verify) 代理服务器证书的服务器名称， 并在 与代理服务器建立连接时[通过SNI传递](https://nginx.org/en/docs/stream/ngx_stream_proxy_module.html#proxy_ssl_server_name)。也可以使用变量（1.11.3）指定服务器名称。

默认情况下，使用[proxy_pass](https://nginx.org/en/docs/stream/ngx_stream_proxy_module.html#proxy_pass)地址的主机部分。



| 句法： | `**proxy_ssl_password_file** *file*;` |
| :----- | ------------------------------------- |
| 默认： | -                                     |
| 内容： | `stream`， `server`                   |

`*file*`为[私钥](https://nginx.org/en/docs/stream/ngx_stream_proxy_module.html#proxy_ssl_certificate_key) 指定一个带有密码短语的密码， 其中每个密码短语都在单独的行上指定。加载密钥时依次尝试使用密码短语。



| 句法： | `**proxy_ssl_protocols** [SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2] [TLSv1.3];` |
| :----- | ------------------------------------------------------------ |
| 默认： | `proxy_ssl_protocols TLSv1 TLSv1.1 TLSv1.2;`                 |
| 内容： | `stream`， `server`                                          |

启用指定的协议以连接到代理服务器。



| 句法： | `**proxy_ssl_server_name** on | off;` |
| :----- | ------------------------------------- |
| 默认： | `proxy_ssl_server_name off；`         |
| 内容： | `stream`， `server`                   |

与代理服务器建立连接时， 启用或禁用通过[TLS服务器名称指示扩展名](http://en.wikipedia.org/wiki/Server_Name_Indication)（SNI，RFC 6066）传递服务器名称 。



| 句法： | `**proxy_ssl_session_reuse** on | off;` |
| :----- | --------------------------------------- |
| 默认： | `proxy_ssl_session_reuse on;`           |
| 内容： | `stream`， `server`                     |

确定在使用代理服务器时是否可以重用SSL会话。如果错误“ `SSL3_GET_FINISHED:digest check failed`”出现在日志中，请尝试禁用会话重用。



| 句法： | `**proxy_ssl_trusted_certificate** *file*;` |
| :----- | ------------------------------------------- |
| 默认： | -                                           |
| 内容： | `stream`， `server`                         |

指定`*file*`带有PEM格式的受信任CA证书的CA证书，用于[验证](https://nginx.org/en/docs/stream/ngx_stream_proxy_module.html#proxy_ssl_verify) 代理服务器的证书。



| 句法： | `**proxy_ssl_verify** on | off;` |
| :----- | -------------------------------- |
| 默认： | `proxy_ssl_verify关闭；`         |
| 内容： | `stream`， `server`              |

启用或禁用代理服务器证书的验证。



| 句法： | `**proxy_ssl_verify_depth** *number*;` |
| :----- | -------------------------------------- |
| 默认： | `proxy_ssl_verify_depth 1;`            |
| 内容： | `stream`， `server`                    |

设置代理服务器证书链中的验证深度。



| 句法： | `**proxy_timeout** *timeout*;` |
| :----- | ------------------------------ |
| 默认： | `proxy_timeout 10m;`           |
| 内容： | `stream`， `server`            |

`*timeout*`在客户端或代理服务器连接上的两个连续读取或写入操作之间设置。如果在此时间内没有数据传输，则连接将关闭。



| 句法： | `**proxy_upload_rate** *rate*;` |
| :----- | ------------------------------- |
| 默认： | `proxy_upload_rate 0;`          |
| 内容： | `stream`， `server`             |

该指令出现在1.9.3版中。

限制从客户端读取数据的速度。在`*rate*`被以每秒字节数指定。零值禁用速率限制。该限制是针对每个连接设置的，因此，如果客户端同时打开两个连接，则总速率将是指定限制的两倍。

参数值可以包含变量（1.17.0）。在应根据特定条件限制费率的情况下，这可能会很有用：

```
map $slow $rate {
    1     4k;
    2     8k;
}

proxy_upload_rate $rate;
```



配置实例:

```
stream {
    upstream backend {
        server backend1.example.com:12345;
        server backend2.example.com:12345;
        server backend3.example.com:12345;
   }

    server {
        listen     12345;
        proxy_pass backend;
        proxy_ssl  on;

        proxy_ssl_certificate         /etc/ssl/certs/backend.crt;
        proxy_ssl_certificate_key     /etc/ssl/certs/backend.key;
        proxy_ssl_protocols           TLSv1 TLSv1.1 TLSv1.2;
        proxy_ssl_ciphers             HIGH:!aNULL:!MD5;
        proxy_ssl_trusted_certificate /etc/ssl/certs/trusted_ca_cert.crt;

        proxy_ssl_verify        on;
        proxy_ssl_verify_depth  2;
        proxy_ssl_session_reuse on;
    }
}
```





### ngx_http_api_module

`ngx_http_api_module`模块（1.13.3）提供REST API访问的各种状态信息，关于即时配置上游服务器组，并管理 键值对，而无需重新配置Nginx的。



| 句法： | `api [write=on|off];` |
| :----- | --------------------- |
| 默认： | —                     |
| 内容： | `location`            |

打开周围位置的REST API接口。访问此位置应受到 [限制](https://nginx.org/en/docs/http/ngx_http_core_module.html#satisfy)。

该`write`参数确定API是只读的还是读写的。默认情况下，API是只读的。



所有API请求都应在URI中包含受支持的API版本。如果请求URI等于位置前缀，则返回支持的API版本列表。当前的API版本是“ `6`”。

`fields`请求行中 的可选“ ”参数指定将输出所请求对象的哪些字段：

> ```
> http://127.0.0.1/api/6/nginx?fields=version,build
> ```



| 句法： | `status_zone zone;`                    |
| :----- | -------------------------------------- |
| 默认： | —                                      |
| 内容： | `server`，`location`，`if in location` |

该指令出现在1.13.12版中。

启用对指定的中虚拟[http](https://nginx.org/en/docs/http/ngx_http_core_module.html#server) 或 [stream](https://nginx.org/en/docs/stream/ngx_stream_core_module.html#server)服务器状态信息的收集 `zone`。多个服务器可以共享同一区域。



从1.17.0开始，可以按[lcation](https://nginx.org/en/docs/http/ngx_http_core_module.html#location)收集状态信息。该特殊值`off`禁用嵌套位置块中的统计信息收集。注意，统计是在处理结束的位置的上下文中收集的。如果在请求处理期间发生[内部重定向](https://nginx.org/en/docs/http/ngx_http_core_module.html#internal)，则它可能与原始位置不同 。					



| 句法： | `zone name [size];` |
| :----- | ------------------- |
| 默认： | —                   |
| 内容： | `upstream`          |

该指令出现在1.9.0版中。

定义共享内存区域的`name`和`size`，以保留在工作进程之间共享组的配置和运行时状态。几个组可以共享同一区域。在这种情况下，`size`仅指定一次就足够。



所有API请求都在URI中包含受支持的API[版本](https://nginx.org/en/docs/http/ngx_http_api_module.html#api_version)。具有此配置的API请求示例：

> ```
> http://127.0.0.1/api/6/
> http://127.0.0.1/api/6/nginx
> http://127.0.0.1/api/6/connections
> http://127.0.0.1/api/6/http/requests
> http://127.0.0.1/api/6/http/server_zones/server_backend
> http://127.0.0.1/api/6/http/caches/cache_backend
> http://127.0.0.1/api/6/http/upstreams/backend
> http://127.0.0.1/api/6/http/upstreams/backend/servers/
> http://127.0.0.1/api/6/http/upstreams/backend/servers/1
> http://127.0.0.1/api/6/http/keyvals/one?key=arg1
> http://127.0.0.1/api/6/stream/
> http://127.0.0.1/api/6/stream/server_zones/server_backend
> http://127.0.0.1/api/6/stream/upstreams/
> http://127.0.0.1/api/6/stream/upstreams/backend
> http://127.0.0.1/api/6/stream/upstreams/backend/servers/1
> ```



配置示例:

```
http {
    upstream backend {
        zone http_backend 64k;

        server backend1.example.com weight=5;
        server backend2.example.com;
    }

    proxy_cache_path /data/nginx/cache_backend keys_zone=cache_backend:10m;

    server {
        server_name backend.example.com;

        location / {
            proxy_pass  http://backend;
            proxy_cache cache_backend;

            health_check;
        }

        status_zone server_backend;
    }

    keyval_zone zone=one:32k state=one.keyval;
    keyval $arg_text $text zone=one;

    server {
        listen 127.0.0.1;

        location /api {
            api write=on;
            allow 127.0.0.1;
            deny all;
        }
    }
}

stream {
    upstream backend {
        zone stream_backend 64k;

        server backend1.example.com:12345 weight=5;
        server backend2.example.com:12345;
    }

    server {
        listen      127.0.0.1:12345;
        proxy_pass  backend;
        status_zone server_backend;
        health_check;
    }
}
```



## nginx正向代理



### 环境介绍

> 代理服务器系统环境为：centos
>
> nginx代理服务器为：192.168.10.10
>
> 测试客户端为局域网内任意windows电脑或Linux电脑



### 正向代理简介

​    nginx不仅可以做反向代理，还能作正向代理来进行上网等功能。如果把局域网外的Internet想象成一个巨大的资源库，则局域网中的客户端要访问Internet，则需要通过代理服务器来访问，这种代理服务就称为正向代理



### nginx正向代理的配置

​    现在的网站基本上都是https，要解决既能访问http80端口也能访问https443端口的网站，需要配置两个SERVER节点，一个处理HTTP转发，另一个处理HTTPS转发，而客户端都通过HTTP来访问代理，通过访问代理不同的端口，来区分HTTP和HTTPS请求。

```js
[root@localhost ~]# vim /usr/local/nginx-1.12.1/conf/nginx.conf
server {
    resolver 114.114.114.114;       #指定DNS服务器IP地址 
    listen 80;
    location / {
        proxy_pass http://$host$request_uri;     #设定代理服务器的协议和地址 
                proxy_set_header HOST $host;
                proxy_buffers 256 4k;
                proxy_max_temp_file_size 0k;
                proxy_connect_timeout 30;
                proxy_send_timeout 60;
                proxy_read_timeout 60;
                proxy_next_upstream error timeout invalid_header http_502;
    }
}
server {
    resolver 114.114.114.114;       #指定DNS服务器IP地址 
    listen 443;
    location / {
       proxy_pass https://$host$request_uri;    #设定代理服务器的协议和地址 
             proxy_buffers 256 4k;
             proxy_max_temp_file_size 0k;
       proxy_connect_timeout 30;
       proxy_send_timeout 60;
       proxy_read_timeout 60;
       proxy_next_upstream error timeout invalid_header http_502;
    }
}
[root@localhost ~]# /usr/local/nginx-1.12.1/sbin/nginx -s reload
```

### Linux客户端访问测试

http的访问测试

```js
[root@localhost ~]# curl -I --proxy 192.168.10.10:80 www.baidu.com
HTTP/1.1 200 OK
Server: nginx/1.12.1
Date: Mon, 11 Jun 2018 15:37:47 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Thu, 31 May 2018 09:28:16 GMT
Connection: keep-alive
ETag: "5b0fc030-264"
Accept-Ranges: bytes
https的访问测试
[root@localhost ~]# curl -I --proxy 192.168.10.10:443 www.baidu.com
HTTP/1.1 200 OK
Server: nginx/1.12.1
Date: Mon, 11 Jun 2018 15:38:07 GMT
Content-Type: text/html
Content-Length: 277
Connection: keep-alive
Accept-Ranges: bytes
Cache-Control: private, no-cache, no-store, proxy-revalidate, no-transform
Etag: "575e1f5c-115"
Last-Modified: Mon, 13 Jun 2016 02:50:04 GMT
Pragma: no-cache
```

### 设置Linux客户端全局代理

```
[root@localhost ~]# vim /etc/profile
export http_proxy='192.168.10.10:80'
export http_proxy='192.168.10.10:443'
export ftp_proxy='192.168.10.10:80'
[root@localhost ~]# source /etc/profile
[root@localhost ~]# curl -I www.baidu.com:80
HTTP/1.1 200 OK
Server: nginx/1.12.1
Date: Mon, 11 Jun 2018 16:10:18 GMT
Content-Type: text/html
Content-Length: 277
Connection: keep-alive
Accept-Ranges: bytes
Cache-Control: private, no-cache, no-store, proxy-revalidate, no-transform
Etag: "575e1f5c-115"
Last-Modified: Mon, 13 Jun 2016 02:50:04 GMT
Pragma: no-cache
[root@localhost ~]# curl -I www.baidu.com:443
HTTP/1.1 200 OK
Server: nginx/1.12.1
Date: Mon, 11 Jun 2018 16:10:27 GMT
Content-Type: text/html
Content-Length: 277
Connection: keep-alive
Accept-Ranges: bytes
Cache-Control: private, no-cache, no-store, proxy-revalidate, no-transform
Etag: "575e1f59-115"
Last-Modified: Mon, 13 Jun 2016 02:50:01 GMT
Pragma: no-cache
```

上面结果就说明服务端nginx正向代理和客户端使用nginx做为全局代理设置成功。





## Tip:



### Openssl version 错误问题

在Centos7上编译安装openssl后，运行`openssl version`出现如下错误：

```bash
openssl: error while loading shared libraries: libssl.so.1.1: cannot open shared object file: No such file or directory
```

这是由于openssl库的位置不正确造成的。

#### 解决方法：

在root用户下执行：

```bash
ln -s /usr/local/lib64/libssl.so.1.1 /usr/lib64/libssl.so.1.1
ln -s /usr/local/lib64/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
```



### SSL证书期限查询

用 xshell 或者 SecureCRT工具登录后，进入证书目录，使用 openssl 命令进行查看：

```
# openssl x509 -in signed.crt -noout -dates
```
