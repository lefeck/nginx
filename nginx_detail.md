# Nginx模块分类

　　针对不同的具体场景，nginx模块会细分为子模块;在特定的复杂的场景下这些子模块会新增新的特性和功能;下面我们来看下nginx模块是怎样划分为子模块的;

　　上一节中我们谈到了ngx_module_t 是每一个模块必须具备的数据结构;其中它有一个成员叫type;这个type其实也就定义了这个模块它是属于哪一种类型的模块;

　　那么一共有哪些类型的模块呢?

![module](/Users/jinhuaiwang/Desktop/module.png)

* 第一类模块叫ngx_core_module 叫核心模块；核心模块里面会有一类核心模块；比如events，http，mail或者stream;它们本身会定义出新的类型模块，所以可以看出来nginx框架代码并没有定义出什么http业务或者stream业务，而是通过某一类**ngx_core_module它可以独立的去定义出新的子类型模块**。可以看出nginx的灵活性是非常强的，如果新出了一类应用可以新增一个ngx_core_module来定义新的模块。

* 还有个独立的模块叫ngx_conf_module，这个模块它只负责去解析我们的nginx.conf文件;

* 它内聚为ngx_event_module 事件模块，那么每一类模块中它总是会有一些通用的共性的部分；这类通用共性的部分，我们会在这类模块中其中第一个模块通常加上_core关键字来把通用的模块放到里面，比如event_core，ngx_http_core_module，ngx_mail_core_module，ngx_stream_core_module，那么就像之前所说的每一个core都有一个index，表示它的顺序;所以每一个子类型中所有的事件模块，所有的http模块它们同样是有顺序的。每一个core_module一定是排名在第一位的。因为它定义了所有子类型模块共同具有的一些特性。

* http模块，ngx_http_core_module它已经定义了许多特色的规则;比如说当一个http请求进入nginx的时候;我们需要为它生成响应;那么为请求生成相应的模块我们叫它请求处理模块;当我们生成响应把响应发送给浏览器的时候我们可能需要对响应中的一些文件做一些特定的处理比如说我发的是一个css文件;那么对这个css文件做一次gzip压缩;那么我们传输的效率将会提升很多，如果我发送的是图片，我需要对图片做裁剪，缩放;那么我用响应过滤模块来处理，响应过滤模块主要对响应做二次处理;还有一类模块叫upsteam相关模块;那么upsteam顾名思义就是我们的上游，就是说当nginx作为反向代理或者说作为正向代理把请求传递给相关的服务做处理的时候 ;那么这类模块都会有upsteam相关的字样;它们专注于在一个请求内部去访问上游服务;其它的mail或者stream相对来说比较简单不再一一细说;

下面我通过之前在编译nginx的时候所看到的源代码文件给大家分析下这些目录是怎样对应到子类型模块中的;

现在进入nginx的安装目录，在安装目录中有个src目录，该目录有一个core目录，它只是nginx的核心框架代码，并不是指nginx的core_module。

```shell
[root@localhost src]# ll
total 20
drwxr-xr-x 2 1001 1001 4096 Jan 28 16:47 core
drwxr-xr-x 3 1001 1001 4096 Jan 28 16:47 event
drwxr-xr-x 4 1001 1001 4096 Jan 28 16:47 http
drwxr-xr-x 2 1001 1001 4096 Jan 28 16:47 mail
drwxr-xr-x 2 1001 1001   74 Jan 28 16:47 misc
drwxr-xr-x 3 1001 1001   18 Jul  7  2020 os
drwxr-xr-x 2 1001 1001 4096 Jul  7  2020 stream
[root@localhost src]# 
```

 　这里而event，http，stream，mail等。所有子类型的模块都在这里，先看 http模块:

```shell
[root@localhost src]# cd http/
[root@localhost http]# ll
total 932
drwxr-xr-x 3 1001 1001   4096 Jan 28 16:47 modules
-rw-r--r-- 1 1001 1001  52447 Jul  7  2020 ngx_http.c
-rw-r--r-- 1 1001 1001   7146 Jul  7  2020 ngx_http_cache.h
-rw-r--r-- 1 1001 1001   2565 Jul  7  2020 ngx_http_config.h
-rw-r--r-- 1 1001 1001   9451 Jul  7  2020 ngx_http_copy_filter_module.c
-rw-r--r-- 1 1001 1001 142370 Jul  7  2020 ngx_http_core_module.c
-rw-r--r-- 1 1001 1001  19026 Jul  7  2020 ngx_http_core_module.h
-rw-r--r-- 1 1001 1001  70553 Jul  7  2020 ngx_http_file_cache.c
-rw-r--r-- 1 1001 1001   5946 Jul  7  2020 ngx_http.h
-rw-r--r-- 1 1001 1001  19498 Jul  7  2020 ngx_http_header_filter_module.c
-rw-r--r-- 1 1001 1001  60174 Jul  7  2020 ngx_http_parse.c
-rw-r--r-- 1 1001 1001   6662 Jul  7  2020 ngx_http_postpone_filter_module.c
-rw-r--r-- 1 1001 1001  29482 Jul  7  2020 ngx_http_request_body.c
-rw-r--r-- 1 1001 1001  96483 Jul  7  2020 ngx_http_request.c
-rw-r--r-- 1 1001 1001  20892 Jul  7  2020 ngx_http_request.h
-rw-r--r-- 1 1001 1001  44806 Jul  7  2020 ngx_http_script.c
-rw-r--r-- 1 1001 1001   8114 Jul  7  2020 ngx_http_script.h
-rw-r--r-- 1 1001 1001  22001 Jul  7  2020 ngx_http_special_response.c
-rw-r--r-- 1 1001 1001 166206 Jul  7  2020 ngx_http_upstream.c
-rw-r--r-- 1 1001 1001  15570 Jul  7  2020 ngx_http_upstream.h
-rw-r--r-- 1 1001 1001  21361 Jul  7  2020 ngx_http_upstream_round_robin.c
-rw-r--r-- 1 1001 1001   5089 Jul  7  2020 ngx_http_upstream_round_robin.h
-rw-r--r-- 1 1001 1001  66752 Jul  7  2020 ngx_http_variables.c
-rw-r--r-- 1 1001 1001   3188 Jul  7  2020 ngx_http_variables.h
-rw-r--r-- 1 1001 1001  10566 Jul  7  2020 ngx_http_write_filter_module.c
drwxr-xr-x 2 1001 1001    260 Jan 28 16:47 v2
```

 		在http模块中，会看到一些框架代码，这类代码不算模块，只是辅助于核心流程的的我们不必关心。

　　 但是每一类子模块中都有一个核心模块，它定义了我们http模块的工作方式。它也是放在这个目录下的。比如说ngx_http.c，我们看下这个文件;

```c
[root@localhost http]# vi ngx_http.c 
......
ngx_module_t  ngx_http_module = {
    NGX_MODULE_V1,
    &ngx_http_module_ctx,                  /* module context */
    ngx_http_commands,                     /* module directives */
    NGX_CORE_MODULE,                       /* module type */
    NULL,                                  /* init master */
    NULL,                                  /* init module */
    NULL,                                  /* init process */
    NULL,                                  /* init thread */
    NULL,                                  /* exit thread */
    NULL,                                  /* exit process */
    NULL,                                  /* exit master */
    NGX_MODULE_V1_PADDING
};
......
```

可以看到在ngx_module_t结构体中，它的type类型为ngx_core_module，它定义了所有的http模块;

所有框架类的代码，包括nginx的http_core_module都是放在这个目录下的;

```shell
[root@localhost http]# ls
modules                        ngx_http_file_cache.c              ngx_http_request.h               ngx_http_upstream_round_robin.h
ngx_http.c                     ngx_http.h                         ngx_http_script.c                ngx_http_variables.c
ngx_http_cache.h               ngx_http_header_filter_module.c    ngx_http_script.h                ngx_http_variables.h
ngx_http_config.h              ngx_http_parse.c                   ngx_http_special_response.c      ngx_http_write_filter_module.c
ngx_http_copy_filter_module.c  ngx_http_postpone_filter_module.c  ngx_http_upstream.c              v2
ngx_http_core_module.c         ngx_http_request_body.c            ngx_http_upstream.h
ngx_http_core_module.h         ngx_http_request.c                 ngx_http_upstream_round_robin.c
```

而官方提供的非框架的也就是一些可有可无的模块，我们把它放到了modules目录下;

　　![img](https://img2020.cnblogs.com/i-beta/1862379/202003/1862379-20200310140602592-1061313580.png)

可以看到这里有许多模块，我们谈到这些模块分为三类:

* 处理请求生成响应的模块;不带关键字叫filter和upsteam;

* 响应过滤模块，响应过滤的它的所有模块会有一个关键字叫filter;

* 还有一类与上游服务器发生交互的;upsteam相关模块;带有;upsteam关键字的;它们都是做负载均衡相关的一些工作;

　

# worker进程间通信方式

　　Nginx是一个多进程程序，不同的worker进程之间，如果想要共享数据，那么只能通过共享内存；下面我们来看一看Nginx的共享内存是怎么使用的?

<img src="https://img2020.cnblogs.com/i-beta/1862379/202003/1862379-20200311135552701-865674186.png" alt="img" style="zoom:50%;"/>



nginx的进程间的通讯方式主要有两种:

* 第一种是信号，之前我们在说如何管理nginx的过程中已经比较详细的介绍过了；

* 共享内存:如果需要做数据的同步，只能通过共享内存。

  所谓共享内存，也就是打开了一块内存，比如说10M，一整块0到10M之间，多个worker进程之间可以同时的访问它；包括读取和写入，那么为了使用好这样一个共享内存就会引入另外两个问题；

  ​		第一个问题：就是**锁**，因为多个worker进程同时操作一块内存，一定会存在竞争关系；所以我们需要加锁。在Nginx的锁中，在早期，它还有基于**信号量的锁**。

  ​		信号量是nginx比较久远的进程同步方式，它会导致你的进程进入休眠状态；也就是发送了主动切换；而现在大多数操作系统版本中，**nginx所使用的锁都是自旋锁**。而不会基于信号量；自旋锁也就是说当这个锁的条件没有满足比如说，这块内存现在被1号worker进程使用，2号worker进程需要去获取锁的时候，只要1号进程没有释放锁，2号进程会一直请求这把锁。所以使用自旋锁要求所有的nginx模块，必须快速地使用共享内存，也就是快速的取得锁以后，快速的释放锁，一旦发现有第三方模块不遵守这样的规则，就可能会导致出现死锁或者说性能下降的问题；那么有了这样的一块共享内存。

  ​		第二个问题：因为一整块共享内存是往往是给许多对象同时使用的；如果我们在模块中手动的去编写，分配把这些内存给到不同的对象，这是非常繁琐的；所以这个时候我们使用了Slab内存管理器。

那么Nginx哪些模块使用了共享内存?

<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-06 下午8.29.27.png" alt="截屏2021-03-06 下午8.29.27" style="zoom: 33%;" />

我对官方常用的Nginx模块使用了共享内存做了一个总结:

使用共享内存主要使用了这两种数据结构:

* rbtree`(红黑树)`：比如我们想做限速和流控等场景时，我们是不能容忍内存中一个worker进程对某一个用户触发了流控，而其它worker进程还不知道。所以我们只能在共享内存中做。
* 红黑树特点：插入删除非常快，当然也可以做遍历，所以如下模块都有该特点。

<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-06 下午8.32.12.png" alt="截屏2021-03-06 下午8.32.12" style="zoom: 50%;" />

比如我现在发现了一个客户端我对它限速，限速如果达到了，我需要把它从我的数据结构容器中移除，都需要非常的快速；

* 单链表；也就是说我只需要把这些共享的元素串联起来就可以了；比如:

<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-06 下午8.33.02.png" alt="截屏2021-03-06 下午8.33.02" style="zoom:50%;" />

 

我们来看个非常复杂的例子就是:ngx_http_lua_api

　　ngx_http_lua_api 这个模块其实是openresty的核心模块；openresty在这个模块中定义了一个SDK，这个SDK叫lua_shared_dict；当这个指令出现的时候，它会分配一块共享内存；比如说这里我们分了10m；这个共享内存会有一个名称叫做dogs；

<img src="https://img2020.cnblogs.com/i-beta/1862379/202003/1862379-20200311160133302-1121407535.png" alt="img" style="zoom:50%;" />

　　接下来我们在lua代码中，比如content_by_lua_block；对应着我们nginx收到了 set这个url的时候；需要做一些什么样的事情，我们首先从dogs共享内存中取出；然后设置了一个key-value； Jim-8；然后向客户端返回我已存储；

　　然后在get请求中我们把Jim的值8取出来；返回给用户；

　　那么在这一段代码中尼，我们同时使用了我们刚刚使用的红黑树和单链表 那么这个lua_shared_dict dogs 10m中使用红黑树来保存每一个key-value；红黑树中每一个节点就是Jim它的value就是8；那么为什么我还需要一个链表尼?是因为这个10m是有限的；当我们的Lua代码涉及到了我们的应用业务代码；很容易就超过了10m的限制；当我们出现10m限制的时候尼，会有很多种处理方法；比如让它写入失败；但是lua_shared_dict 采用了另外一种实现方式它用lru淘汰；也就是我最早set，最早get 长时间不用的那一个节点；比如前面还有Jim等于7或者等于6的节点；会优先被淘汰掉；当已经达到10m的最大值时；所以这个lua_shared_dict同时满足了红黑树和链表；

　　共享内存是nginx跨worker进程通讯的最有效的手段；只要我们需要让一段业务逻辑在多个worker进程中同时生效；比如很多在做集群的流控上；那么必须使用共享内存；而不能在每一个worker内存中去操作；



# 用好共享内存工具:Slab管理器

​		刚刚谈到nginx不同的worker进程间需要共享信息的时候，需要通过共享内存；我们也谈到了共享内存上可以使用链表或者红黑树这样的数据结构；但是每一个红黑树上有许多节点；每一个节点你都需要分配内存去存放；那么怎么样把一整块共享内存切割成一小块给红黑树上的每一个节点使用呢?

　　下面来看下Slab内存分配管理是怎么样应用于共享内存上的，首先我们来看下Slab内存管理是怎么样的一种形式。

<img src="https://img2020.cnblogs.com/i-beta/1862379/202003/1862379-20200311162834921-56306655.png" alt="img" style="zoom:50%;" />

​		它首先会把整块的共享内存分为很多页面，那么每个页面例如4k，会切分为很多slot，比如32字节是一种slot，64字节又是一种slot，128字节又是一种slot，那么这些slot是以乘2的方式向上增长的。如果现在有一个51字节需要分配的内存会放到哪里呢？会放于小于它最大的一个slot的一个环节；比如说64字节；所以上图中slot就是指向不同大小的块；所以这样的一种数据结构有一个特点：会有内存的浪费的，51字节它会用64字节来存放；其它的13字节就浪费了；那么最多会有多少内存消耗呢？会有2倍，这种使用的方式叫做Bestfit。

​		Bestfit这种分配内存的方式有什么好处呢？它适合小对象；如果我们要分配的对象的内存非常小，比如小于一个页面的大小，就非常合适；因为它很少有碎片，那么每分配一块内存，就会沿着还未分配的空白的地方继续使用就可以了；当一个页面满了以后，我再拿一个空白的页面继续给此类slot大小的内存继续使用就可以。那么有时候我分配在某段内存上的数据结构它是固定的，甚至需要初始化；那么这样的话，原先的数据结构都还在；当我重复使用的话，也避免了初始化；Slab内存管理中，我们怎么做数据的监控和统计呢?

　　那么tengine上有一个模块叫做slab_stat，slab_stat可以帮我们看不同的slot；

<img src="https://img2020.cnblogs.com/i-beta/1862379/202003/1862379-20200311170228891-2027957008.png" alt="img" style="zoom:50%;" />

 下面我们来看下怎么样在openresty的场景下去使用tengine上的slab_stat模块

　　首先我们打开tengine的页面  http://tengine.taobao.org/document/ngx_slab_stat.html

　　但是会发现在这个模块上没有github的地址，也就是说它没有作为一个独立的模块提供出来，那这个时候该怎么办呢?

　　把tengine下载下来，解压， 进入ngx_slab_stat目录，可以看到这是一个标准的nginx第三方模块；

```
[root@localhost ~]# wget https://tengine.taobao.org/download/tengine-2.3.2.tar.gz
[root@localhost ~]# tar -zxf tengine-2.3.2.tar.gz
[root@localhost ~]# cd  tengine-2.3.2/modules/ngx_slab_stat/
[root@localhost ngx_slab_stat]# ll
total 44
-rw-rw-r-- 1 root root   204 Sep  5  2019 config
-rw-rw-r-- 1 root root  6627 Sep  5  2019 ngx_http_slab_stat_module.c
-rw-rw-r-- 1 root root  3465 Sep  5  2019 README.cn
-rw-rw-r-- 1 root root  3501 Sep  5  2019 README.md
-rw-rw-r-- 1 root root 21430 Sep  5  2019 slab_stat.patch
drwxrwxr-x 2 root root    20 Sep  5  2019 t
```

​		回到 openresty中，让openresty编译的时候，把tengine的slab_stat模块编译进去，执行configure的时候，可以添加一个参数--add-module=，制定安装的第三方模块路径名称，那么现在开始编译openresty；

 ```
[root@localhost openresty-1.13.6.2]# ./configure --add-module=/root/tengine-2.3.2/modules/ngx_slab_stat/
[root@localhost openresty-1.13.6.2]# make 
#备份原来的nginx执行程序
[root@localhost openresty-1.13.6.2]# cp /usr/local/openresty-1.13.6.2/sbin/nginx /usr/local/openresty-1.13.6.2/sbin/nginx.bak
# 将新编译的nginx执行程序复制到/usr/local/openresty-1.13.6.2/sbin/目录下
[root@localhost openresty-1.13.6.2]# cp /opt/nginx/nginx /usr/local/openresty-1.13.6.2/sbin/
 ```

验证是否成功安装 `ngx_slab_stat`

```
nginx -V
```

现在openresty已经安装完成了，已经包含了ngx_slab_stat模块

 nginx.conf 配置文件代码:

```
lua_shared_dict dogs 10m;
server {
  listen 8080;
  server_name localhost;

​  #charset koi8-r;

​  #access_log logs/host.access.log main；
​  location = /slab_stat{
​   slab_stat;
​  }
​  location /set{
​      content_by_lua_block{
​          local dogs=ngx.shared.dogs
​          dogs:set("Jim"，8)
​          ngx.say("STORED");
​      }
​  }

​  location /get {
​      content_by_lua_block{
​          local dogs=ngx.shared.dogs
​          ngx.say(dogs:get("Jim"));
​      }
​  }
​  location / {
​    #proxy_set_header Host host;       #proxy_set_header X-Real-IPhost；       roxy_set_header X-Real-IPremote_addr；
​    #proxy_set_header X-Forwarded-For proxy_add_x_forwarded_for;       #proxy_cache _cache；       #proxy_cache_keyproxy_add_x_forwarded_for；       #proxy_cache _cache；       #proxy_cache_keyhost𝑢𝑟𝑖uriis_args&args；
​    #proxy_cache_valid 200 304 302 1d;
​    #proxy_pass http://local;
​  }
}

```

配置完，把nginx启动看它的执行效果；

每一个slot及其slot对应的大小；分配了多少个，使用了多少个，失败了多少个；

所谓分配就是10m是一个非常大的共享内存，它会划分很多个页面；对于比较小的比如32字节，一个页面可以有128个；这里127可用，已经使用了一个；　　![img](https://img2020.cnblogs.com/i-beta/1862379/202003/1862379-20200312162608398-1523160924.png)

　　总结：以上我们介绍了Slab内存的使用方法:slab使用了Bestfit思想，它也是Linux操作系统经常使用的内存分配方式；

　　那么通常我们在使用共享内存时，都需要使用slab_stat去分配相应的内存给对象，再使用上层的数据结构来维护这些数据对象；

　　



# 哈希表的max_size与bucket_size如何配置

　　Nginx容器是许多nginx高级功能的实现基础，即使不需要编辑第三方模块或者查看nginx的源代码，但需要变更我们的nginx配置文件，以达到最大化的性能。

​		我们也需要了解Nginx容器是怎么样使用的，下面来看下nginx最主要的内部容器。　　

<img src="https://img2020.cnblogs.com/i-beta/1862379/202003/1862379-20200312170850695-444175995.png" alt="img" style="zoom:50%;" />

​		首先就是数组，也就是ngx_array_t，这里的数组和我们平常所理解的数组有所不同。它是多块连续内存，其中每一块连续内存中可以存放很多元素。而链表就是ngx_list_t，队列是ngx_queue_t，这些结构体它们所实现的功能是类似的，只不过它们的操作方法会有所不同。

　　而nginx中最重要的两个数据结构是哈希表和红黑树。基数数是自平衡排序二叉树中的一种;只不过它的key只能是整型;像geo等模块在使用基数数;其它使用基数数的场景并不多;



**哈希表**



**哈希表使用的注意事项：**

​		那么nginx的哈希表跟我们正常所见到的哈希表还是有所不同的，只是从它的实现层面来看，和正常的哈希表是相似的，就是每一个元素会顺序的放到一块连续的内存当中。每一个元素它的key同样是通过哈希函数来映射的。

　　如下:

　　![img](https://img2020.cnblogs.com/i-beta/1862379/202003/1862379-20200312172336560-31515558.png)

 

 　这是一段存放哈希表内容的连续内存;那么如下的一个结构体就是哈希表的描述;

　　　　![img](https://img2020.cnblogs.com/i-beta/1862379/202003/1862379-20200312172601274-2027195456.png)

 

 

　　　　每一段大小的内容如下:

　　　　![img](https://img2020.cnblogs.com/i-beta/1862379/202003/1862379-20200312172706017-46329412.png)

 

 

　　　　它的name就是它的key;它的value是一个指针;指向我们实际的内容:

　　　　![img](https://img2020.cnblogs.com/i-beta/1862379/202003/1862379-20200312172841677-245808033.png)

 

 　　

　　　　一个key和另外一个key是连续放在一起的;这和大部分的哈希表是一样的;

　　　　完整图示如下:

　　　　![img](https://img2020.cnblogs.com/i-beta/1862379/202003/1862379-20200312173019190-2037288113.png)

 

 哈希表与通常的哈希表有哪里不同呢?

<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-07 上午10.20.47.png" alt="截屏2021-03-07 上午10.20.47" style="zoom: 33%;" />



​		它的应用场景不同，它仅仅应用于静态不变的内容，也就是说我们在运行过程中，这个哈希表通常是不会出现插入和删除的。

　　 也就是说我们nginx刚启动的时候，就可以已经确定这个哈希表中一共有多少个元素，所以当使用哈希表的这些模块，通常会暴漏出来一个叫max_size和bucket size的参数，这两个参数给我们的时候，我们的max_size仅仅控制了最大的哈希表bucket的个数，而不是实际上bucket的个数，比如说我们的max size配置可能是100，但是实际上只有十个元素使用了哈希表。它与实际的bucket size 是不符的，但**max size作用在于可以限制最大块的使用，因为这里消耗了我们的内存。**



所有使用哈希表的模块，有些什么样的特点?

　　比如说在http和stream的核心模块里，它们所有的变量使用了哈希表，因为变量在我们模块编译的时候就已经定义清楚了。

　　还有像map，还有像反向代理，因为反向代理中需要配置header做哈希来提升它的访问性能。referer和ssi也是同样的道理，因为哈希表在访问的时候它是一个O(1)的复杂度，速度非常的快。

　　在哈希表中有一个叫bucket size，这个bucket size往往会有些默认值。这个默认值有时我们会发现nginx的配置文档中说是cpu_cache_line会对齐到这样一个值，这是什么意思呢？这实际上是影响怎么样去配置bucket size，也就是说现在主流的CPU，它实际上是有了L1，L2，L3缓存的，它在取内存上的数据时，并不是按照大家所想象的那样，按照所有的64位，或者32位这样取，现在主流的CPU一次从内存上取数据的字节数就是cpu_cache_line，是64字节。

　　而为什么哈希表要向64字节对齐呢？假设现在每一个哈希表的bucket是59字节，如果是紧密的排列在一起的，那么取第一个哈希表元素，只需要访问一次，还多取了一个字节，但取第二个元素的时候，实际上需要访问组成两次，包括第一个64字节当中的最后一个字节，以及第二个单元里面的58个字节，所以为了避免这种取两次的问题。nginx在它的代码中自动向上对齐了，所以**在配置bucket size的时候，需要注意两个问题，如果我们配置的不是cpu_cache_line，而是70字节，它就会向上给我们分配每个元素是128字节。如果有可能的话，尽量不要超过64字节，以减少CPU来访问我们哈希表的次数。**

**总结**

​		以上我们介绍了哈希表的使用，实际上还有更多的第三方模块都在使用哈希表，注意:哈希表只为静态的不变的内容服务，哈希表的bucket size需要考虑cpu_cache_line的对齐问题;





# Nginx中最常用的容器：红黑树

　　之前提到nginx的多个worker进程之间，做进程间通讯的时候，经常在共享内存上使用红黑树来管理许多对象，那么实际上在Nginx的内存上也会大量使用红黑树，现在我们来看看nginx中第二个非常常用的数据容器，红黑树首先是个二叉树，二叉查找树有哪些特性呢？

1. 某节点的左子树节点值仅包含小于该节点值
2. 某节点的右子树节点值仅包含大于该节点值
3. 左右子树每个也必须是二叉查找树

![img](https://img2020.cnblogs.com/i-beta/1862379/202003/1862379-20200313101046664-1594723067.png)

 

　　那么这样的一个二叉查找数，它有可能退化成一个链表，比如上图中右边的一张图，它们都没有左子节点，且都满足右边的节点大于左边的节点，大于根节点，那么这个时候在这样的链表二叉树上去查找某一个元素，它的遍历复杂度是O(n);而红黑树它有一个主要的特点，就是它的高度差不会很大， 比如左边3个高度:11-6-1，右边有11-15-22-25-27五个高度;不会超过最低的两倍，在nginx中描述每一个红黑树有一个数据结构叫做ngx_rbtree_t;root节点就是指向这个红黑树的根节点，红黑树会提供一些方法;红黑树里我们会很容易的找到最小的节点;比如最左边的子节点;我们用红黑树做定时器的时候;经常使用这个特性;那么红黑树还有哪些优点尼?

* 它的高度不会超过两倍的log(n);n就是节点数;

* 对红黑树增删改查算法复杂度O(log(n));

* 遍历复杂度是O(n)；

  为什么要单独提出来说尼?因为哈希表它的遍历的复杂度就不是O(n);而是它的bucket数量;

　　那么有了这些特点尼，我们就可以去判断当使用了红黑树的模块，我们使用增删改查的时候，可以预测效率是很高的，而且如果它 提供了遍历这样的方法;我们也完全可以使用;特别是针对Lua模块;因为Lua模块它的底层实现往往我们不太清楚;但是如果我们知道它是基于红黑树实现的;比如说我们刚刚所演示过的share_direct;那么我们就可以放心大胆的使用它的遍历和增删改查等等方法;

　　那么使用红黑树的模块有哪些尼?

　　实际上非常多，这只列举了官方一些常用的模块;

　　比如解析配置的conf模块;

　　ngx_event_timer_rbtree 虽然不是模块，但是是所有worker进程都会有的;管理定时器的红黑树;

![img](https://img2020.cnblogs.com/i-beta/1862379/202003/1862379-20200313111457931-907070626.png)

 　　

　　![img](https://img2020.cnblogs.com/i-beta/1862379/202003/1862379-20200313110146973-432366513.png)

　　　总结:我们了解到了红黑树的特性，可以放心的使用红黑树里面的很多方法;而不用纠结这样的一个方法我频繁的调用，会不会造成性能问题;

　　





# Nginx 的 Http 模块

本部分内容将详细介绍 Nginx 中对 Http请求的 11 个处理阶段，分成 3 个小节讲解并进行相关实验操作。



## 第三章内容介绍

第三章主要讲解HTTP模块

## 冲突的配置指令以谁为准

### 配置块的嵌套

配置块 http、server、location

```nginx
main
http {
	upstream { … }
    split_clients {…}
    map {…}
    geo {…}
    server {
        if () {…}
        location {
        	limit_except {…}
        }
        location {
        	location { } 
        } 
    }
    server { } 
}
```

### 指令的Context

示例

```
Syntax: log_format name [escape=default|json|none] string ...;
Default: log_format combined "..."; 
Context: http

Syntax: access_log path [format [buffer=size] [gzip[=level]] [flush=time] [if=condition]];
access_log off;
Default: access_log logs/access.log combined; 
Context: http, server, location, if in location, limit_except
```

以log日志模块说明：log_format指令只能存在http配置段中，如果配置在其它server，location等配置段，语法配置不通过，access_log指令存在于http,server, location if等配置段中.我们把这种模式称之为上下文。



### 指令的合并

**值指令：存储配置项的值**

- 可以合并（root，access_log，gzip都存储的值，不同块下面是可以合并的。）
- 示例
  - root
  - access_log
  - Gzip

**动作类指令：指定行为**

- 不可以合并（请求到达该位置时，必须立即处理某种行为）
- 示例
  - rewrite
  - proxy_pass
- 生效阶段
  - server_rewrite 阶段
  - rewrite 阶段
  - content 阶段（反向代理）

### 存储值的指令继承规则：向上覆盖

- 子配置不存在时，直接使用父配置块
- 子置存在时，直接覆盖父配置块

```nginx
server {
		listen 8080;
		root /home/geek/nginx/html;
		access_log logs/access.log main;
		location /test {
				root /home/geek/nginx/test; #子配置存在时，直接覆盖父配置块
				access_log logs/accesstest.log main;
		}
		location /hello {
				alias hello/;
		}
		location / {
		 #子配置不存在时，直接使用父配置块
		}
}
```

### HTTP模块合并配置的实现

- 指令在那个块下生效？
- 指令允许出现在哪些块下？
- 在server块内生效，从http向server合并指令；

```c
 char *(*merge_srv_conf)(ngx_conf_t *cf, void *prev, void *conf);
```

- 配置缓存在内存

```c
 char *(*merge_loc_conf)(ngx_conf_t *cf, void *prev, void *conf);
```



## Listen指令的用法

### Listen指令

Syntax:

```
listen address[:port] [default_server] [ssl] [http2 | spdy] [proxy_protocol] [setfib=number] [fastopen=number] [backlog=number] [rcvbuf=size] 
[sndbuf=size] [accept_filter=filter] [deferred] [bind] [ipv6only=on|off] [reuseport] [so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];
listen port [default_server] [ssl] [http2 | spdy] [proxy_protocol] [setfib=number] [fastopen=number] [backlog=number] [rcvbuf=size] [sndbuf=size] 
[accept_filter=filter] [deferred] [bind] [ipv6only=on|off] [reuseport] [so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];
listen unix:path [default_server] [ssl] [http2 | spdy] [proxy_protocol] [backlog=number] [rcvbuf=size] [sndbuf=size] [accept_filter=filter] [deferred] 
[bind] [so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];

Default: listen *:80 | *:8000; 
Context: server
```

### Listen案例演示

```
listen unix:/var/run/nginx.sock;
listen 127.0.0.1:8000;
listen 127.0.0.1;
listen 8000;
listen *:8000;
listen localhost:8000 bind;
listen [::]:8000 ipv6only=on;
listen [::1];
```

Ipv6 不能监听所有地址的所有端口



## 处理HTTP请求头部的流程

### 接收请求事件模块

### 接收请求HTTP模块

**接收URI**

1. 分配请求内存池：request_pool_size:4k
2. 状态机解析请求行
3. 分配大内存：large_client_header_buffers:4 8k
4. 状态机解析请求行
5. 标识URI

**接收header**

1. 状态机解析header
2. 分配大内存：large_client_header_buffers:4 8k
3. 标识header
4. 移除超时定时器：client_header_timeout: 60s
5. 开始11个阶段的http请求处理

<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-22 下午3.39.21.png" alt="截屏2021-03-22 下午3.39.21" style="zoom: 33%;" />

## Nginx中的正则表达式

### 正则表达式

| 元字符       | 描述                                                         |
| ------------ | ------------------------------------------------------------ |
| \            | 将下一个字符标记符、或一个向后引用、或一个八进制转义符。例如，“\\n”匹配\n。“\n”匹配换行符。序列“\\”匹配“\”而“\(”则匹配“(”。即相当于多种编程语言中都有的“转义字符”的概念。 |
| ^            | 匹配输入字行首。如果设置了RegExp对象的Multiline属性，^也匹配“\n”或“\r”之后的位置。 |
| $            | 匹配输入行尾。如果设置了RegExp对象的Multiline属性，$也匹配“\n”或“\r”之前的位置。 |
| *            | 匹配前面的子表达式任意次。例如，zo*能匹配“z”，也能匹配“zo”以及“zoo”。*等价于{0,}。 |
| +            | 匹配前面的子表达式一次或多次(大于等于1次）。例如，“zo+”能匹配“zo”以及“zoo”，但不能匹配“z”。+等价于{1,}。 |
| ?            | 匹配前面的子表达式零次或一次。例如，“do(es)?”可以匹配“do”或“does”。?等价于{0,1}。 |
| {*n*}        | *n*是一个非负整数。匹配确定的*n*次。例如，“o{2}”不能匹配“Bob”中的“o”，但是能匹配“food”中的两个o。 |
| {*n*,}       | *n*是一个非负整数。至少匹配*n*次。例如，“o{2,}”不能匹配“Bob”中的“o”，但能匹配“foooood”中的所有o。“o{1,}”等价于“o+”。“o{0,}”则等价于“o*”。 |
| {*n*,*m*}    | *m*和*n*均为非负整数，其中*n*<=*m*。最少匹配*n*次且最多匹配*m*次。例如，“o{1,3}”将匹配“fooooood”中的前三个o为一组，后三个o为一组。“o{0,1}”等价于“o?”。请注意在逗号和两个数之间不能有空格。 |
| ?            | 当该字符紧跟在任何一个其他限制符（*,+,?，{*n*}，{*n*,}，{*n*,*m*}）后面时，匹配模式是非贪婪的。非贪婪模式尽可能少地匹配所搜索的字符串，而默认的贪婪模式则尽可能多地匹配所搜索的字符串。例如，对于字符串“oooo”，“o+”将尽可能多地匹配“o”，得到结果[“oooo”]，而“o+?”将尽可能少地匹配“o”，得到结果 ['o', 'o', 'o', 'o'] |
| .点          | 匹配除“\n”和"\r"之外的任何单个字符。要匹配包括“\n”和"\r"在内的任何字符，请使用像“[\s\S]”的模式。 |
| (pattern)    | 匹配pattern并获取这一匹配。所获取的匹配可以从产生的Matches集合得到，在VBScript中使用SubMatches集合，在JScript中则使用0…0…9属性。要匹配圆括号字符，请使用“\(”或“\)”。 |
| (?:pattern)  | 非获取匹配，匹配pattern但不获取匹配结果，不进行存储供以后使用。这在使用或字符“(\|)”来组合一个模式的各个部分时很有用。例如“industr(?:y\|ies)”就是一个比“industry\|industries”更简略的表达式。 |
| (?=pattern)  | 非获取匹配，正向肯定预查，在任何匹配pattern的字符串开始处匹配查找字符串，该匹配不需要获取供以后使用。例如，“Windows(?=95\|98\|NT\|2000)”能匹配“Windows2000”中的“Windows”，但不能匹配“Windows3.1”中的“Windows”。预查不消耗字符，也就是说，在一个匹配发生后，在最后一次匹配之后立即开始下一次匹配的搜索，而不是从包含预查的字符之后开始。 |
| (?!pattern)  | 非获取匹配，正向否定预查，在任何不匹配pattern的字符串开始处匹配查找字符串，该匹配不需要获取供以后使用。例如“Windows(?!95\|98\|NT\|2000)”能匹配“Windows3.1”中的“Windows”，但不能匹配“Windows2000”中的“Windows”。 |
| (?<=pattern) | 非获取匹配，反向肯定预查，与正向肯定预查类似，只是方向相反。例如，“(?<=95\|98\|NT\|2000)Windows”能匹配“2000Windows”中的“Windows”，但不能匹配“3.1Windows”中的“Windows”。“(?<=95\|98\|NT\|2000)Windows”目前在python3.6中re模块测试会报错，用“\|”连接的字符串长度必须一样，这里“95\|98\|NT”的长度都是2，“2000”的长度是4，会报错。 |
| (?<!patte_n) | 非获取匹配，反向否定预查，与正向否定预查类似，只是方向相反。例如“(?<!95\|98\|NT\|2000)Windows”能匹配“3.1Windows”中的“Windows”，但不能匹配“2000Windows”中的“Windows”。这个地方不正确，有问题此处用或任意一项都不能超过2位，如“(?<!95\|98\|NT\|20)Windows正确，“(?<!95\|980\|NT\|20)Windows 报错，若是单独使用则无限制，如(?<!2000)Windows 正确匹配。同上，这里在python3.6中re模块中字符串长度要一致，并不是一定为2，比如“(?<!1995\|1998\|NTNT\|2000)Windows”也是可以的。 |
| x\|y         | 匹配x或y。例如，“z\|food”能匹配“z”或“food”(此处请谨慎)。“[zf]ood”则匹配“zood”或“food”。 |
| [xyz]        | 字符集合。匹配所包含的任意一个字符。例如，“[abc]”可以匹配“plain”中的“a”。 |
| [^xyz]       | 负值字符集合。匹配未包含的任意字符。例如，“[^abc]”可以匹配“plain”中的“plin”任一字符。 |
| [a-z]        | 字符范围。匹配指定范围内的任意字符。例如，“[a-z]”可以匹配“a”到“z”范围内的任意小写字母字符。注意:只有连字符在字符组内部时,并且出现在两个字符之间时,才能表示字符的范围; 如果出字符组的开头,则只能表示连字符本身. |
| [^a-z]       | 负值字符范围。匹配任何不在指定范围内的任意字符。例如，“[^a-z]”可以匹配任何不在“a”到“z”范围内的任意字符。 |
| \b           | 匹配一个单词的边界，也就是指单词和空格间的位置（即正则表达式的“匹配”有两种概念，一种是匹配字符，一种是匹配位置，这里的\b就是匹配位置的）。例如，“er\b”可以匹配“never”中的“er”，但不能匹配“verb”中的“er”；“\b1_”可以匹配“1_23”中的“1_”，但不能匹配“21_3”中的“1_”。 |
| \B           | 匹配非单词边界。“er\B”能匹配“verb”中的“er”，但不能匹配“never”中的“er”。 |
| \cx          | 匹配由x指明的控制字符。例如，\cM匹配一个Control-M或回车符。x的值必须为A-Z或a-z之一。否则，将c视为一个原义的“c”字符。 |
| \d           | 匹配一个数字字符。等价于[0-9]。grep 要加上-P，perl正则支持   |
| \D           | 匹配一个非数字字符。等价于[^0-9]。grep要加上-P，perl正则支持 |
| \f           | 匹配一个换页符。等价于\x0c和\cL。                            |
| \n           | 匹配一个换行符。等价于\x0a和\cJ。                            |
| \r           | 匹配一个回车符。等价于\x0d和\cM。                            |
| \s           | 匹配任何不可见字符，包括空格、制表符、换页符等等。等价于[ \f\n\r\t\v]。 |
| \S           | 匹配任何可见字符。等价于[^ \f\n\r\t\v]。                     |
| \t           | 匹配一个制表符。等价于\x09和\cI。                            |
| \v           | 匹配一个垂直制表符。等价于\x0b和\cK。                        |
| \w           | 匹配包括下划线的任何单词字符。类似但不等价于“[A-Za-z0-9_]”，这里的"单词"字符使用Unicode字符集。 |
| \W           | 匹配任何非单词字符。等价于“[^A-Za-z0-9_]”。                  |
| \x*n*        | 匹配*n*，其中*n*为十六进制转义值。十六进制转义值必须为确定的两个数字长。例如，“\x41”匹配“A”。“\x041”则等价于“\x04&1”。正则表达式中可以使用ASCII编码。 |
| \*num*       | 匹配*num*，其中*num*是一个正整数。对所获取的匹配的引用。例如，“(.)\1”匹配两个连续的相同字符。 |
| \*n*         | 标识一个八进制转义值或一个向后引用。如果\*n*之前至少*n*个获取的子表达式，则*n*为向后引用。否则，如果*n*为八进制数字（0-7），则*n*为一个八进制转义值。 |
| \*nm*        | 标识一个八进制转义值或一个向后引用。如果\*nm*之前至少有*nm*个获得子表达式，则*nm*为向后引用。如果\*nm*之前至少有*n*个获取，则*n*为一个后跟文字*m*的向后引用。如果前面的条件都不满足，若*n*和*m*均为八进制数字（0-7），则\*nm*将匹配八进制转义值*nm*。 |
| \*nml*       | 如果*n*为八进制数字（0-7），且*m*和*l*均为八进制数字（0-7），则匹配八进制转义值*nml*。 |
| \u*n*        | 匹配*n*，其中*n*是一个用四个十六进制数字表示的Unicode字符。例如，\u00A9匹配版权符号（&copy;）。 |
| \p{P}        | 小写 p 是 property 的意思，表示 Unicode 属性，用于 Unicode 正表达式的前缀。中括号内的“P”表示Unicode 字符集七个字符属性之一：标点字符。其他六个属性：L：字母；M：标记符号（一般不会单独出现）；Z：分隔符（比如空格、换行等）；S：符号（比如数学符号、货币符号等）；N：数字（比如阿拉伯数字、罗马数字等）；C：其他字符。**注：此语法部分语言不支持，例：javascript。* |
| \<\>         | 匹配词（word）的开始（\<）和结束（\>）。例如正则表达式\<the\>能够匹配字符串"for the wise"中的"the"，但是不能匹配字符串"otherwise"中的"the"。注意：这个元字符不是所有的软件都支持的。 |
| ( )          | 将( 和 ) 之间的表达式定义为“组”（group），并且将匹配这个表达式的字符保存到一个临时区域（一个正则表达式中最多可以保存9个），它们可以用 \1 到\9 的符号来引用。 |
| \|           | 将两个匹配条件进行逻辑“或”（Or）运算。例如正则表达式(him\|her) 匹配"it belongs to him"和"it belongs to her"，但是不能匹配"it belongs to them."。注意：这个元字符不是所有的软件都支持的。 |



### 正则表达式

- \转义字符：取消元字符的特殊含义
- () 分组和取值

```
示例：
原始url：/admin/website/article/35/change/uploads/party/5.jpg
转换后url：/static/uploads/party/5.jpg

匹配原始url的正则表达式：
/^\/admin\/website\/article\/(\d+)\/change\/uploads\/(\w+)\/(\w+)\.(png|jpg|gif|jpeg|b
mp)$/
rewrite^/admin/website/solution/(\d+)/change/uploads/(.*)\.(png|jpg|gif|jpeg|bmp)$ /static/uploads/$2/$3.$4 last;
```

[http处理阶段](https://blog.csdn.net/qinyushuang/article/details/44567885)



## server_name指令块

　　在我们的nginx的http模块处理请求之前,首先要确保它的指令被正确的解析出来了,也就是说我们知道,为了处理这个请求,到底使用哪一个指令的值,因为我们说到指令的配置可以出现在http下,也可以出现在server块下,也可以出现在location下，在这里，我们首先需要确保这个请求是被哪个server块处理;

　　所以接下来我们首先需要介绍一个配置指令叫server_name,它可以保证我们在处理11个阶段的http模块处理之前,先决定哪个server块被使用,

 

**server_name 指令**

1. 指令后可以跟随多个域名，第一个是主域名

> Syntax server_name_in_redirect on | off;
> Default server_name_in_redirect off; 
> Context http, server, location

2. *泛域名：仅支持在最前或最后

> 例如：server_name *.taohui.tech

3. 正则表达式：加～前缀

> 例如: server_name [www.taohui.tech](http://www.taohui.tech/) ~^www\d+.taohui.tech$;

4. 用正则表达式创建变量：用小括号（）

> 例如: ~^(www\.)?(.+)$

 **server_name匹配顺序**

* 精确匹配
* *在前的泛域名
* *在后的泛域名
* 按文件中的先后顺序匹配正则表达式
* default server
  * 第一个
  * Listen 后指定 default　　

**配置实例:**

* server_name 指令后可以跟多个域名,第1个是主域名
* server_name_in_redirect 来决定主域名是否生，当配置"server_name_in_redirect off;"时,主域名是不生效的.

**示例一:**

```shell
# cat server.conf
server {
				listen       80;
        server_name primary.taohui.tech second.taohui.tech;
        #server_name_in_redirect on;// 第一次启用        
        server_name_in_redirect off;
        return 302 /redirect;
}
```

测试结果：

```
# curl second.taohui.tech -I 
HTTP/1.1 302 Moved Temporarily
Server: nginx/1.16.1
Date: Mon, 22 Mar 2021 07:53:35 GMT
Content-Type: text/html
Content-Length: 145
Location: http://second.taohui.tech/redirect
Connection: keep-alive
```

**示例二:**

```shell
# cat server.conf
server {
				listen       80;
        server_name primary.taohui.tech second.taohui.tech;
        server_name_in_redirect on;
        #server_name_in_redirect off;
        return 302 /redirect;
}
```

测试结果：

```shell
# curl second.taohui.tech -I
HTTP/1.1 302 Moved Temporarily
Server: nginx/1.16.1
Date: Mon, 22 Mar 2021 07:54:35 GMT
Content-Type: text/html
Content-Length: 145
Location: http://primary.taohui.tech/redirect
Connection: keep-alive
```



## http 请求 11 个处理阶段

Nginx 将一个 Http 请求分成多个阶段，以模块为单位进行处理。其将 Http请求的处理过程分成了 11 个阶段，各个阶段可以包含任意多个 Http 的模块并以流水线的方式处理请求。这 11 个 Http 阶段如下所示：

```c
typedef enum {
    NGX_HTTP_POST_READ_PHASE = 0,   
    NGX_HTTP_SERVER_REWRITE_PHASE,  

    NGX_HTTP_FIND_CONFIG_PHASE,     
    NGX_HTTP_REWRITE_PHASE,         
    NGX_HTTP_POST_REWRITE_PHASE,    

    NGX_HTTP_PREACCESS_PHASE,       

    NGX_HTTP_ACCESS_PHASE,          
    NGX_HTTP_POST_ACCESS_PHASE,     

    NGX_HTTP_TRY_FILES_PHASE,       
    NGX_HTTP_CONTENT_PHASE,         

    NGX_HTTP_LOG_PHASE              
} ngx_http_phases;
```

如下图所示。我们可以看到 11 个阶段的处理顺序，以及每个阶段中涉及到的相关模块以及模块之间的顺序。

![图片描述](https://img.mukewang.com/wiki/5e4f5b9c096f449a06410337.jpg)



### POST_READ 阶段

​		POST_READ 阶段是 Nginx 接收到 Http 请求完整头部后的处理阶段，这里主要使用的是 realip 模块获取用户的真实地址，方便后续对该 IP 进行限速或者过滤其请求等。



### SERVER_REWRITE 和 REWRITE 阶段

​		SERVER_REWRITE 和后面的 REWRITE 阶段一般是使用 rewrite 模块修改 Http请求的 uri，实现请求的控制，nginx http框架执行，第三方模块在此不会得到执行。



### FIND_CONFIG 阶段

​		FIND_CONFIG 阶段只是做 location 的匹配项。



### PREACCESS、ACCESS 和 POST_ACCESS 阶段

​		PREACCESS、ACCESS 和 POST_ACCESS 是和 Http 请求访问权限相关的阶段。PREACCESS 阶段是在连接之前要做的访问控制, 这个阶段有 limit_conn 和 limit_req 等模块工作。ACCESS 阶段是解决用户能不能访问，比如根据用户名、密码限制用户访问(auth_basic 模块)、根据 ip 限制用户访问(access 模块)以及第三方模块认证限制用户的访问(auth_request模块)。POST_ACCESS 是在 ACCESS 之后要做的一些工作。一些特殊情况，在access此阶段中如果access模块执行了satify 满足后，直接到达try_files阶段，不会执行（auth_basic，auth_request模块），因此，模块并不是一定要都要顺序执行，只要满足条件即可。



### TRY_FILES 阶段

​		TRY_FILES 阶段为访问静态文件资源而设置的。有时候又称之为 PRECONTENT 阶段，即在 CONTENT 阶段之前做的事情。主要是 try_files 模块在此阶段工作。



### CONTENT

​		最重要的 CONTENT 是处理 Http 请求内容的阶段，大部分 HTTP 模块介入这个阶段，比如 index、autoindex、concat 以及反向代理的模块都是在这里生效的。



### LOG 阶段

​		LOG 是处理完请求后的日志记录阶段，如 access_log 模块。



**Tips:** 所有的 Http请求必须都是从上到下，一个接一个阶段执行的。



## realip 模块



### 如何拿到真实的用户IP地址

1. TCP连接四元组（src ip,src port, dst ip,dst port）
2. HTTP头部 X-Forwarded-For 用于传递**IP**
3. HTTP头部 X-Real_ip 用于传递用户IP
4. 前提：网络中存在许多方向代理

![realip](/Users/jinhuaiwang/Documents/k8s-onenote/nginx/picture/realip.png)

用户的请求到达nginx，remote addr是反向代理的ip：2.2.2.2，用户地址是：113.21.5.23，不是192.168.10.x，怎样才能做到呢？首先，客户端的请求到达公网出口（网关），公网ip将客户端的请求送给cdn服务器作加速，cdn服务器会在HTTP 头部插入 X-Forwarded-For字段用于记录传递转发IP， 同时也插入X-Real_ip字段用于记录传递用户真实IP，到达反向代理服务器后，也做同样的操作，在HTTP头部插入 X-Forwarded-For字段用于记录传递转发IP，同时保持X-Real_ip字段用于记录传递用户真实IP不变，将请求送达nginx服务器，nginx收到请求，可以看到用户真实ip和remote_addr地址。将响应body写入，按照原路径返回。



### X-Forwarded-For 和 X-Real-IP区别

- X-Forwarded-For 可以有多个IP地址
- X-Real-IP 只能有一个IP地址

示例：

```nginx
X-Forwarded-For：115.204.33.1，1.1.1.1
X-Real-IP：115.204.33.1
```

拿到用户真实 IP 地址如何使用？

通过变量

> 如 binary_remote_addr, remote_addr这样的变量，其值就为真实的IP! 这样做连接限制（limit_conn模块）才有意义！

### realip模块

1. 默认不会编译进Nginx: 通过--with-http_realip_module启用功能
2. 变量：realip_remote_addr、realip_remote_port
3. 功能：修改客户端ip地址
4. 指令：set_real_ip_from、real_ip_header、real_ip_recursive



### realip指令

```
Syntax: set_real_ip_from address | CIDR | unix:;
Default: —
Context: http, server, location

Syntax: real_ip_header field | X-Real-IP | X-Forwarded-For | proxy_protocol;
Default: real_ip_header X-Real-IP; 
Context: http, server, location

Syntax: real_ip_recursive on | off;
Default: real_ip_recursive off; 
Context: http, server, location
```

realip 模块是在 postread 阶段生效的，它的作用是:**当本机的 nginx 处于一个反向代理的后端时获取到真实的用户 ip。** 如果没有 realip 模块，Nginx 中的 $remote_addr 可能就不是客户端的真实 ip 了，而是代理主机的 ip。
realip模块的配置实例如下:

我们添加配置文件

```
server {
    server_name realip.nginx.com;
	
    set_real_ip_from 192.168.103.145;
    # real_ip_header X-Real-IP;
    real_ip_recursive off;
    real_ip_header X-Forwarded-For;

    location /{
        return 200 "Client real ip: $remote_addr\n";
    }
}
```

测试结果：

```
$ curl -H "X-Forwarded-For: 1.1.1.1,192.168.103.145" realip.nginx.com
Client real ip: 192.168.103.145
```

**去除回环地址**

如果我们将`real_ip_recursive off;`改为`real_ip_recursive on;`;

再次测试结果：

```
$ curl -H "X-Forwarded-For: 1.1.1.1,192.168.103.145" realip.nginx.com
Client real ip: 1.1.1.1
```

```nginx
set_real_ip_from 10.10.10.10;
# real_ip_recursive off;
real_ip_recursive on;
real_ip_header X-Forwarded-For;
```

set_real_ip_from 是指定我们信任的后端代理服务器，real_ip_header 是告诉 nginx 真正的用户 ip 是存在 X-Forwarded-For 请求头中的。

当 real_ip_recursive 设置为 off 时，nginx 会把 real_ip_header 指定的 Http头中的最后一个 ip 当成真实 ip;

而当 real_ip_recursive 为 on 时，nginx 会把 real_ip_header 指定的 Http头中的最后一个不是信任服务器的 ip (前面设置的set_real_ip_from)当成真实 ip。通过这样的手段，最后拿到用户的真实 ip。



## rewrite 模块

rewrite 模块可以看到它在 SERVER_REWRITE 和 REWRITE 阶段都有介入。rewrite 模块的主要功能是改写请求的 uri。它是 Nginx 默认安装的模块。rewrite 模块会根据正则匹配重写 uri，然后发起内部跳转再匹配 location, 或者直接做30x重定向返回客户端。rewrite 模块的指令有 break, if, return, rewrite, set 等，这些都是我们常用到的。

### return 指令

```yaml
Syntax:	return code [text];
				return code URL;
				return URL;
Default: —
Context: server, location, if
```

return 指令返回后，Http 请求将在 return 的阶段终止，后续阶段将无法进行，所以许多模块得不到执行。

```bash
return 200 "hello, world"
```

将客户重定向到一个新域名的示例：

```
server {
    listen 80;
    listen 443 ssl;
    server_name www.old-name.com;
    return 301 $scheme://www.new-name.com$request_uri;
}
```


上面代码中，listen 指令表明 server 块同时用于 HTTP 和 HTTPS 流量。server_name 指令匹配包含域名 ‘www.old-name.com’ 的请求。return 指令告诉 Nginx 停止处理请求，直接返回 301 (Moved Permanently) 代码和指定的重写过的 URL 到客户端。$scheme 是协议（HTTP 或 HTTPS），$request_uri 是包含参数的完整的 URI。

对于 3xx 系列响应码，url 参数定义了新的（重写过的）URL：

```
return (301 | 302 | 303 | 307) url;
```


对于其他响应码，可以选择定义一个出现在响应正文中的文本字符串（HTTP 代码的标准文本，例如 404 的 Not Found，仍包含在标题中）。文本可以包含 NGINX 变量。

```
return (1xx | 2xx | 4xx | 5xx) ["text"];
```

例如，在拒绝没有有效身份验证令牌的请求时，此指令可能适用：

```
return 401 "Access denied because token is expired or invalid";
```

通过 error_page 指令，可以为每个 HTTP 代码返回一个完整的自定义 HTML 页面，也可以更改响应代码或执行重定向。



### rewrite 指令

```yaml
Syntax:  rewrite regex replacement [flag];
Default: --
Context: server, location, if
```

1、将 regex 指定的 url 替换成 replacement 这个新的 url,可以使用正则表达式及变量提取。

2、当 replacement 以 http:// 或者 https:// 或者 $schema 开头，则直接返回 302 重定向

3、替换后的 url 根据 flag 指定的方式进行处理

- last: 用 replacement 这个 url 进行新的 location 匹配。
- break: break 指令停止当前脚本指令的执行，等价于独立的break指令。停止处理当前的 ngx_http_rewrite_module 指令集
- redirect：返回 302临时重定向，在替换字符串不以“http://”，“https://”或“$scheme”开头时使用
- permanent: 返回 301永久重定向

last 和 break 的区别及共同处：

- last 重写 url 后，会再从 server 走一遍匹配流程，而 break 终止重写后的匹配
- break 和 last 都能阻止后面的 rewrite 指令再次执行

**Tips：**

​		**`rewrite` 指令只能返回代码 301 或 302。要返回其他代码，需要在 `rewrite` 指令后面包含 `return` 指令。**



### if 指令

```nginx
Syntax:	 if (condition) { ... }
Default: —
Context: server, location
```

if 指令的条件表达式:

- 检查变量是否为空或者为 0
- 将变量与字符串做匹配，使用 = 或者 !=
- 将变量与正则表达式做匹配:
  - ~ 或者 !~ 大小写敏感
  - ~* 或者 !~* 大小写不敏感
- 检查文件是否存在 -f 或者 !-f
- 检查目录是否存在 -d 或者 !-d
- 检查文件、目录、软链接是否存在 -e !-e
- 是否为可执行文件 -x 或者 !-x

**规则：**

* 条件condition为真，执行大括号里边的指令，遵循值指令的继承规则。

### 实例

```shell
# 如果用户代理 User-Agent 包含"MSIE"，rewrite 请求到 /msie/ 目录下。通过正则匹配的捕获可以用 $1 $2 等使用
if ($http_user_agent ~ MSIE) {
    rewrite ^(.*)$ /msie/$1 break;
}

# 如果 cookie 匹配正则，设置变量 $id 等于匹配到的正则部分
if ($http_cookie ~* "id=([^;]+)(?:;|$)") {
    set $id $1;
}

# 如果请求方法为 POST，则返回状态 405（Method not allowed）
if ($request_method = POST) {
    return 405;
}

# 如果通过 set 指令设置了 $slow，限速
if ($slow) {
    limit_rate 10k;
}

# 如果请求的文件存在，则开启缓存，并通过 break 停止后面的检查
if (-f $request_filename) {
    expires max;
    break;
}

# 如果请求的文件、目录或符号链接都不存在，则用 rewrite 在 URI 头部添加 /index.php
if (!-e $request_filename) {
    rewrite ^/(.*)$ /index.php/$1 break;
}

#防盗链请求
if($invalid_refer){
   return 403;
}
```



##  location 匹配

location 匹配是在 FIND_CONFIG 阶段进行的，我们需要掌握 location 的匹配规则和匹配顺序。



### location 匹配顺序

### location匹配规则

1. 遍历匹配全部前缀字符串location
2. 匹配上 = 字符串：使用匹配上的 = 精确匹配location
3. 匹配上 ^~ 字符串：使用匹配上的 ^～ 字符串location
4. 记住最长匹配的前缀字符串location
5. 按照nginx.conf 中的顺序依次匹配正则表达式 location
6. 如果匹配正则表达式成功：使用匹配上的正则表达式
7. 如果不能匹配正则表达式：则使用最长匹配的前缀字符串location

有一个简单总结如下：

> (location =) > (location 完整路径) > (location ^~ 路径) > (location * 正则顺序) > (location 部分起始路径) > (location /)

即：

> (精确匹配）> (最长字符串匹配，但完全匹配) >（非正则匹配）>（正则匹配）>（最长字符串匹配，不完全匹配）>（location通配）

![图片描述](https://img.mukewang.com/wiki/5e4f5bde09da390a07530400.jpg)



**Nginx处理请求的位置**

Nginx以类似于选择服务器块的方式选择将用于服务请求的位置。它贯穿一个过程，该过程为任何给定请求确定最佳位置块。了解此过程是能够可靠，准确地配置Nginx的关键要求。

牢记我们上面描述的位置声明的类型，Nginx通过将请求URI与每个位置进行比较来评估可能的位置上下文。它使用以下算法执行此操作：

- Nginx首先检查所有基于前缀的位置匹配（所有不涉及正则表达式的位置类型）。它根据完整的请求URI检查每个位置。
- 首先，Nginx寻找完全匹配。如果`=`发现使用修饰符的位置块与请求URI完全匹配，则立即选择该位置块来处理请求。
- 如果没有找到精确的（带有=修饰符）位置块匹配项，则Nginx然后继续评估不精确的前缀。它发现给定请求URI的最长匹配前缀位置，然后对其进行评估，如下所示：
  - 如果最长的匹配前缀位置具有`^~`修饰符，则Nginx将立即结束其搜索并选择此位置来满足请求。
  - 如果最长的匹配前缀位置*不*使用`^~`修饰符，则该匹配项暂时由Nginx存储，以便可以移动搜索的焦点。
- 确定并存储了最长的匹配前缀位置后，Nginx继续评估正则表达式位置（区分大小写和不区分大小写）。如果有任何的正则表达式的位置*内*的最长前缀匹配的位置，Nginx的将这些移动到它的正则表达式的位置列表的顶部进行检查。然后，Nginx尝试顺序匹配正则表达式位置。所述**第一**所述请求URI匹配正则表达式的位置被立即选择来服务该请求。
- 如果未找到与请求URI匹配的正则表达式位置，则选择先前存储的前缀位置来处理请求。

重要的是要了解，默认情况下，Nginx将优先于前缀匹配来提供正则表达式匹配。但是，它首先*评估*前缀位置，从而允许管理员通过使用`=`和`^~`修饰符指定位置来覆盖此趋势。

[参考链接](https://www.digitalocean.com/community/tutorials/understanding-nginx-server-and-location-block-selection-algorithms)



location的URI不能长度大于请求的URI，否则，无法捕获到，直接报404退出。遍历全部的location前缀字符串匹配，匹配前缀最优的将被作为返回结果。



## 实验



### realip 模块使用

realip 模块默认没有被编译进 Nginx 的，需要在源码编译阶段使用–with-http_realip_module，将 realip 模块编译进来后方可使用。接下来，我们做个简单测试，首先准备一个 server 块如下：

```bash
server {
    listen 8007;
    server_name localhost;
    set_real_ip_from 218.19.206.164;
    real_ip_recursive off;
    # real_ip_recursive on;
    real_ip_header X-Forwarded-For;
    location / {
       return 200 "client real ip： $remote_addr\n";
    }
}
```

首先，我们将 real_ip_recursive 设置为 off，然后做一次请求:

```bash
$ curl -H "X-Forwarded-For: 1.1.1.1,218.19.206.164" http://主机ip:8007 
client real ip： 218.19.206.164  
```

这里返回的是头部参数 X-Forwarded-For 中最后一个 ip，如果将 real_ip_recursive 设置为 on，此时，由于 set_real_ip_from 中设置218.19.206.164为信任的方向代理 ip，那么 Nginx 会往前找一位，认为 1.1.1.1 是用户的真实ip。

```nginx
$ ./nginx -s reload
$ curl -H "X-Forwarded-For: 1.1.1.1,218.19.206.164" http://主机ip:8007  
client real ip： 1.1.1.1
```

[rewrite_doc](https://gist.github.com/esfand/8246661)

### return 指令和 if 指令

写一个简单配置如下：

```nginx
server {
    server_name return_and_if.test.com;
    listen 8008;

    root html;
    # 404错误跳转到403.html页面，根路径由root指令指定
    error_page 404 /403.html;

    # return 405 '405 Not Allowed!\n';
    location / {
       if ( $request_method = POST ) {
          return 200 "Post Request!\n";
       }
    }
}
```

先测试if指令，当请求方法为 POST 时，我们能得到 ‘post request!’ 这样的字符串输出。GET 请求时候，针对 404 情况，会跳转到/403.html，我们准备一个 403.html 页面，里面写上’403, forbidden!’ 这一行内容，开始下面的 Http 请求:

```bash
$ curl -X POST http://180.76.152.113:8008  
Post Request!

$ curl http://180.76.152.113:8008/a.txt  
403, forbidden!
```

如果我们打开 return 405 这行指令，则 error_page 将不会生效，连同后面的 location 匹配也不会生效。无论我们发送如何请求，都会返回405的错误信息。这是因为 server 中的 return 指令是在 SERVER_REWRITE中执行的，而 location 匹配则是在下一个阶段 FIND_CONFIG 中执行的，所以FIND_CONFIG阶段在 SERVER_REWRITE之后，根本得不到执行。

```bash
$ curl http://180.76.152.113:8009  
405 Not Allowed!
```



### rewrite 模块使用

首先，我们准备环境，首先是新建一个目录 third（全路径为/etc/nginx/html/third），再该目录下新建一个文件 3.txt, 里面只有一行内容 ‘hello, world’。接下来，我们准备一个 server 块，加到 Http 指令块中:

```nginx
server {
   server_name rewrite.test.com;
   listen 8009;
   # 打开rewrite日志，可以看到对应的rewrite结果
   rewrite_log on;
   error_log logs/rewrite_error.log notice;

   root html/;
   location /first {
      rewrite /first(.*) /second$1 last;
      return 200 'first!\n';
   }

   location /second {
      #rewrite /second(.*) /third$1 break;
      rewrite /second(.*) /third$1;
      return 200 'second!\n';
   }

   location /third {
      return 200 'third!\n';
   }
}
```

上述配置中，要打开 rewrite_log指令，这样我们可以看到 rewrite 指令的相应日志，方便查看结果。

当我们在 /second 配置中，使用 break 时，请求命令:

```bash
$ curl http://主机ip:8009/first/3.txt 
hello, world
```

如果是不使用 break 标识，则请求结果如下:

```bash
$ curl http://主机ip:8009/first/3.txt 
second!
```

首先是 /first/3.txt 请求在 /first 中匹配，并被替换为 /second/3.txt， last 标识表示将继续进行匹配，在 /second 中，uri 又被 rewrite 成 /third/3.txt, 如果后面跟了 break 标识，表示 rewrite 到此结束，不会执行后面的 return 指令，直接请求静态资源/third/3.txt，得到其内容’hello, world’；如果是没有 break 标识，则会在执行 return 指令后直接返回，并不会继续执行下去，最后返回’second!'字符串。



### location 匹配

```bash
server {
   server_name location.test.com;
   listen 8010;

   location = / {  
      return 200 "精确匹配/";
   }

   location ~* /ma.*ch {
      return 200 "正则匹配/ma.*ch";
   }

   location ~ /mat.*ch {
      return 200 "正则匹配/match.*";
   }

   location = /test {
      return 200 "精确匹配/test";
   }

   location ^~ /test/ {
      return 200 "前缀匹配/test";
   }
   
   location /test/hello {
      return 200 "最长匹配/test/hello";
   }
   
   location /test/helloworld {
      return 200 "最长匹配/test/helloworld\n";
   }
   location ~ /test/he.*o {
      return 200 "正则匹配/test/he.*o";
   }

   location / {  
      return 200 "通配/";
   }

}
```

我们按照这样的 location 规则，进行匹配实验，结果如下：

```bash
# 精确匹配优先级最高
$ curl http://localhost:8010/
精确匹配/

$ curl http://localhost:8010/test 
精确匹配/test

# 最长匹配优先级高于前缀匹配
$ curl http://localhost:8010/test/hello
最长匹配/test/hello

# 最长匹配优先级高于前缀匹配
$ curl http://localhost:8010/test/helloworl
最长匹配/test/hello

# 前缀匹配优先级高于正则匹配
$ curl http://180.76.152.113:8010/test/heeo 
前缀匹配/test

# 正则匹配，按照顺序依次匹配，如果同时匹配两个正则，则前面的优先匹配
$ curl http://180.76.152.113:8010/matxxch 
正则匹配/ma.*ch

# 什么都匹配不到时，最后匹配通配/
$ curl http://180.76.152.113:8010/xxxxx 
通配/
```



## 小结

这里介绍了 Nginx 处理 Http 请求的 11 个阶段，并重点介绍了 前三个阶段POST_READ、REWRITE以及FIND_CONFIG以及这些阶段中涉及到的模块和指令。前面讲到的指令都是 Nginx 中的高频指令，必须要熟练掌握。



在前面介绍完 post-read、server-rewrite、find-config、rewrite 和 post-rewrite 阶段后，我们将继续学习 preaccess 和 access 两个阶段，中间会涉及部分模块，一同进行说明。



## preaccess 阶段

在 preaccess 阶段在 access 阶段之前，主要是限制用户的请求，比如并发连接数（limit_conn模块）和每秒请求数（limit_req 模块）等。这两个模块对于预防一些攻击请求是很有效的。



### limit_conn 模块

ngx_http_limit_conn_module 模块限制单个 ip 的建立连接的个数，该模块内有 6 个指令。分别如下：

- **limit_conn_zone**: 该指令主要的作用就是分配共享内存。 下面的指令格式中 key 定义键，这个 key 往往取客户端的真实 ip，zone=name 定义区域名称，后面的 limit_conn 指令会用到的。size 定义各个键共享内存空间大小;

```yaml
Syntax: limit_conn_zone key zone=name:size;
Default: —
Context: http
```

- **limit_conn_status**: 对于连接拒绝的请求，返回设置的状态码，默认是 503;

```yaml
Syntax: limit_conn_status code;
Default: limit_conn_status 503;
Context: http, server, location
```

- **limit_conn**: 该指令实际限制请求的并发连接数。指令指定每个给定键值的最大同时连接数，当超过这个数字时被返回 503 （默认，可以由指令 limit_conn_status 设置）错误;

```yaml
Syntax: limit_conn zone number;
Default: —
Context: http, server, location
```

- **limit_conn_log_level**: 当达到最大限制连接数后，记录日志的等级;

```yaml
Syntax: limit_conn_log_level info | notice | warn | error;
Default: limit_conn_log_level error;
Context: http, server, location
```

- **limit_conn_dry_run**: 这个指令是 1.17.6 版本中才出现的，用于设置演习模式。在这个模式中，连接数不受限制。但是在共享内存的区域中，过多的连接数也会照常处理。

```yaml
Syntax:	limit_conn_dry_run on | off;
Default: limit_conn_dry_run off;
Context: http, server, location
```

- **limit_zone**: 该指令已弃用，由 limit_conn_zone 代替，不再进行说明。



#### limit_conn 模块实验

本次案例将使用 limit_conn 模块中的指令完成限速功能实验。实验配置块如下:

```nginx
...
http {
    ...
    # 没有这个会报错，必须要定义共享内存
    limit_conn_zone $binary_remote_addr zone=addr:10m;
    ...
    server {
        server_name localhost;
        listen 8010;

        location / {
           limit_conn_status 500;
           limit_conn_log_level warn;
            # 限制向用户返回的速度，每秒50个字节
           limit_rate 50;
           limit_conn addr 1;
        }

    }
    ...
}
...
```

使用 limit_rate 指令用于限制 Nginx 相应速度，每秒返回 50 个字节，然后是限制并发数为 2，这样方便展示效果。当我们打开一个浏览器请求该端口下的根路径时，由于相应会比较慢，迅速打开另一个窗口请求同样的地址，会发现再次请求时，正好达到了同时并发数为 2，启动限制功能，第二个窗口返回 503 错误（默认）。

**访问第一次**

![图片描述](https://img.mukewang.com/wiki/5e4f5c1a09af5ad213600340.jpg)

**快速访问第二次**
![图片描述](https://img.mukewang.com/wiki/5e4f5c280994943713660304.jpg)



### limit_req 模块



**功能:**

​		ngx_http_limit_req_module 模块主要用于处理突发流量，它基于漏斗算法将突发的流量限定为恒定的流量。如果请求容量没有超出设定的极限，后续的突发请求的响应会变慢，而对于超过容量的请求，则会立即返回 503（默认）错误。

- 生效阶段：NGX_HTTP_PREACCESS_PHASE 阶段
- 模块：http_limit_req_module
- 默认编译进nginx, 通过--without-http_limit_req_module 禁用
- 生效算法：leaky bucked算法
- 生效范围：
  - 全部worker进程（基于共享内存）
  - 进入preaccess前不生效
  - 限制的有效性取决于key的设计：依赖postread阶段的realip模块取到真实ip



**limit_req 指令**



**定义共享内存（包括大小），以及key关键字和限制速率**

- limit_req_zone 指令，定义共享内存, key 关键字以及限制速率

```yaml
Syntax:	limit_req_zone key zone=name:size rate=rate [sync];
Default: —
Context: http
		- rate单位为r/s或者r/m
```

- limit_req 指令，限制并发连接数

```yaml
Syntax:	limit_req zone=name [burst=number] [nodelay | delay=number];
Default: —
Context: http, server, location
  -  burst 默认为0
  - no delay, 对 burst中的请求不再采用延时处理的做法，而是立即处理
```

- limit_req_log_level 指令，设置服务拒绝请求发生时打印的日志级别

```yaml
Syntax:	limit_req_log_level info | notice | warn | error;
Default:
limit_req_log_level error;
Context:	http, server, location
```

- limit_req_status 指令， 设置服务拒绝请求发生时返回状态码

```yaml
Syntax: limit_req_status code;
Default: limit_req_status 503;
Context: http, server, location
```



#### 案例演示

**问题：**

1. limit_req 与 limit_conn配置同时生效时，哪个有效？
2. nodelay 添加与否，有什么不同？

配置示例

```nginx
#limit_conn_zone $binary_remote_addr zone=addr:10m;
limit_req_zone $binary_remote_addr zone=one:10m rate=2r/m;

server {
    server_name t2.wang.com;
    root html/;
    error_log logs/conn_error.log info;
    
    location /{
        limit_conn_status 500;
        limit_conn_log_level warn;
        # limit_rate 50;
        # limit_conn addr 1;
        # limit_req zone=one burst=3 nodelay;
        limit_req zone=one;
    }
}
```



## access 阶段



### access模块



**模块: http_access_module**

生效阶段: NGX_HTTP_ACCESS_PHARSE阶段

默认编译进nginx, 通过--without-http_access_module禁用功能

生效范围:

* 进入access阶段前不生效

在 access 阶段，我们可以通 allow 和 deny 指令来允许和拒绝某些 ip 的访问权限，指令的用法如下:

```yaml
Syntax: allow address | CIDR | unix: | all;
Default: —
Context: http, server, location, limit_except

Syntax: deny address | CIDR | unix: | all;
Default: —
Context: http, server, location, limit_except
```

allow 和 deny 指令后面可以跟具体 ip 地址，也可以跟一个 ip 段， 或者所有(all)。

```nginx
location / {
    deny  192.168.1.1;
    allow 192.168.1.0/24;
    allow 10.1.1.0/16;
    allow 2001:0db8::/32;
    deny  all;
}
```



#### access 模块实验

我们做一个简单的示例，配置如下。在 /root/test/web 下有 web1.html 和 web2.html 两个静态文件。访问/web1.html 时，使用 allow all指令将所有来源的 ip 请求全部放过（当然也可以不写）；使用 deny all 会拒绝所有，所以访问 /web2.htm l时，会出现 403 的报错页面。

```nginx
server {
   server_name access.test.com;
   listen 8011;

   root /root/test/web;

   location /web1.html {
      default_type text/html;
      allow all;
      # return 200 'access';
   }

   location /web2.html {
      default_type text/html;
      deny all;
      # return 200 'deny';
   }
}
```

访问允许的 web1.html 页面
![图片描述](https://img.mukewang.com/wiki/5e4f5c3a09661bfc13660246.jpg)

访问禁止的 web2.html
![图片描述](https://img.mukewang.com/wiki/5e4f5c5c0964755013660326.jpg)

大家可以思考下，如果使用的是 return 指令呢，会有怎样的结果？打开注释，重新加载 Nginx 后，可以看到无论是访问 /web1.html 还是 /web2.html，我们都可以看到想要的 return 指令中的结果。这是因为 return 指令所在的 rewrite 模块先于 access 模块执行，所以不会执行到 allow 和 deny 指令就直接返回了。但是对于访问静态页面资源，则是在 content 阶段执行的，所以会在经过 allow 和 deny 指令处理后才获取静态资源页面的内容，并返回给用户。



### auth_basic 模块



**功能:**

​		auth_basic 模块是基于 HTTP Basic Authentication 协议进行用户名和密码的认证，它默认是编译进 Nginx 中的，可以在源码编译阶段通过 --without-http_auth_basic_module 禁用该模块。



指令如下：

```yaml
Syntax:	auth_basic string | off;
# 默认是关闭的
Default: auth_basic off;
Context: http, server, location, limit_except

Syntax:	auth_basic_user_file file;
Default: —
Context: http, server, location, limit_except
```

对于使用文件保存用户名和密码，二者之间需用冒号隔开，如下所示。

```nginx
# comment
name1:password1
name2:password2:comment
name3:password3
```

在 centos 系统上，想要生成这样的密码文件，我们可以使用 httpd-tools 工具完成，直接使用 `yum install httpd-tools` 安装即可。

```bash
$ sudo yum install httpd-tools
# 生成密码文件user_file，帐号为user，密码为pass
$ htpasswd -bc user_file user pass
```

接下来，我们只需要配置好 auth_basic 指令，即可对相应的 http 请求做好认证工作。



#### auth_basic 模块实验

```nginx
$ htpasswd -bc /root/user.pass store @store.123!
$ cat /root/user.pass
store:$apr1$36xHOQGz$yk4O3roiW3SIJrkXFJ0pS1
```

在 Nginx 加入如下 server 块的配置，监听 8012 端口，并在 / 路径中加入认证模块。

```nginx
server {
   server_name auth_basic.test.com;
   listen 8012;

   location / {
       auth_basic           "my site";
       auth_basic_user_file /root/user.pass;
   }
}
```

重新加载 Nginx 后，访问主机的 8012 端口的根路径时，就会发现需要输入账号和密码了。成功输入账号和密码后，就可以看到 Nginx 的欢迎页了。

**使用 auth_basic 模块认证**

![图片描述](https://img.mukewang.com/wiki/5e52711b092e22d013660403.jpg)
认证成功后的页面

![图片描述](https://img.mukewang.com/wiki/5e52712909fdadeb13660355.jpg)









### auth_request模块



**功能：**该模块的功能是向上游服务转发请求，如果上游服务返回的相应码是 2xx，则通过认证，继续向后执行;若返回的 401 或者 403，则将响应返回给客户端。

**原理**：收到请求后，生成子请求，通过反向代理技术把请求传递给上游服务

**默未为编译进nginx: ** 需要使用 --with-http_auth_reques_module将该模块编译进 Nginx 中，然后我们才能使用该模块。



**指令：**

```yaml
Syntax: auth_request uri | off;
Default: auth_request off;
Context: http, server, location

Syntax: auth_request_set $variable value;
Default: —
Context: http, server, location
```



#### auth_request模块实验

```nginx
server {
        listen 8032;
        server_name auth.nginx.com;
        
        location /{
            auth_request /test_auth;
        }
        
        location = /test_auth {
   			 # 上游认证服务地址
            proxy_pass http://127.0.0.1:8033/auth_upstream;
            proxy_pass_request_body off;
            proxy_set_header Content-Length "";
            proxy_set_header X-original-URI $request_uri;
        }
 }

server {
       listen 8033;
    
       location = /auth_upstream {
            return 200 "hello\n";
            #return 403 "hello\n";
       }
}
```

测试结果:

```
[root@nginx ~]# curl 192.168.10.122:8032
default testing page...
```

#修改配置如下，重启服务。

```
       location = /auth_upstream {
            #return 200 "hello\n";
            return 403 "hello\n";
       }
```

测试结果:

```
[root@nginx ~]# curl 192.168.10.122:8032
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.19.1</center>
</body>
</html>
```





**satisfy指令**

​		**satisfy指令的作用: 限制所有access阶段模块**

**指令：**

```
Syntax: satisfy all | any;
Default: satisfy all; 
Context: http, server, location
```

- all: 必须符合所有的权限模块
- any:符合一个权限模块即可

**access阶段的模块：**

- access模块
- auth_basic模块
- auth_request模块
- 其他模块

**access阶段模块请求示意图:**

<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-08 下午5.33.24.png" alt="截屏2021-03-08 下午5.33.24" style="zoom: 50%;" />



#### 案例分析

1. 如果有return指令，access阶段还会生效吗？

   回答：不可以。因为return在rewrite时生效，它在postread阶段，早于access阶段。

2. 多个access模块的顺序有影响吗？

查看ngx_modules.c

```
&ngx_http_auth_request_module, 
&ngx_http_auth_basic_module, 
&ngx_http_access_module,
```

 回答：有影响，在设置`satisfy all` 时。

3. 输对密码，下面可以访问到文件吗？

```
location /{
    satisfy any;
    auth_basic "test auth_basic";
    auth_basic_user_file examples/auth.pass;
    deny all;
}
```

回答：可以。因为`satisfy any` 代表只要满足一个条件就可以。

4. 如果把deny all 提前到 auth_basic 之前呢？

回答：可以。因为`satisfy any` 代表只要满足一个条件就可以；与指令配置前后顺序没有关系。

5. 如果改为allow all, 有机会输入密码吗？

回答：不可以，因为access先于auth_basic生效。



## 小结

本篇文章中，我们介绍了 Http 请求的 11 个阶段中的中间阶段，分别为 preaccess 和 access 阶段。在这两个阶段中，主要生效的指令有limit_conn、limit_req、allow、deny 等，这些指令几乎都是用来做访问控制的，用来限制 Nginx 的并发连接、访问限速、设置访问白名单以及认证访问等。这些安全限制在线上环境是十分必要的，必须要限制恶意的请求以及添加白名单操作。



## try_files 阶段

这个阶段又称为 precontent 阶段，是 content 阶段的前置处理阶段，该阶段主要介入的模块是 ngx_http_try_files_module 模块。该模块依次访问多个 URI 对应得文件（由 root 或者 alias 指令指定），当文件存在时直接返回内容，如果所有文件不存在，则按最后一个 URL 结果或者 code 返回。

```yaml
Syntax: try_files file ... uri;
try_files file ... =code;
Default: —
Context: server, location
```



#### try_files 示例

在测试机器的 /root/test/web 目录下有 2 个 html 文件，分别为 web.html 和 web2.html， 没有 web3.html。我们编写如下的 server 块，监听 8013 端口。首先访问 [http://主机ip:8013/web](http://xn--ip-wz2cm89g:8013/web) 时，根据配置情况，Nginx 首先查找是否存在 /root/test/web/web3.html 文件，没有找到会继续向下，找$uri，也就是/root/test/web 文件，不存在。继续找 KaTeX parse error: Expected 'EOF', got '，' at position 15: uri/index.html，̲即/root/test/web…uri/web1.html时文件存在，故返回/root/test/web/web1.html文件内容。如果该文件还不存在，则还会继续批评额哦@lasturi，最后返回’lasturi!'这样的字符串。而在访问 [http://主机ip:8013/return_code](http://xn--ip-wz2cm89g:8013/return_code) 时，由于无法匹配静态资源，根据配置最后返回404错误码，出现 Nginx 默认的 404 错误页面。

```nginx
server {
    server_name  try_files.com;
    listen 8013;
    root /root/test/;
    default_type text/plain;
    location /web {
        # 找/root/test/index.html
        # try_files /index.html 
        try_files /web/web3.html
        $uri $uri/index.html $uri/web1.html  
        @lasturi; #最后匹配这个
    }
    location @lasturi {
        eturn 200 'lasturi!\n';
    }
    location /return_code {
        try_files $uri $uri/index.html $uri.html =404;
    }
}
```

测试结果:

```shell
[root@nginx ~]# curl 192.168.10.122:8013/first
lasturl!
[root@nginx ~]# curl 192.168.10.122:8013/second
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.19.1</center>
</body>
</html>
```



## precontent阶段

### 实时拷贝流量：mirror

**模块：**

- ngx_http_mirror_module模块；
- 默认编译进nignx;
- 可以通过--without-http_mirror_module移除模块

**功能：**

处理请求时，生成子请求访问其他服务，对子请求的返回值不做处理

```
Syntax: mirror uri | off;
Default: mirror off; 
Context: http, server, location

Syntax: mirror_request_body on | off;
Default: mirror_request_body on; 
Context: http, server, location
```

### 实战案例

配置文件

```nginx
server {
    server_name t2.wang.com;
    listen 10020;
    error_log logs/mirror.log debug;
    location / {
        mirror /mirror;
        mirror_request_body off;
    }

    location = /mirror {
        internal;
        proxy_pass http://127.0.0.1:8082$request_uri;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
        proxy_set_header X-original-URI $request_uri;
    }
}
```

后端配置

```nginx
server {
    listen 8082;
    
    location / {
        return 200 'mirror response!\n';
    }
}
```

访问测试

```
$ curl http://t2.wang.com:10020/mirror.txt
mirror.txt
```

检查两个nginx服务日志，发现都有访问记录。



## content 阶段

content 阶段中最主要的 static 模块，该模块提供了root 和 alias 这两个常用的指令。二者的用法如下：

```nginx
Syntax: alias path
Default: —
Context: location

Syntax: root path
Default: root html
Context: http, server, location, if in location
```

可以看到，单从指令用法上就可以看到不少区别，首先是 alias 指令没有默认值，而且该指令只能在 location 中使用。而 root 可以存在与 http、server、location 等多个指令块中，还可以出现在 if 指令中。另外，最最主要的不同是两个指令会以不同的方式将请求映射到服务器文件上。root 指令会用[root 路径 ＋ location 路径]的规则映射静态资源请求，而 alias 会使用 alias 的路径替换 location 路径。
此外 alias 后面必须要用“/”结束，否则会找不到文件的，而 root 则可有可无。来看下面一个例子:

```nginx
location ^~ /test {
	root /root/html/;
}

location ^~ /test2/ {
	alias /root/html/;
}
```

对于 http 请求: `http://ip:端口/test/web1.html`访问的是主机 上全路径为 `/root/html/test/web1.html`的静态资源；而请求`http://ip:端口/test2/web1.html` 访问的是全路径为`/root/html/web1.html`的静态资源，/test2/已经被替换掉了。



### 配置示例

**文件路径**

```
html/first/
└── 1.txt
```

**配置文件**

```nginx
location /root {
    root html;
}
location /alias {
    alias html;
}
location ~ /root/(\w+\.txt) {
    root html/first/$1;
}
location ~ /alias/(\w+\.txt) {
    alias html/first/$1;
}
```

访问一下URL会得到什么相应？

```
/root/
/alias/
/root/1.txt
/alias/1.txt
```

结果演示：

```nginx
$ curl http://t2.wang.com/root/
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.19.1</center>
</body>
</html>
# error.log: "/etc/nginx/html/root/index.html" is not found (2: No such file or directory), 

$ curl http://t2.wang.com/alias/
default testing page...

$ curl http://t2.wang.com/root/1.txt
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.19.1</center>
</body>
</html>
# error.log: open() "/etc/nginx/html/first/1.txt/root/1.txt" failed (20: Not a directory)

$ curl http://t2.wang.com/alias/1.txt
1.txt
```





在 static 模块中，还提供了 3 个变量供我们使用，分别是:

- **request_filename**: 访问静态资源的完整路径
- **document_root**: 访问静态资源文件所在目录
- **realpath_root**: 如果 document_root 是软链接，则改变量会将其替换成真正的地址

同样是上面的例子，稍做改动:

```nginx
    location /web {
        default_type text/html;
        alias /root/test/web;
        return 200 '$request_filename:$document_root:$realpath_root\n';
    }
```

访问 `http://ip:端口//web/web1.html`, 返回的结果为:

```nginx
/root/test/web/web1.html:/root/test/web:/root/test/web
```



## index和autoindex模块

### index 模块

**功能：**指定 / 访问时返回index文件内容

**模块：**ngx_http_index_module

**指令用法：**

```nginx
Syntax:	index file ...;
Default: index index.html;
Context: http, server, location

# 示例，访问 uri=/ 时，返回静态资源 index.html 文件中的内容
location / {
    index index.html;
}
```



###  random_index模块

**功能：**随机选择 index 指令指定的一系列 index 文件中的一个， 作为 / 路径的返回文件内容

**模块：**

- ngx_http_index_module
- 默认不编译进Nginx , 通过--with-http_random_index_module编译进去

**指令用法：**

```nginx
Syntax: random_index on | off;
Default: random_index off; 
Context: location
```



### autoindex模块

**功能：**当 URL 以 / 结尾时，尝试以 html/xml/json/jsonp 等格式返回 root/alias 中指向目录的目录结构

**模块：**

- ngx_http_index_module
- 默认编译进 Nginx, 取消编译 --without-http_autoindex_module

**指令用法：**

```nginx
# 是否开启目录显示，默认Nginx是不会显示目录下的所有文件
Syntax:	autoindex on | off;
Default: autoindex off;
Context: http, server, location

# 显示出文件的实际大小,
Syntax:	autoindex_exact_size on | off;
Default: autoindex_exact_size on;
Context: http, server, location

# 显示格式，默认是html形式显示
Syntax:	autoindex_format html | xml | json | jsonp;
Default: autoindex_format html;
Context: http, server, location

# 显示时间，设置为on后，按照服务器的时钟为准
Syntax:	autoindex_localtime on | off;
Default: autoindex_localtime off;
Context: http, server, location
```

### 配置实例

配置文件

```nginx
location / {
    alias html/;
    #autoindex on;
    #index no.html;
    autoindex_exact_size off;
    autoindex_format html;
    autoindex_localtime on;
}
```

测试结果:

```shell
# curl autoindx.nginx.com:8076
test nginx app
```

把注释的#去掉

测试结果:

```shell
# curl autoindx.nginx.com:8076
<html>
<head><title>Index of /</title></head>
<body>
<h1>Index of /</h1><hr><pre><a href="../">../</a>
<a href="en-US/">en-US/</a>                                             07-Mar-2021 17:35       -
<a href="icons/">icons/</a>                                             07-Mar-2021 17:35       -
<a href="img/">img/</a>                                               07-Mar-2021 17:35       -
<a href="404.html">404.html</a>                                           01-Nov-2020 10:01    3650
<a href="50x.html">50x.html</a>                                           01-Nov-2020 10:01    3693
<a href="index.html">index.html</a>                                         22-Mar-2021 22:16      15
<a href="nginx-logo.png">nginx-logo.png</a>                                     01-Nov-2020 10:01     368
<a href="poweredby.png">poweredby.png</a>                                      01-Nov-2020 10:01     368
</pre><hr></body>
</html>
```

上面域名地址，默认打开时配置文件。如果你开启了autoindex，依然返回的是 index.html页面，除非index 指定的页面不存在。



在 content 阶段，在 static 模块之前，还会执行的模块有 index 和 autoindex模块。index 模块提供了 index 指令，用于指定/访问时返回 index 文件内容。
autoindex 模块会根据配置决定是否以列表的形式展示目录下的内容，这个功能在后续实战中搭建内部 pip 源中会用到。





### concat 模块

**功能：**当页面需要访问多个小文件时，把他们的内容合并到一次http相应中返回，提升性能

**模块：**

- ngx_http_concat_module
- Tengine(https://github.com/alibaba/nginx-http-concat)
- –add-module=../nginx-http-concat/

**使用：**

在uri后加上 ?? , 后通过多个, 逗号分隔文件。如果还有参数，则在最后通过？添加参数

示例：https://g.alicdn.com/??kissy/k/6.2.4/seed-min.js,kg/global-util/1.0.7/index-min.js,tb/tracker/4.3.5/index.js,kg/tb-nav/2.5.3/index-min.js,secdev/sufei_data/3.3.5/index.js

### concat模块的指令

```
concat : on | off
default : concat off
Context : http, server, location

concat_types : MIME types
Default : concat_types: text/css application/x-javascript
Context : http, server, location

concat_unique : on | off
Default : concat_unique on
Context : http, server, location

concat_max_files : numberp
Default : concat_max_files 10
Context : http, server, location

concat_delimiter : string
Default : NONE
Context : http, server, locatione

concat_ignore_file_error : on | off
Default : off
Context : http, server, location
```

### 案例演示

演示文件

```
# echo 1.txt > html/concat/1.txt
# echo 2.txt > html/concat/2.txt
```

重新编译nginx

```
git clone https://github.com/alibaba/nginx-http-concat
./configure --prefix=/home/jeek/nginx --with-http_ssl_module --with-http_realip_module --add-module=./nginx-http-concat/
make
```

nginx热更新

```
mv /home/jeek/nginx/sbin/nginx /home/jeek/nginx/sbin/nginx1.14.3
cp objs/nginx /home/jeek/nginx/sbin/nginx
kill -USR2 `cat /home/jeek/nginx/logs/nginx.pid ` 
kill -QUIT `cat /home/jeek/nginx/logs/nginx.pid.oldbin `
```

配置文件

```
concat on;
location /concat {
    concat_max_files 20;
    concat_types text/plain;
    concat_unique on;
    concat_delimiter ':::';
    concat_ignore_file_error on;
}
```

结果测试

```
# curl http://t2.wang.com/concat/??1.txt,2.txt
1.txt
:::2.txt
```



## log 阶段



**功能：**将HTTP 请求相关的信息记录到日志

**模块：**ngx_http_log_module，默认集成，无法禁用



```nginx
# 官方例子
log_format compression '$remote_addr - $remote_user [$time_local] '
                       '"$request" $status $bytes_sent '
                       '"$http_referer" "$http_user_agent" "$gzip_ratio"';

access_log /spool/logs/nginx-access.log compression buffer=32k;

# access_log指令用法
Syntax:	access_log path [format [buffer=size] [gzip[=level]] [flush=time] [if=condition]];
access_log off;
Default: access_log logs/access.log combined;
Context: http, server, location, if in location, limit_except

# log_format指令用法
Syntax:	log_format name [escape=default|json|none] string ...;
Default: log_format combined "...";
Context: http

```



### access 日志格式

**指令**

```nginx
Syntax: log_format name [escape=default|json|none] string ...;
Default: log_format combined "..."; 
Context: http
```

**默认combined 日志格式**

```nginx
log_format combined '$remote_addr - $remote_user [$time_local] ' 
'"$request" $status $body_bytes_sent ' '"$http_referer" 
"$http_user_agent"';
```

**日志文件路径**

```nginx
Syntax: access_log path [format [buffer=size] [gzip[=level]] [flush=time] [if=condition]];
        access_log off;
Default: access_log logs/access.log combined; 
Context: http, server, location, if in location, limit_except
```

说明：

- path 路径可以包含变量：不打开cache时每记录一条日志都需要打开、关闭日志文件
- if 通过变量值控制请求日志是否记录
- 日志缓存：
  - 功能：批量将内存中的日志写入磁盘
  - 写入磁盘的条件：
    - 所有待写入磁盘的日志大小超过缓存大小
    - 达到flush 指定的过期时间
    - worker 进程执行 reopen 命令， 或者正在关闭
- 日志压缩：
  - 功能：批量压缩内存中的日志，再写入磁盘
  - buffer 大小为 64KB
  - 压缩级别默认为1 （1最快压缩率最低，9最慢压缩率最高）



**是否打开日志缓存**

指令说明

```
Syntax: open_log_file_cache max=N [inactive=time] [min_uses=N] [valid=time];
        open_log_file_cache off;
Default: open_log_file_cache off; 
Context: http, server, location
```

参数：

- max: 缓存内的最大文件句柄数，超出后用LRU 算法淘汰
- inactive: 文件访问完后在这段时间内不会被关闭。默认10秒
- min_uses: 在inactive 时间内使用次数超过 min_users才会继续存在内存中。默认1
- valid: 超出valid时间后，将对缓存的日志文件检查是否存在
- off: 关闭缓存功能



### access_log 示例

我们只需要在 http 指令块中配置 log_format 指令和 access_log 指令即可。测试的配置如下：

```nginx
...

http {
    ...
    
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  logs/access.log  main;
    
    # 和上面的日志格式无关
    server {
        listen 8000;
        return 200 '8000, server\n';
    }
    
    ...
}
...
```

log_format 指令是指定打印日志的格式，access_log 指令指定日志输出的路径以及指定使用前面定义的日志格式。在配置好日志相关的指令后，重启 Nginx，并发送一个 Http 请求，就可以在对应的路径上看到相关的日志信息了。

```nginx
# 模拟发送http请求
[shen@shen Desktop]$ curl http://180.76.152.113:8000
8000, server
[shen@shen Desktop]$ curl -H "X-Forwarded-For: 1.1.1.1" http://180.76.152.113:8000

# 查看打印的日志，和前面配置的日志格式进行对比
[root@server nginx]# tail -2 logs/access.log 
103.46.244.226 - - [02/Feb/2020:20:52:05 +0800] "GET / HTTP/1.1" 200 13 "-" "curl/7.29.0" "-"
103.46.244.226 - - [02/Feb/2020:20:57:03 +0800] "GET / HTTP/1.1" 200 13 "-" "curl/7.29.0" "1.1.1.1"
```





## HTTP过滤模块的调用流程

### 过滤模块的位置

使用示例

```
limit_req zone=req_one
burst=120;
limit_conn c_zone 1;

satisfy any;
allow 192.168.1.0/32;
auth_basic_user_file
access.pass;

gzip on;
image_filter resize 80 80;
```

### 返回响应：加工响应内容

- copy_filter: 复制包体内容
- postpone_filter: 处理子请求
- header_filter: 构造响应头部
- write_filter: 发送响应



## Nginx变量的运行原理

### 变量的惰性求值

1. 提供变量的模块：Preconfiguration 中定义新的变量，设置变量名 和 解析出变量的方法
2. 使用变量的模块，比如 http 的 access 模块
3. 处理请求时，通过变量名，去提供变量的模块，通过解析出变量的方法，获得请求值

### 变量的特性

- 惰性求值
- 变量值可以时刻变化，其值为使用的那一时刻的值





## HTTP框架提供的变量

### HTTP 请求相关的变量

- arg_参数名：URL 中某个具体参数的值
- query_string: 与args变量完全相同
- args: 全部URL参数
- is_args: 如果请求URL 中有参数则返回‘？’，否则返回空
- centent_length: HTTP 请求中标识包体长度的 Content-Length 头部的值
- content_type: 标识请求包体类型的 Content-Type 头部的值

- uri: 请求的URI（不同于URL，不包括？后的参数）
- document_uri: 与uri 完全相同
- request_uri: 请求的URL( 包括URI 以及完整的参数 )
- scheme: 协议名，例如HTTP 或者 HTTPS
- request_method: 请求方法，例如GET 或者 POST
- request_length: 所有请求内容的大小，包括请求行、头部、包体等
- remote_user: 由 HTTP Basic Authentication 协议传入的用户名

### HTTP 请求相关的变量（三）

request_body_file：临时存在请求包体的文件

- 如果包体非常小，则不会存文件
- client_body_in_file_only 强制所有包体存入文件，且可决定是否删除

request_body: 请求中的包体，这个变量当且仅当使用反向代理，且设定用内存暂存包体时才有效

request: 原始的url 请求，含有方法与协议版本，例如 GET /?a=1&b=22 HTTP/1.1

### HTTP 请求相关的变量（四）

**host:**

- 先从请求行中获取
- 如果含有Host头部，则用其值替换掉请求行中的主机名
- 如果前两者都取不到，则使用匹配上的server_name

### HTTP 请求相关的变量（五）

http_头部名字：返回一个具体请求头部的值

特殊：

- http_host
- http_user_agent
- http_referer
- http_via
- http_x_forwarded_for
- http_cookie

### 案例演示

```nginx
location / {
    set $limit_rate 10k;
    return 200 '
        arg_a:$arg_a, arg_b:$arg_b, args:$args
        connection:$connection, connection_requests:$connection_requests
        cookie_a:$cookie_a;
        uri:$uri, document_uri:$document_uri, request_uri:$request_uri
        request:$request
        request_id:$request_id
        server:$server_addr, $server_name, $server_port, $server_protocol
        topinfo: $tcpinfo_rtt, $tcpinfo_rttvar, $tcpinfo_snd_cwnd, $tcpinfo_rcv_space
        host:$host, server_name:$server_name, http_host:$http_host
        limit_rate:$limit_rate
        hostname:$hostname
    \n';
}
```

结果测试

```nginx
# curl -H 'Content-Length: 0' -H 'Cookie: a=c1' 'http://localhost:7070/hello?a=11&b=22'

        arg_a:11, arg_b:22, args:a=11&b=22
        connection:19, connection_requests:1
        cookie_a:c1;
        uri:/hello, document_uri:/hello, request_uri:/hello?a=11&b=22
        request:GET /hello?a=11&b=22 HTTP/1.1
        request_id:b1f030fac3d4f337f88357c3cb333108
        server:127.0.0.1, t2.wang.com, 7070, HTTP/1.1
        topinfo: 0, 0, 10, 43690
        host:localhost, server_name:t2.wang.com, http_host:localhost:7070
        limit_rate:10240
        hostname:wang-13.host.com
```



### tcp 连接相关的变量

| binary_remote_addr  | 客户端地址的整型格式，对于IPv4 是4字节，对于IPv6是16字节     |
| ------------------- | ------------------------------------------------------------ |
| remote_addr         | 客户端地址                                                   |
| remote_port         | 客户端端口                                                   |
| server_addr         | 服务器端地址                                                 |
| server_port:        | 服务器端端口                                                 |
| connection          | 递增的连接序号                                               |
| connection_requests | 当前连接上执行过的请求数，对keepalive连接有意义              |
| server_protocol     | 服务器端协议，例如 HTTP/1.1                                  |
| proxy_protocol_addr | 若使用了proxy_protocol 协议，则返回协议中的地址，否则返回空  |
| proxy_protocol_port | 若使用了proxy_protocal协议，则返回协议中的端口，否则返回为空 |
| TCP_INFO            | tcp 内核层参数，包括$tcpinfo_rtt, $tcpinfo_rttvar, $tcpinfo_snd_cwnd, $tcpinfo_rcv_space |

### Nginx 处理请求的变量

| request_time        | 请求处理到现在的耗时，单位为妙，精确到毫秒s                  |
| ------------------- | ------------------------------------------------------------ |
| erver_name:         | 匹配上请求的server_name 值                                   |
| https:              | 如果开启了 TLS/SSL, 则返回on, 否则返回空                     |
| request_completion: | 若请求处理完，则返回OK， 否则返回为空                        |
| request_id          | 以16进制输出的请求标示id，该id共含有16个字节，是随机生成的   |
| limit_rate          | 返回客户端响应时的速度上限，单位为每秒字节数。可以通过 set 指令修改对请求产生效果 |
| document_root       | :由URI 和 root/alias 规则生成的文件夹路径                    |
| request_filename    | 待访问文件的完整路径                                         |
| realpath_root       | 将 document_root 中的软连接等换成真实路径                    |



### 发送 HTTP 响应相关的变量

| body_bytes_sent        | 响应中 body 包体的长度 |
| ---------------------- | ---------------------- |
| bytes_sent             | 全部 http 响应的长度   |
| status                 | http 响应中的返回码    |
| sent_trailer_名字      | 把响应结尾内容里值返回 |
| **sent_http_头部名字** | 响应中某个具体头部的值 |



### Nginx 系统变量

| pipe:                    | 使用了管道，则返回p, 否则返回空                              |
| ------------------------ | ------------------------------------------------------------ |
| nginx_version:           | Nginx 版本号                                                 |
| time_local:time_iso8601: | 使用ISO 8601 标准输出的当前时间，例如 2018-11-14T15:55:37+08:00 |
| pid                      | 所属 worker 进程的进程 id                                    |
| hostname:                | 所在的服务器的主机名，与 hostname 命令输出一致               |
| msec                     | 1970年1月1日到现在的时间，单位为妙，小数点后精确到毫秒       |



## referer模块



**场景：**某网站通过url 引用了你的页面，当用户在浏览器上点击url 时，http 请求的头部中会通过referer头部，将该网站当前页面的url带上，告诉服务器本次请求是由这个页面发起的

**目的：**拒绝非正常的网站访问我们站点的资源

**思路：**通过referer模块，用invalid_referer 变量根据配置判断 referer 头部是否合法

**referer模块：**默认编译进Nginx，通过 --without-http_referer_module 禁用

### referer 指令

```
Syntax: valid_referers none | blocked | server_names | string ...;
Default: —
Context: server, location

Syntax: referer_hash_bucket_size size;
Default: referer_hash_bucket_size 64; 
Context: server, location

Syntax: referer_hash_max_size size;
Default: referer_hash_max_size 2048; 
Context: server, location
```

### valid_referers 指令

可同时携带多个参数，标示多个referer 头部都生效

**参数值：**

- none: 允许缺失 referer 头部的请求访问
- block: 允许 referer 头部没有对应的值的请求访问
- server_names: 若 referer 中站点域名与 server_name 中本机域名某个匹配，则允许该请求访问
- 表示域名及URL的字符串，对域名可在前缀或者后缀中加 * 通配符；若 referer 头部的值匹配字符串后，则允许访问
- 正则表达式：若 referer 头部的值匹配正则表达式后，则允许访问

**总结：**请求头中包含valid_referers 指令的值，则允许请求访问

**invalid_referer变量：**

- 允许访问时变量值为空
- 不允许访问时变量值为1

### 配置实例

配置文件

```nginx
server {
  listen 80;
  server_name referer.nginx.com;
  location /{
      valid_referers none blocked server_names *.nginx.cn www.baidu.com/nginx/ ~\.google\.;
      if ($invalid_referer) {
        return 403;
      }
      return 200 'valid\n';
  }
}
```

以下请求哪些会被拒绝？

```
curl -H 'referer: http://www.baidu.com/ttt' referer.nginx.com
curl -H 'referer: http://www.nginx.cn/ttt' referer.nginx.com
curl -H 'referer: ' referer.nginx.com
curl referer.nginx.com
curl -H 'referer: http://referer.nginx.com' referer.nginx.com
curl -H 'referer: http://referer.baidu.com' referer.nginx.com
curl -H 'referer: http://image.baidu.com/search/detail' referer.nginx.com
curl -H 'referer: http://image.google.com/search/detail' referer.nginx.com
```

结果测试

```nginx
# curl -H 'referer: http://www.baidu.com/ttt' referer.nginx.com
<head><title>403 Forbidden</title></head>

# curl -H 'referer: http://referer.nginx.cn/ttt' referer.nginx.com
valid

# curl -H 'referer: ' referer.nginx.com
valid

# curl  referer.nginx.com
valid

# curl -H 'referer: http://referer.nginx.com' referer.nginx.com
valid

# curl -H 'referer: http://referer.wang.com' referer.nginx.com
<head><title>403 Forbidden</title></head>

# curl -H 'referer: http://image.baidu.com/search/detail' referer.nginx.com
<head><title>403 Forbidden</title></head>

# curl -H 'referer: http://image.google.com/search/detail' referer.nginx.com
valid
```





## secure_link模块

由于攻击者很容易伪造referer头部，那么防盗链功能就会失效，因此，就有了secure_link模块，它提供了安全的防盗链方式，避免了此类问题发生。

**作用： **解决referer模块防盗链不安全问题

**通过验证URL中哈希值的方式防盗链**

**过程：**

- 由某服务器（也可以是nginx）生成加密后的安全链接url, 返回给客户端
- 客户端使用安全url 访问nginx, 由nginx 的secure_link 变量判断是否验证通过

**原理：**

- 哈希算法是不可逆的
- 客户端只能拿到执行过哈希算法的URL
- 仅生成URL 的服务器和验证URL 是否安全的nginx 这二者，才保存执行哈希算法前的原始字符串（服务器和nginx是知道原始字符串的）
- 原始字符串通常由以下部分有序组成
  - 资源位置，例如HTTP 中指定资源的URI, 防止攻击者拿到一个安全的URL 后可以访问任意资源
  - 用户信息，例如用户IP地址，限制其他用户盗用安全URL
  - 时间戳，使安全URL 及时过期
  - 密钥，服务器端和nginx拥有，增加攻击者猜测出原始字符串的难度

**变量：**

- secure_link
- secure_link_expires

**模块：**

- ngx_http_secure_link_module
- 默认未编译进nginx
- 需要通过 --with-http_secure_link_module 添加

**secure_link 指令**

```
Syntax: secure_link expression;
Default: —
Context: http, server, location

Syntax: secure_link_md5 expression;
Default: —
Context: http, server, location

Syntax: secure_link_secret word;
Default: —
Context: location
```



### 变量值及带过期时间的配置

**变量**

- secure_link
  - 值为空字符串：验证不通过
  - 值为0: URL过期
  - 值为1: 验证通过
- secure_link_expires: 时间戳的值

**命令行生成安全链接：**

原请求：

```
/test1.txt?md5=md5生成值&expires=时间戳（如2147483647）
```

生成md5: 

```
echo -n “时间戳 URL 客户端IP 密钥” | openssl md5 -binary | openssl base64 | tr +/ - | tr -d =
```

**nginx配置：**

- secure_link $arg_md5,$arg_expires;
- secure_link_md5 “$secure_link_expires$uri$remote_addr secret”;



###  secure_link实例

重新编译nginx

```
./configure --prefix=/home/jeek/nginx --with-http_ssl_module --with-http_secure_link_module && make
```

配置文件

```nginx
server {
listen  80;
server_name secure.nginx.com
location /{
    secure_link $arg_md5,$arg_expires;
    secure_link_md5 "$secure_link_expires$uri$remote_addr secret";
    
    if ($secure_link = ""){
        return 403;
    }
    if ($secure_link = "0"){
        return 410;
    }
    return 200 '$secure_link:$secure_link_expires\n';
}
}
```

结果测试

```shell
# echo -n '2147483647/test1.txt192.168.70.13 secret' | openssl md5 -binary | openssl base64 | tr +/ - | tr -d =
dIiXNBt9lkWPzEHwmpfZRw
# curl 'secure.nginx.com/test1.txt?md5=dIiXNBt9lkWPzEHwmpfZRw&expires=2147483647'
1:2147483647
```



### 仅对URL 进行哈希配置

1. 将请求URL 分为三个部分
2. Hash 生成方式：对“link 密钥” 做md5 哈希求值
3. 用 secure_link_secret secret; 配置密钥

**命令行生成安全链接：**

1. 原请求：link
2. 生成的安全请求：/prefix/md5/link
3. 生成的md5: echo -n ‘linksecret’ | openssl md5 -hex

**Nginx 配置：**

- secure_link_secret secret;



### secure_link_secret实例

配置文件

```nginx
location /p/ {
    secure_link_secret mysecret2;
    
    if ($secure_link = ""){
        return 403;
    }
    rewrite ^ /secure/$secure_link;
}
location /secure/ {
    alias html/;
    internal;
}
```

结果测试

```shell
# echo -n 'test1.txtmysecret2' | openssl md5 -hex                    
(stdin)= c3f9b32bf901b04c052ea9511e29a918
# curl 'secret.nginx.com/p/c3f9b32bf901b04c052ea9511e29a918/test1.txt'
```



## map 使用详解



### map 指令介绍：

map 指令是由 ngx_http_map_module 模块提供的，默认情况下安装 nginx 都会安装该模块。

map 的主要作用是创建自定义变量，通过使用 nginx 的内置变量，去匹配某些特定规则，如果匹配成功则设置某个值给自定义变量。 而这个自定义变量又可以有其它用途。



**Map 模块的指令**

```bash
Syntax:	map string $variable { ... }
Default:	—
Context: http

Syntax:	map_hash_bucket_size size;
Default: map_hash_bucket_size 32|64|128;
Context: http

Syntax:	map_hash_max_size size;
Default: map_hash_max_size 2048;
Context: http
```



**Map 模块的规则**

![截屏2021-03-08 上午10.37.09](/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-08 上午10.37.09.png)



Map 模块的示例

测试配置文件如下:

```shell
map $http_host $name {
    hostnames; #dns反解析

    default       0;

    ~map\.tao\w+\.org.cn 1;
    *.taohui.org.cn   2;
    map.taohui.tech   3;
    map.taohui.*    4;
}

# 当$http_user_agent 值 = "~Opera Mini"  那么我们就将 $mobile值设置为 1 否则就设置为 0
map $http_user_agent $mobile {
    default       0;
    "~Opera Mini" 1;
}

server {
	listen 10001;
	default_type text/plain;
	location /{
		return 200 '$name:$mobile\n';
	}
}
```

测试结果:

```shell
#前缀匹配
[root@nginx ~]# curl -H 'Host: map.taohui.org.cn' 192.168.10.141:10001
2:0
#正则表达式匹配
[root@nginx ~]# curl -H 'Host: map.taohui123.org.cn' 192.168.10.141:10001
1:0
#后缀匹配
[root@nginx ~]# curl -H 'Host: map.taohui.pub' 192.168.10.141:10001
4:0
#字符串严格匹配
[root@nginx ~]# curl -H 'Host: map.taohui.tech' 192.168.10.141:10001
3:0
#字符串严格匹配
[root@localhost ~]# curl -H 'User-Agent:Opera Mini' -H 'Host: map.taohui.pub' 192.168.10.141:10001
4:1
```

生产环境案例: 作用灰度发布

```nginx
http {

    map_hash_bucket_size 64;

    map $http_x_group_env $svc_upstream {
        default zxl-test-splitflow-old-version;
        ~*old zxl-test-splitflow-old-version;
        ~*new zxl-test-splitflow-new-version;
    }
    
    
    upstream zxl-test-splitflow-old-version {
        server 10.168.173.29:8080 max_fails=1 fail_timeout=2;
    }

    upstream zxl-test-splitflow-new-version {
        server 10.168.177.171:8080 max_fails=1 fail_timeout=2;
    }
    
    server {
        listen 8998;
        server_name aa.hc.harmonycloud.cn;
        location /testdemo/test {
            proxy_pass http://$svc_upstream;
        }
    }
}
```





## 通过split_client模块灰度测试

​		灰度测试或者AB测试，这个概念我相信大家都不陌生了，也是互联网公司常见的迭代方式。最近公司有个很老的SDK项目，完全的面向过程方式，很难维护和管理，所以决定在此基础上对此SDK项目进行重构，使用面向对象风格编写代码，经过大概两周的努力，顺利迁移sdk项目，但是目前还有项目在使用以前的SDk，此时需要一个过渡方案，一部分用户还是正常使用以前的SDK，而一部分少量的用户直接走新的接口，最终我们采用了nginx的split_client模块进行灰度测试。


### 实现AB测试：split_clients

功能：基于已有变量，创建新变量，为其他AB 测试提供更多的可能性

- 对已有变量的值执行 VMurmurHash2 算法，得到 32 位整形哈希数字，记为hash
- 32 位无符号整型的最大数字 2^32-1，记为max
- 哈希数字与最大数字相除 hash/max，可以得到百分比percent
- 配置指令中指示了各个百分比构成的范围，如0-1%，1%-5%等，及范围对应的值
- 当percent 落在哪个范围里，新变量的值就对应着其后的参数

模块：

- ngx_http_split_clients_module
- 默认编译进Nginx
- 通过 –without-http_split_clients_moudule 禁用

### **规则**

**已有变量：**

- 字符串
- 一个或多个变量
- 变量和字符串的结合

**case规则：**

- xx.xx%, 支持小数点后2位， 所有项的百分比相加不能超过100%
- *，有它匹配剩余的百分比（100%减去以上所有项相加的百分比）



### split_clients 模块的指令

```
Syntax: split_clients string $variable { ... }
Default: —
Context: http
```

### 配置示例

配置文件:split-clients.conf

```shell
split_clients "${http_testcli}" $variant {
    0.51% .one;
    20.0% .two;
    50.5% .three;
    # 40% .four;
    * "";
}

server {
        listen 10002;
        server_name split_clients.taohui.tech;
        error_log  /var/log/nginx/error.log  debug;
        default_type text/plain;
        location /{
                return 200 'ABtestfile$variant\n';
        }
}
```

结果测试

```shell
# curl -H 'testcli: 456abcabcaddd'  192.168.10.141:10002   
ABtestfile.three

# curl -H 'testcli: 456abcabcafff'  192.168.10.141:10002
ABtestfile.two
```



reference

* [灰度发布](https://blog.csdn.net/qq_32019789/article/details/108143853)



## geo模块

**功能：**根据IP地址创建新变量,根据IP地址范围的匹配生成新变量：

**指令：**

```
Syntax: geo [$address] $variable { ... }
Default: —
Context: http
```

**模块：**

- ngx_http_geo_module
- 默认编译进nginx
- 通过 –without-http_geo_module 禁用

**规则:**

1. 如果 geo 指令后，不输入 $address，那么默认使用 $remote_addr变量作为IP地址
2. { } 内的指令匹配：优先最长匹配
   - 通过IP地址及子网掩码的方式，定义 IP 范围，当 IP 地址在范围内时新变量使用其后的参数值
   - default 指定了当以上范围都未匹配上时，新变量的默认值
   - 通过proxy 指令指定可信地址（参考realip 模块），此时 remote_addr 的值为X-Forwarded-For 头部值中最后一个 IP 地址
   - proxy_recursive 允许循环地址搜索
   - include, 优化可读性
   - delete 删除指定网络

### 案例测试

配置文件:geo.conf

注意⚠️：必须有realip 模块

```
geo $country {
    default ZZ;
    #include conf/geo.conf;
    proxy 192.168.10.122; #nginx ip address,默认时使用remote_addr,相当于配置set_realip
    
    127.0.0.0/24 US;
    127.0.0.1/32 RU;
    10.1.0.0/16 RU;
    192.168.1.0/24 UK;
}

server {
    listen 8011;
    server_name geo.nginx.com;
    return 200 'country:$country\n';
}
```

问题：以下命令执行时，变量 country 的值各为多少？（proxy 为客户端地址）

1. curl -H 'X-Forwarded-For: 10.1.0.0,127.0.0.2' geo.nginx.com:8011
2. curl -H 'X-Forwarded-For: 10.1.0.0,127.0.0.1' geo.nginx.com:8011
3. curl -H 'X-Forwarded-For: 10.1.0.0,127.0.0.1,1.2.3.4' geo.nginx.com:8011

结果测试：

```
# curl -H 'X-Forwarded-For: 10.1.0.0,127.0.0.2' geo.nginx.com:8011
country:US
# curl -H 'X-Forwarded-For: 10.1.0.0,127.0.0.1' geo.nginx.com:8011
country:RU
# curl -H 'X-Forwarded-For: 10.1.0.0,127.0.0.1,1.2.3.4' geo.nginx.com:8011
country:ZZ
```





## geoip模块

**功能：**根据IP 地址创建新变量,基于 MaxMind 数据库从客户端地址获取变量：geoip

**流程：**

1. 安装 MaxMind 里geoip 的C开发库 （https://dev.maxmind.com/geoip/legacy/downloadable/ ）
2. 编译 nginx 时带上 –with-http_geoip_module 参数
3. 下载 MaxMind 中的二进制地址库
4. 使用geoip_country 或者 geoip_city 指令配置好 nginx.conf
5. 运行（或者升级 nginx）

**模块：**

- ngx_http_geoip_module
- 默认未编译进nginx
- 通过 --with-http_geoip_module 启用

### geoip_country 指令提供的变量

```
Syntax: geoip_country file;
Default: —
Context: http

Syntax: geoip_proxy address | CIDR;
Default: —
Context: http
```

变量：

- $geoip_country_code：两个字母的国家代码，比如CN 或者 US
- $geoip_country_code3: 三个字母的国家代码，比如CHN 或者 USA
- $geoip_country_name: 国家名字，例如 “China”, “United States”

### geoip_city 指令提供的变量

```
Syntax: geoip_city file;
Default: —
Context: http
```

### geoip_city 指令提供的变量

- $geoip_latitude：纬度
- $geoip_longitude：经度
- $geoip_city_continent_code：属于全球哪个洲，例如EU 或者 AS
- 与geoip_country 指令生成的变量重叠
  - $geoip_country_code：两个字母的国家代码，比如CN 或者 US
  - $geoip_country_code3: 三个字母的国家代码，比如CHN 或者 USA
  - $geoip_country_name: 国家名字，例如 “China”, “United States”
- $geoip_region：洲或者省的编码，例如02
- $geoip_region_name：洲或者省的名称，例如Zhejiang 或者 Saint Petersburg
- $geoip_city：城市名
- $geoip_postal_code：邮编

### 案例演示：

**依赖包缺失，未能实际操作**

```shell
wget https://github.com/maxmind/geoip-api-c/releases/download/v1.6.12/GeoIP-1.6.12.tar.gz 
tar zxf GeoIP-1.6.12.tar.gz
cd GeoIP-1.6.12/
./configure && make && make install

git clone https://github.com/mbcc2006/GeoLiteCity-data.git
cd GeoLiteCity-data/
mv  GeoLiteCity.dat  /usr/share/GeoIP/
```

配置文件：geoip.conf

```shell
#在http模块加入GeoIP库的路径
geoip_country         /usr/share/GeoIP/GeoIP.dat;
geoip_city            /usr/share/GeoIP/GeoLiteCity.dat;
geoip_proxy           192.168.10.122;
geoip_proxy_recursive on;

server {
        listen 8023;
        server_name geoip.taohui.tech;
        error_log logs/myerror.log info;
        keepalive_requests 2;
        keepalive_timeout 75s 20;
        location /{
             return 200 'country:$geoip_country_code,$geoip_country_code3,$geoip_country_name
     country from city:$geoip_city_country_code,$geoip_city_country_code3,$geoip_city_country_name
     city:$geoip_area_code,$geoip_city_continent_code,$geoip_dma_code
     $geoip_latitude,$geoip_longitude,$geoip_region,$geoip_region_name,$geoip_city,$geoip_postal_code\n';
         }
     }
```

测试结果:

```shell
[root@localhost ~]# curl -H 'X-Forwarded-For: 183.146.45.2,77.48.21.58,104.248.224.193' geoip.taohui.tech:8023
country:US,USA,United States
     country from city:US,USA,United States
     city:302,NA,504
     39.7157,-75.5281,DE,Delaware,Wilmington,19801
[root@localhost ~]# curl -H 'X-Forwarded-For: 183.146.45.2,77.48.21.58' geoip.taohui.tech:8023
country:CZ,CZE,Czech Republic
     country from city:CZ,CZE,Czech Republic
     city:0,EU,0
     49.7689,13.8406,88,Stredocesky kraj,Zajecov,335 01
[root@localhost ~]# curl -H 'X-Forwarded-For: 183.146.45.2' geoip.taohui.tech:8023
country:CN,CHN,China
     country from city:CN,CHN,China
     city:0,AS,0
     29.1068,119.6442,02,Zhejiang,Jinhua,
```



## Nginx对客户端提升连接效率

功能：多个HTTP 请求通过复用 TCP 连接，实现以下功能

- 减少握手次数
- 通过减少并发连接数减少服务器的资源消耗
- 降低 TCP 拥塞控制的影响

**协议：**nginx向客户端返回响应,可以增加的头部

* Connetcion 头部：取值为 close 或者 keepalive

  ​	close：表示处理完即关闭连接

  ​	keepalive：表示复用连接处理下一条请求

* Keep-Alive 头部：其值为timeout=n, 后面的数字 n 单位是妙，告诉客户端，连接至少保留n妙。

**keepalived指令**

```
#对某些浏览器不做长链接
Syntax:	keepalive_disable none | browser ...;
Default:	keepalive_disable msie6;
Context:	http, server, location

#一个活动连接上的最大请求数。发出最大数量的请求后，将关闭连接。
Syntax:	keepalive_requests number;
Default:	keepalive_requests 100;
Context:	http, server, location

#第一个参数，一个http请求到达,经过timeout时间依然没有请求,就会关闭连接. 可选的第二个参数 nginx通过keepalive头部,这个链接应该保留多少秒
Syntax:	keepalive_timeout timeout [header_timeout];
Default:	keepalive_timeout 75s;
Context:	http, server, location
```



# 反向代理和负载均衡



## 反向代理与负载均衡原理



### **Nginx在AKF上应用**

​		在X轴扩展是最简单的，nginx中Round-Robin 或者 least-connected 算法都是基于水平扩展，将用户的请求分发到不同的客户端，但是无法解决数据量的问题。单台数据量非常大的时候，无论增加多少台服务器，每台服务的数量量依然非常大。我们可以从Y轴扩展，基于url对功能进行拆分，在不同集群的功能不同。不同的url, 通过location代理到上游服务器进行处理，来解决数量大的问题。通常要做代码的重构和更改，成本很高。如果想更小的代价做这样的事情，可以通过Z轴来实现，通过用户ip地址或其它信息映射到某个特定的服务或者集群。

<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-04-04 上午12.02.48.png" alt="截屏2021-04-04 上午12.02.48" style="zoom:67%;" />

**总结：**

- X轴: 基于Round-Robin 或者 least-connected 算法分发请求
- Y轴: 基于 URL 对功能进行分发
- Z轴：将用户 IP 地址或者其他信息映射到某个特定的服务或者集群

### 支持多种协议反代

<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-04-04 上午12.33.51.png" alt="截屏2021-04-04 上午12.33.51" style="zoom:50%;" />

- udp -> nginx -> udp
- tcp -> nginx -> tcp
- http -> nginx -> http, websocket, memcached, scgi, fstcgi, uwsgi, grpc

**主要功能：反向代理和缓存**



## 负载均衡策略：round-robin



### upstream 模块

​		Nginx 的 stream 模块和 http 模块分别支持四层和七层模块的负载均衡。其用法和支持的负载均衡策略大致相同。首先使用 upstream 指令块 和 server 指令指定上游的服务，

**功能：**指定一组上游服务器地址，其中地址可以是域名、IP地址或者 unix socket 地址。可以在域名或者IP地址后加端口，如果不加端口，那么默认使用80端口。

**指令**

```nginx
Syntax: upstream name { ... }
Default: —
Context: http

Syntax: server address [parameters];
Default: —
Context: upstream
```

**通用参数**

- backup : 指定当前server 为备份服务，仅当非备份 server 不可用时，请求才会转发到该server
- down : 标识某台服务已经下线，不再服务



### 加权Round-Robin算法

**功能：**

- 在加权轮训的方式访问 server 指令指定的上游服务
- 集成在 Nginx 的 upstream 框架中,不允许被移除

**指令：**

- weight : 服务访问的权重，默认是1
- max_conns : server的最大并发连接数，仅作用于单 worker 进程，默认是0，表示没有限制。
- max_fails : 在fail_timeout 时间段内，最大的失败次数。当达到最大失败时，会在 fail_timeout 秒内这台 server 不允许再次被选择
- fail_timeout : 单位为妙，默认10秒，具有2个功能:
  - 指定一段时间内，最大的失败次数 max_fails
  - 到达max_fails 后，该server 不能访问的时间



### 对上游服务使用keepalive

**注意:** nginx 默认采用http1.0协议，短链接； http1.1协议（默认长连接）

**功能：**通过复用连接，降低 nginx 与上游服务器建立、关闭连接的消耗，提升吞吐量的同时降低时延

**模块：**

- ngx_http_upstream_keepalive_module
- 默认编译进Nginx
- 通过 --without-http_upstream_keepalive_module 禁用模块

**对上游连接的 http 头部设定**

```
proxy_http_version 1.1;
proxy_set_header Connection "";
```

### upstream_keepalive指令

```
Syntax: keepalive connections; #最多保持多少个tcp空闲连接等待请求
Default: -
Context: upstream

1.15.3新增命令
Syntax: keepalive_requests number;#一个tcp连接上的最多用多少个请求
Default: keepalive_requests 100; 
Context: upstream

Syntax: keepalive_timeout timeout; #一个tcp链接最多久断开链接
Default: keepalive_timeout 60s; 
Context: upstream
```

### resolver指令

**功能：** 用于为上游服务器做dns解析服务器地址

```
Syntax: resolver address ... [valid=time] [ipv6=on|off];
Default: —
Context: http, server, location

Syntax: resolver_timeout time;
Default: resolver_timeout 30s; 
Context: http, server, location
```

### 配置示例

上游服务: backed.conf

```nginx
server {
    listen 8011;
    return 200 '8011 server respose\n';
}
server {
    listen 8012;
    return 200 '8012 server respose\n';
}
```

代理服务: keepalive.conf

```nginx
upstream rrups{
    server 127.0.0.1:8011 weight=2 max_conns=2 fail_timeout=5;
    server 127.0.0.1:8012;
    keepalive 32;
}
server {
    server_name keepalive.nginx.com;
    location / {
        proxy_pass http://rrups;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
```

结果测试

```shell
# curl http://keepalive.nginx.com/
8011 server respose
# curl http://keepalive.nginx.com/
8011 server respose
# curl http://keepalive.nginx.com/
8012 server respose
```

tcp监听地址

```
# tcpdump -i lo port 8011
18:18:50.480628 IP localhost.36412 > localhost.8011: Flags [S], seq 3437835566, win 43690, options [mss 65495,sackOK,TS val 292212905 ecr 0,nop,wscale 7], length 0
18:18:50.480647 IP localhost.8011 > localhost.36412: Flags [S.], seq 3703467240, ack 3437835567, win 43690, options [mss 65495,sackOK,TS val 292212906 ecr 292212905,nop,wscale 7], length 0
18:18:50.480656 IP localhost.36412 > localhost.8011: Flags [.], ack 1, win 342, options [nop,nop,TS val 292212906 ecr 292212906], length 0
18:18:50.480678 IP localhost.36412 > localhost.8011: Flags [P.], seq 1:70, ack 1, win 342, options [nop,nop,TS val 292212906 ecr 292212906], length 69
18:18:50.480682 IP localhost.8011 > localhost.36412: Flags [.], ack 70, win 342, options [nop,nop,TS val 292212906 ecr 292212906], length 0
18:18:50.480715 IP localhost.8011 > localhost.36412: Flags [P.], seq 1:183, ack 70, win 342, options [nop,nop,TS val 292212906 ecr 292212906], length 182
```

一次完整请求的访问报文

```shell
18:25:01.262713 IP localhost.36582 > localhost.8011: Flags [S], seq 4136017620, win 43690, options [mss 65495,sackOK,TS val 292583688 ecr 0,nop,wscale 7], length 0
18:25:01.262721 IP localhost.8011 > localhost.36582: Flags [S.], seq 2978684598, ack 4136017621, win 43690, options [mss 65495,sackOK,TS val 292583688 ecr 292583688,nop,wscale 7], length 0
18:25:01.262729 IP localhost.36582 > localhost.8011: Flags [.], ack 1, win 342, options [nop,nop,TS val 292583688 ecr 292583688], length 0
18:25:01.262750 IP localhost.36582 > localhost.8011: Flags [P.], seq 1:89, ack 1, win 342, options [nop,nop,TS val 292583688 ecr 292583688], length 88
18:25:01.262753 IP localhost.8011 > localhost.36582: Flags [.], ack 89, win 342, options [nop,nop,TS val 292583688 ecr 292583688], length 0
18:25:01.262793 IP localhost.8011 > localhost.36582: Flags [P.], seq 1:178, ack 89, win 342, options [nop,nop,TS val 292583688 ecr 292583688], length 177
18:25:01.262796 IP localhost.36582 > localhost.8011: Flags [.], ack 178, win 350, options [nop,nop,TS val 292583688 ecr 292583688], length 0
18:25:01.262832 IP localhost.8011 > localhost.36582: Flags [F.], seq 178, ack 89, win 342, options [nop,nop,TS val 292583688 ecr 292583688], length 0
18:25:01.262862 IP localhost.36582 > localhost.8011: Flags [F.], seq 89, ack 179, win 350, options [nop,nop,TS val 292583688 ecr 292583688], length 0
18:25:01.262868 IP localhost.8011 > localhost.36582: Flags [.], ack 90, win 342, options [nop,nop,TS val 292583688 ecr 292583688], length 0
```

备注：tcpdump用法

```
# tcpdump -p -nnn -vvv -i eth0 dst host 10.200.7.54 or src host 172.17.2.65 and port 8080 -w dump.cap -s0
```





## 负载均衡Hash算法



### 基于客户端IPHash 算法

**功能：**以客户端的IP地址作为hash 算法的关键字，映射到特定的上游服务器中。

- 对IPV4 地址使用前三个字节作为关键字，对 IPV6 则使用完整地址
- 可以使用 round-robin 算法的参数
- 可以基于realip 模块修改用于执行算法的IP地址

**模块：**

- ngx_http_upstream_ip_hash_module
- 默认编译进Nginx
- 通过 --without-http_upstream_ip_hash_module 禁用

**指令**

```nginx
Syntax: ip_hash;
Default: —
Context: upstream
```



### 基于key实现Hash算法

**功能：**通过指定关键字作为 hash key, 基于 hash 算法映射到特定的上游服务器中

- 关键字可以含有变量，字符串
- 可以使用 round-robin 算法的参数

**模块：**

- ngx_http_upstream_hash_module
- 默认编译进Nginx
- 通过 --without-http_upstream_ip_hash_module 禁用模块

**指令**

```nginx
Syntax: hash key [consistent];
Default: —
Context: upstream
```

### 配置示例

配置文件 ip_hash.conf

```nginx
server {
    listen 127.0.0.1:8011;
    return 200 "8011 server respose\n";
}
server {
    listen 127.0.0.1:8012;
    return 200 "8012 server respose\n";
}
upstream iphashups {
    ip_hash;
    # hash user_$arg_username;
    server 127.0.0.1:8011 weight=2 max_conns=2 fail_timeout=5;
    server 127.0.0.1:8012;
}
server {
    listen 80;
    server_name iphash.nginx.com;
    
    location / {
        proxy_pass http://iphashups;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
```

测试结果

```shell
# curl iphash.nginx.com
8012 server respose
# curl  iphash.nginx.com
8012 server respose
# curl iphash.nginx.com  
8011 server respose
```

修改配置文件如下

```nginx
# ip_hash;
hash user_$arg_username;
```

测试结果

```shell
# curl iphash.nginx.com/?username=wangsan
8012 server respose
# curl iphash.nginx.com/?username=wangsan
8012 server respose
# curl iphash.nginx.com/?username=lisi
8011 server respos
```



## 一致性Hash算法

### Hash 算法的问题

​		宕机或者扩容时，hash 算法引发大量路由变更，可能导致缓存大范围失效

**解决方法：一致性 Hash 算法**  由upstream_hash模块提供, 可以避免大量的缓存失效

​		使用一致性 Hash 算法：`hash key [consistent];`

**指令**

```nginx
Syntax:	hash key [consistent];
Default:	—
Context:	upstream
```

[一致性hash算法](https://zhuanlan.zhihu.com/p/129049724)



## 最少连接算法

### upstream_least_conn模块

**功能：**从所有上游服务器中，找出当前并发连接数最少的一个，将请求转发给它如果出现多个最少连接服务器的连接数都是一样的，退化使用 round-robin 算法。

**指令：**

```nginx
Syntax: least_conn;
Default: —
Context: upstream
```

**模块：**

- ngx_http_upstream_ least_conn _module
- 默认编译进Nginx
- 通过 --without-http_upstream_ip_hash_module 禁用模块

### upstream_zone模块

**功能：**分配出共享内存，将其他 upstream 模块定义的负载均衡策略数据、运行时每个上游服务的状态数据存放在共享内存上，以对所有 nginx worker 进程生效

**指令**

```nginx
Syntax: zone name [size];
Default: —
Context: upstream
```

**模块：**

- ngx_http_upstream_ zone _module
- 默认编译进Nginx
- 通过 --without-http_upstream_ip_hash_module 禁用模块

### upstream 模块间的顺序

编译时，配置文件中模块的顺序，从上到下，依次运行

```c
ngx_module_t *ngx_modules[] = {
… … 
&ngx_http_upstream_hash_module, 
&ngx_http_upstream_ip_hash_module, 
&ngx_http_upstream_least_conn_module, 
&ngx_http_upstream_random_module, 
&ngx_http_upstream_keepalive_module, 
&ngx_http_upstream_zone_module,
… …
};
```



## upstream 模块提供的变量

### upstream 模块提供的变量(不含缓存)

- upstream_addr : 上游服务器的IP地址，格式为可读的字符串，例如127.0.0.1:8012
- upstream_connect_time : 与上游服务器建立连接消耗的时间，单位为妙，精确到毫秒
- upstream_header_time : 接收上游服务发回响应中 http 头部所消耗的时间，单位为妙，精确到毫秒
- upstream_reponse_time : 接收完整的上游服务器的响应消耗的时间，单位为妙，精确到毫秒
- upstream_http_名称 : 从上游服务返回的响应头部的值
- upstream_bytes_received : 从上游服务接收到的响应长度，单位为字节

- upstream_repose_length : 从上游服务返回的响应包体长度，单位为字节
- upstream_status : 上游服务返回的 HTTP 响应中的状态码。如果未连接上，该变量值为502
- upstream_cookie_名称 ：从上游服务返回的响应头 Set-Cookie 中取出的 cookie 值
- upstream_trailer_名称 : 从上游服务的响应尾部取到的值

### 配置示例

添加日志配置文件

```nginx
log_format  varups  '$upstream_addr $upstream_connect_time $upstream_header_time $upstream_response_time '
                        '$upstream_response_length $upstream_bytes_received '
                        '$upstream_status $upstream_http_server $upstream_cache_status';
```

访问nginx并检查日志

```shell
# curl http://upstream.nginx.com/
# tail logs/upstream.log 
127.0.0.1:8011 0.001 0.001 0.001 20 182 200 nginx/1.14.0 -
```



## proxy模块处理请求流程

### HTTP 反向代理流程

![nginxproxy](/Users/jinhuaiwang/Documents/k8s-onenote/nginx/picture/nginxproxy.jpg)



#### **判断proxy缓存**

​		proxy模块是在content阶段发生，对于一个到来的请求，首先会判断是否开启了proxy_cache，如果开启了缓存，并且命中会直接将缓存文件中对应的key的内容返回。通常会对一些变化不频繁的内容做缓存以减轻nginx和上游服务器的压力。

#### 构造发送给上游的header与body

​		proxy模块提供了很多指令来改变发给上游请求的headers和body，比如proxy_set_header，proxy_set_body，proxy_request_pass_request，prxy_request_pass_headers等等。nginx会先根据这些指令的内容生成header和body。（客户端请求的headers是在请求的11个阶段开始之前nginx框架就接受了，因为设计到分配变量，选择server，location等等）

#### **读取请求body**

​		上一步提到了，客户端与nginx建立连接后，nginx不会立即与上游服务器建立连接，先生成header和body，如果用户发送的是一个post请求，那么nginx通常是会先将客户端请求的body读取完再建立连接（由proxy_request_buffering指令决定，而且不管proxy_set_body，proxy_pass_request_body这些指令的设置如何，用户请求的body肯定是要接受的，是否redefine或者丢弃是另外一回事），这么做的好处是对于并发支持有限的上游服务器，这是一种能提升并发能力的做法，举一个例子，先做以下假设

1. 客户端的请求是上传一个文件，文件size比较大
2. 客户端的上行带宽有限
3. 上游服务器和nginx处于同一个内网中

​		这时候如果我们没有打开proxy_request_buffering，那么nginx会立即与上游服务器建立连接，然后边接受客户端的请求内容，边将内容发给上游，此时如果上游服务器的并发连接数比较小，而这个请求可能会很长，如果此时有多个这样的上传请求，那么上游服务器的并发能力就会下降。如果打开了buffering，那么nginx会等所有的上传文件内容都接受完，再建立连接发送给上游，那么这次请求处理的就很快（内网网速非常快）。这样虽然对客户端来说没有什么区别，但是却能提升上游服务器的并发能力。

#### **选择服务器**

在上一步打开proxy_request_buffering后，nginx接受完完整请求的body（body保存在临时文件中），nginx会根据upstream中指定的负载均衡算法来选择一台上游服务器提供服务。

#### **建立连接，发送请求**

​		确定了连接的上游服务器，nginx便开始根据指定的参数（比如max_conn，fail_timeout等TCP连接参数）与上游服务器建立连接，连接建立成功后就开始将客户端请求的内容转发给上游。

#### **接受响应**

​		上游服务器处理完请求，nginx开始接受响应，包括header和body（先是header再是body），这时又会有一个proxy_buffering来决定nginx的行为，如果打开了proxy_buffering，那么nginx会等接受完完整的上游响应body后（Tips：1.如果body小于proxy_buffers设置的大小，通常为64K，那么即使打开proxy_buffering，也不会保存到临时文件中。2. 如果上游服务器的响应headers里有X-Accel-Buffering: yes|no，会覆盖proxy_buffering的指值。 3.如果headers的大小大于proxy_buffer_size大小，或产生502错误），再发给客户端，通常nginx与上游都是在同一个内网中，所以这个配置是打开的。在这一步，nginx同样提供了很多指令来改变发给客户端的响应内容。

#### **保存缓存**

​		如果打开了proxy_cache，那么nginx会将响应内容保存到缓存文件中，cache的行为包括缓存文件的路径，缓存内容的key的规则，keys对应的共享内存的name和size等等都有不同的指令完成。

#### **关闭或复用连接**

​		上一步中，如果没有打开cache，那么nginx会根据upstream中keepalive指令来决定是否关闭或者复用tcp连接。

 

(tip: nginx作为负载均衡服务，通常与上游的连接数理论上最大为65535个（local port限制），如果想要提高并发数，增加上游服务的ip数量或者监听的端口数量来避开linux的系统限制)

 

以上就是proxy_module处理和转发请求的大致流程，其中有一些细节十分巧妙，nginx就是这样，在很多功能上的设计都是如此，这也是它越发流行的原因之一吧。



## proxy 模块

**功能**：对上游服务使用 http/https 协议进行反向代理

**指令**

```nginx
Syntax: proxy_pass URL;
Default: —
Context: location, if in location, limit_except
```

**模块：**

- ngx_http_proxy_module
- 默认编译进Nginx
- 通过 --without-http_proxy_module 禁用模块

**URL规则**

- URL 必须以 http:// 或者 https:// 开头，接下来是域名、IP、unix socket 地址 或者 upstream 的名字，前两者可以在域名或者IP后加端口。最后是可选的URI
- 当 URL 参数中携带 URI 与否，会导致发向上游请求的 URL 不同
  - 不携带 URI ,则将客户端请求中的URL 直接转发给上游
    - location 后使用正则表达式、@名字时，应采用这种方式
  - 携带 URI, 则对用户请求中的 URI 作如下操作：
    - 将 location 参数中匹配上的一段替换为该 URI
- 该 URL 参数中可以携带变量
- 更复杂的 URL 替换，可以在 lcoation 内的配置添加 rewrite break 语句

### 配置示例

**proxy_pass 不携带uri时**

nginx反向代理配置文件：proxy.conf

```nginx
upstream proxyups {
    server 127.0.0.1:8012 weight=1;
}
server {
    server_name proxy.nginx.com;
    location /a {
        proxy_pass http://proxyups/;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
```

上游应用配置文件 server.conf

```nginx
server {
     listen 8012;
     default_type text/plain;
     return 200 '8012 server response.
     uri: $uri\n';
}
```

结果测试

```shell
# curl http://proxy.nginx.com/a/b/c
8012 server respose
uri:/a/b/c
```



**proxy_pass 携带uri时**

修改配置文件proxy.conf 

```nginx
proxy_pass http://proxyups/www;
```

再次结果测试

```shell
# curl http://proxy.nginx.com/a/b/c
8012 server respose
uri:/www/b/c
```



## 修改发往上游的请求

### 生成发往上游的请求行

指令

```
#设置发送给上游的请求方法：GET，PUT，DELETE，POST。
Syntax: proxy_method method;
Default: —
Context: http, server, location

#设置发送给上游的http请求版本。
Syntax: proxy_http_version 1.0 | 1.1;
Default: proxy_http_version 1.0; 
Context: http, server, location
```

### 生成发往上游的请求头部

```
#设置请求头发送给上游
Syntax: proxy_set_header field value;
Default: proxy_set_header Host $proxy_host;
         proxy_set_header Connection close; 
Context: http, server, location
注意⚠️：若value 的值为空字符串，则整个header 都不会向上游发送

#是否将用户请求的头部发送给上游，默认是发的。
Syntax: proxy_pass_request_headers on | off;
Default: proxy_pass_request_headers on; 
Context: http, server, location
```

### 生成发往上游的包体

```
#是否将用户请求的主体发送给上游，默认是发的。
Syntax: proxy_pass_request_body on | off;
Default: proxy_pass_request_body on; 
Context: http, server, location

#自定义body发送给上游。
Syntax: proxy_set_body value;
Default: —
Context: http, server, location
```

### 配置示例

nginx做反向代理的配置文件proxy.conf

```nginx
upstream proxyupstream {
    server 127.0.0.1:8012 weight=1;
}
server {
    server_name proxy.nginx.com;
    
    location /a {
        proxy_pass http://proxyupstream;
        # proxy_method POST;
        # proxy_pass_request_headers off;
        # proxy_pass_request_body off;
        # proxy_set_body 'hello world';
        # proxy_set_header name '';
        # proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
```

修改8012 后端服务的返回值

```nginx
server {
    listen 8012;
    return 200 '8012 server respose
uri:$uri
method: $request_method
request: $request
http_name: $http_name
\n';
}
```

结果测试

```shell
$ curl -H 'name: suse' http://proxy.nginx.com/a/b/c
8012 server respose
uri:/www/b/c
method: GET
request: GET /a/b/c HTTP/1.0
http_name: suse
```

修改 proxy.conf 配置文件，取下下面的注释

```nginx
proxy_method POST;
proxy_pass_request_headers off;
proxy_http_version 1.1;
```

结果测试：

method方法被修改，http_name返回值为空

```shell
# curl -H 'name: suse' http://proxy.nginx.com/a/b/c
8012 server respose
uri:/www/b/c
method: POST
request: POST /a/b/c HTTP/1.1
http_name:
```

可以看到请求头并没有传到后端应用，因为proxy_pass_request_headers off

修改 proxy.conf 配置文件，取下下面的注释

```nginx
proxy_set_body 'hello world';
proxy_set_header name '';
```

结果测试：

http_name 值为空

```shell
# curl -H 'name: suse' http://proxy.nginx.com/a/b/c
8012 server respose
uri:/a/b/c
method: POST
request: POST /a/b/c HTTP/1.1
http_name:
```

我们通过tcpdump 对端口数据进行监听, 发现包体 ‘hello world’ 已经传送过去

```shell
# tcpdump -i lo port 8012 -A -s 0
...
.d...d..POST /a/b/c HTTP/1.1
Host: proxyupstream
Content-Length: 11

hello world
...
```



## 接收用户请求包体

**指令**

```
Syntax: proxy_request_buffering on | off;
Default: proxy_request_buffering on; 
Context: http, server, location
```

**动作：**接收客户端请求的包体：收完再转发，还是边收边转发？

on 开启：

- 客户端网速较慢
- 上游服务并发处理能力低
- 适应高吞吐量场景

off 关闭：

- 更及时的响应
- 降低 Nginx 读写磁盘的消耗
- 一旦开始发送内容， proxy_next_upstream 功能失败



### 客户端包体的接收（？）

**存在包体时，接收包体所分配的内存：**

- 若接收头部时已经接收完全部包体，则不分配
- 若剩余待接收包体的长度小于 client_body_buffer_size, 则仅分配所需大小
- 分配 client_body_buffer_size 大小内存接收包体
  - 关闭包体缓存时，该内存上内容及时发送给上游
  - 打开包体缓存，该段大小内存用完时，写入临时文件，释放内存

**指令**

```
Syntax: client_body_buffer_size size;
Default: client_body_buffer_size 8k|16k; 
Context: http, server, location

Syntax: client_body_in_single_buffer on | off;
Default: client_body_in_single_buffer off; 
Context: http, server, location
```

### 最大包体长度限制

```
Syntax: client_max_body_size size;
Default: client_max_body_size 1m; 
Context: http, server, location
```

仅对请求头部中含有 Content-Length 有效超出最大长度后，返回413错误

### 临时文件路径格式

```
#设置存储用户请求体的文件的目录路径
Syntax: client_body_temp_path path [level1 [level2 [level3]]];
Default: client_body_temp_path client_body_temp; 
Context: http, server, location

#指定是否将用户请求体存储到一个文件里
Syntax: client_body_in_file_only on | clean | off;
Default: client_body_in_file_only off; 
Context: http, server, location
注意：
（1）该指令为on时，用户的请求体会被存储到一个文件中，但是请求结束后，该文件也不会被删除；
（2）该指令一般在调试的时候使用。
```

### 读取包体时的超时

```
#读取body的最大时延
Syntax: client_body_timeout time;
Default: client_body_timeout 60s; 
Context: http, server, location
```

注意：只有请求体需要被1次以上读取时，该超时时间才会被设置。且如果这个时间后用户什么都没发，nginx会返回requests time out 408.



## 与上游服务建立连接



### 向上游服务建立连接

**设立连接超时时间**

```
Syntax: proxy_connect_timeout time;
Default: proxy_connect_timeout 60s; 
Context: http, server, location
```

超时后，会向客户端生成http响应，响应码为502

```
Syntax: proxy_next_upstream http_502 | ..;
Default: proxy_next_upstream error timeout; 
Context: http, server, location
```

### 上游连接启用 TCP keepalive



<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-10 下午3.28.17.png" alt="截屏2021-03-10 下午3.28.17" style="zoom:50%;" />



**TCP keepalive工作原理**

​		nginx向上游发送数据，上游有收到数据，会返回给nginx应答，当一段时间内没有任何请求，nginx会向上游发送探测包，检查上游是否还在建立连接？如果上游响应探测包的应答，说明连接依然存活；否则，连接关闭。



**作用**：将tcp连接及时关闭，减少不必要的资源浪费。

**启用tcp 长连接**

```
Syntax: proxy_socket_keepalive on | off;
Default: proxy_socket_keepalive off; 
Context: http, server, location
```



### 上游连接启用 HTTP keepalive

**启用 http 长连接**

```
Syntax: keepalive connections;
Default: —
Context: upstream

Syntax: keepalive_requests number;
Default: keepalive_requests 100; 
Context: upstream
```



### 修改TCP 连接中的 local address

**指令**

```
Syntax: proxy_bind address [transparent] | off;
Default: —
Context: http, server, location
```

**address 地址：**

- 可以使用变量：proxy_bind $remote_addr;
- 可以使用不属于所在机器的IP地址：proxy_bind $remote_addr transparent;



### 当客户端关闭连接时

**忽略客户端终止**

```
客户端到nginx连接已经关闭，nginx到上游服务的连接是否要关闭，默认是不关闭的。
Syntax: proxy_ignore_client_abort on | off;
Default: proxy_ignore_client_abort off; 
Context: http, server, location
```

### 向上游发送HTTP 请求

转发超时时间

```
#nginx向上游发送http请求的超时时间
Syntax: proxy_send_timeout time;
Default: proxy_send_timeout 60s; 
Context: http, server, location
```



## 接收上游的响应

### 接收上游的 HTTP 响应头部

**设置代理缓存区大小**

nginx接收到上游http响应头，不超过默认缓存空间大小时，直接存入缓存；如果超过，将数据存入磁盘中。

```
Syntax: proxy_buffer_size size;
Default: proxy_buffer_size 4k|8k; 
Context: http, server, location
```

报错提示 error.log : upstream sent too big header



### 接收上游的 HTTP 包体

**设置缓存区大小和数量**

```
Syntax: proxy_buffers number size;
Default: proxy_buffers 8 4k|8k; 
Context: http, server, location
```

开启转发缓存

```
Syntax: proxy_buffering on | off;
Default: proxy_buffering on; 
Context: http, server, location
```

设置最大临时文件大小，如果超过这个值会报错

```
Syntax: proxy_max_temp_file_size size;
Default: proxy_max_temp_file_size 1024m; 
Context: http, server, location
```

设置最大写入临时文件的字节数。

```
Syntax: proxy_temp_file_write_size size;
Default: proxy_temp_file_write_size 8k|16k; 
Context: http, server, location
```

设置临时文件路径

```
Syntax: proxy_temp_path path [level1 [level2 [level3]]];
Default: proxy_temp_path proxy_temp; 
Context: http, server, location
```

### 及时转发包体

及时向客户端发送部分响应

```
Syntax: proxy_busy_buffers_size size;
Default: proxy_busy_buffers_size 8k|16k; 
Context: http, server, location
```

### 接收上游时网络速度指令

```
#读取上游数据超时时间
Syntax: proxy_read_timeout time;
Default: proxy_read_timeout 60s; 
Context: http, server, location

#读取上游数据限制的速率
Syntax: proxy_limit_rate rate;
Default: proxy_limit_rate 0; 
Context: http, server, location
```

### 上游包体的持久化

**存储文件用户权限**

```nginx
#指定创建文件和目录的相关权限，
Syntax: proxy_store_access users:permissions ...;
Default: proxy_store_access user:rw; 
Context: http, server, location

#这个指令设置哪些传来的文件将被存储，参数"on"保持文件与alias或root指令指定的目录一致，参数"off"将关闭存储，路径名中可以使用变量
Syntax: proxy_store on | off | string;
Default: proxy_store off; 
Context: http, server, location
```



### 配置实例

配置文件：proxy.conf

```nginx
upstream proxyups {
    server 127.0.0.1:8012 weight=1;
}

server {
    server_name storage.nginx.com;
    root /tmp;
    location / {
        proxy_pass http://proxyups;
        proxy_store on;
        proxy_store_access user:rw group:rw all:r;
    }
}
```

后端服务backed.conf

```nginx
server {
    listen 8012;
    root html;
    location / {
    }
}
```

**结果测试**

通过nginx访问文件，发现已经缓存到了文件

```nginx
# curl http://storage.nginx.com/a.txt
a.txt
# cat /tmp/a.txt 
a.txt
```



## 处理上游的响应头部

### 禁用上游响应头部

**指令**

```
Syntax: proxy_ignore_headers field ...;
Default: —
Context: http, server, location
```

**功能介绍：某些响应头部可以改变nginx的行为，使用proxy_ignore_headers可以禁用他们生效；**

**可以禁用的头部功能**

- X-Accel-Redirect：由上游服务器指定在nginx内部重定向，控制请求的执行
- X-Accel-Limit-Rate ： 由上游设置发往客户端的速度限制，等同limit_rate指令
- X-Accel-Buffering : 由上游控制是否缓存上游的响应
- X-Accel-Charset : 由上游控制Content-Type中的Charset
- 缓存相关：
  - X-Accel-Expires : 设置响应在nginx的缓存时间，单位秒；@开头表示一天某时刻
  - Expires：控制nginx缓存时间，优先级低于X-Accel-Expires
  - Cache-Control:控制nginx缓存时间，优先级低于X-Accel-Expires
  - Set-Cookie：响应中出现Set-Cookie则不缓存，可通过proxy_ignore_headers禁止生效
  - Vary：响应中出现Vary：*则不缓存，同样可以禁止生效

### 转发上游响应

**指令**

```
Syntax: proxy_hide_header field;
Default: —
Context: http, server, location
```

- proxy_hide_header 功能 : 对上游响应中的某些头部，设置不向客户端转发
- proxy_hide_header 功能默认不转发的响应包头:
  - Date ：由ngx_http_header_filter_module过滤模块填写，值为nginx发送响应头部时的时间
  - server：由ngx_http_header_filter_module过滤模块过滤模块填写，值为nginx版本
  - X-Pad：通常是Apache为避免浏览器BUG生成的头部，默认忽略
  - X-Accel-：用于控制nginx行为的响应，不需要向客户端转发
- proxy_pass_header : 对于已经被proxy-hide-header的头部，设置向客户端转发

**指令**

```
Syntax: proxy_pass_header field;
Default: —
Context: http, server, location
```

### 修改上游Set-Cookie头部

修改上游服务器的Set-Cookie指令；修改域名

```
Syntax: proxy_cookie_domain off;   
        proxy_cookie_domain domain replacement;
Default: proxy_cookie_domain off;
Context: http, server, location

Syntax: proxy_cookie_path off;
proxy_cookie_path path replacement;
Default: proxy_cookie_path off; 
Context: http, server, location
```

### 修改返回的Location头部

```
Syntax: proxy_redirect default;
        proxy_redirect off;
        proxy_redirect redirect replacement;
Default: proxy_redirect default; 
Context: http, server, location
```

### 配置示例

后端使用另一个nginxopenresty, 配置文件 backed.conf

```
server {
    listen 8012;
    default_type text/plain;
    root html;
    location /{
        add_header aaa 'aaaa value';   添加aaa字段
        # add_header X-Accel-Limit-Rate 10;
    }
}
```

前端使用nginx, 配置文件 proxy.conf

```
upstream proxyups{
    server 127.0.0.1:8012;
}
server {
    server_name t1.wang.com;
    root /tmp;
    
    location / {
        proxy_pass http://proxyups;
        
        #proxy_hide_header aaa;  #没有屏蔽头部aaa字端
        #proxy_pass_header server;
        #proxy_ignore_headers X-Accel-Limit-Rate;
        
        #proxy_pass_request_headers off;
        #proxy_pass_request_body off;
        #proxy_set_body 'hello world';
        #proxy_set_header name '';
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
```

**结果测试**

可以在结果里发现有 aaa的值

```
# curl http://t1.wang.com/a.txt -I
HTTP/1.1 200 OK
Server: nginx/1.14.0
Date: Sat, 05 Dec 2020 09:21:18 GMT
Content-Type: text/plain
Content-Length: 6
Connection: keep-alive
Last-Modified: Sat, 05 Dec 2020 09:21:16 GMT
ETag: "5fcb510c-6"
aaa: aaaa value
Accept-Ranges: bytes
```

修改配置文件proxy.conf ,取消注释

```
proxy_hide_header aaa;  #没有屏蔽头部aaa字端
proxy_pass_header server;
```

**结果测试**

隐藏了后端的包头，返回了后端服务器的版本号

```
# curl http://t1.wang.com/a.txt -I
HTTP/1.1 200 OK
Date: Sat, 05 Dec 2020 09:23:25 GMT
Content-Type: text/plain
Content-Length: 6
Connection: keep-alive
Server: openresty/1.13.6.2
Last-Modified: Sat, 05 Dec 2020 09:21:16 GMT
ETag: "5fcb510c-6"
Accept-Ranges: bytes
```

后端服务器openresty, 修改配置文件 backed.conf，添加参数注释

```
add_header X-Accel-Limit-Rate 10;
```

结果测试

我们发现访问后端服务时很慢

```
# time curl http://t1.wang.com/hello.mp4 -I
HTTP/1.1 200 OK
Date: Sat, 05 Dec 2020 09:27:57 GMT
```

前端服务器nginx，修改配置文件，添加限速忽略

```
proxy_ignore_headers X-Accel-Limit-Rate;
```

**结果测试**

我们发现限速取消

```
# time curl http://t1.wang.com/hello.mp4 -I
HTTP/1.1 200 OK
...

real    0m0.009s
user    0m0.000s
sys     0m0.005s
```



## 上游出现失败时的方案

### 上游返回失败时的处理方法

指令

```
Syntax: proxy_next_upstream error | timeout | invalid_header 
        | http_500 | http_502 | http_503 | http_504 | http_403 
        | http_404 | http_429 | non_idempotent | off ...;
Default: proxy_next_upstream error timeout; 
Context: http, server, location
```

前提：没有向客户端发送任何内容

配置：

- error：在与服务器建立连接，向其传递请求或读取响应标头时发生错误;
- timeout：在与服务器建立连接，向其传递请求或读取响应头时发生超时;
- invalid_header：服务器返回空响应或无效响应;
- http_：服务器返回了带有代码的响应;
- non_idempotent：通常，如果请求已经被发送到上游服务器（1.9.13），则具有非幂等方法的请求（POST，LOCK，PATCH）不被传递到下一个服务器;启用此选项明确允许重试此类请求;
- off：禁用将请求传递到下一个服务器。

### 限制proxy_next_upstream时间和次数

指令

```
#限制请求可以传递到下一个服务器的时间。 0值关闭此限制。
Syntax: proxy_next_upstream_timeout time;
Default: proxy_next_upstream_timeout 0; 
Context: http, server, location

#限制将请求传递到下一个服务器的可能尝试次数。 0值关闭此限制
Syntax: proxy_next_upstream_tries number;
Default: proxy_next_upstream_tries 0; 
Context: http, server, location
```

### 配置示例

后端服务backend.conf

```nginx
server {
    listen 8011;
    default_type test/plain;
    return 200 '8011 server response.\n';
}
server {
    listen 8012;
    default_type test/plain;
    return 500 '8012 server Internal Error.\n';
}
```

转发服务proxy.conf

```nginx
upstream nextups {
    server 127.0.0.1:8011;
    server 127.0.0.1:8012;
}

server {
    server_name upstream.nginx.com;
    location / {
        proxy_pass http://nextups;
    }
    location /error {
        proxy_pass http://nextups;
        proxy_connect_timeout 1s;
        proxy_next_upstream off;
    }
    location /httperror {
        proxy_pass http://nextups;
        proxy_next_upstream http_500;
    }
}
```

**结果测试**

不断访问http://t1.wang.com/，我们会看到结果会依次返回

```
# curl http://upstream.nginx.com
8011 server response.
# curl http://upstream.nginx.com
8012 server Internal Error.
```

修改配置文件，将backend.conf 的 8012 端口改为8013，多次访问http://upstream.nginx.com;

我们发现，每次都是返回8011，并没有给我们返回错误

```
# curl http://upstream.nginx.com
8011 server response.
```

我们多次访问 http://upstream.nginx.com/error 进行结果对比，发现返回结果一次是8011，一次是服务器内部错误502

```shell
# curl http://upstream.nginx.com/error
8011 server response.
# curl http://upstream.nginx.com/error
<html>
<head><title>502 Bad Gateway</title></head>
<body bgcolor="white">
<center><h1>502 Bad Gateway</h1></center>
<hr><center>nginx/1.14.0</center>
</body>
</html>
```

修改proxy.conf 配置文件,如下:

```nginx
    ...
    location /error {
        proxy_pass http://nextups;
        proxy_connect_timeout 1s;
        proxy_next_upstream error;
    }
    ...
```

多次访问 http://upstream.nginx.com/error 进行结果对比，发现结果请求结果都返回8011

```shell
# curl http://upstream.nginx.com/error
8011 server response.
# curl http://upstream.nginx.com/error
8011 server response.
```

修改配置文件，将backend.conf 的 8013 端口改为8012，多次访问 http://upstream.nginx.com/httperr 进行结果对比，发现每次访问结果都一样，因为后端服务8012返回的错误码是500，nginx反向代理服务器收到500的错误码，会选择一个新的upstream，返回给客户端。

```shell
# curl http://upstream.nginx.com/httperr
8011 server response.
```



### error_page拦截上游失败响应

**功能：**

​		当上游响应的响应码大于等于300时，应将响应返回客户端还是按 errror_page 指令处理

**指令**

```nginx
Syntax: proxy_intercept_errors on | off;
Default: proxy_intercept_errors off; 
Context: http, server, location
```

### 配置示例

后端配置文件

```nginx
server {
    listen 8014;
    default_type test/plain;
    return 500 '8014 server Internal Error.\n';
}
```

在刚刚的配置文件 proxy.conf 中添加一行配置

```nginx
# error_page 500 /test1.txt;
location /intercept {
    # proxy_intercept_errors on;
    proxy_pass http://127.0.0.1:8014;
}
location /test {
    root html;
}
```

访问 http://intercept.nginx.com/intercept,我们看到返回结果为500

```nginx
# curl http://intercept.nginx.com/intercept -I
HTTP/1.1 500 Internal Server Error
```

将 proxy.conf 配置中的注释取消,如下所示

```
error_page 500 /test1.txt;
location /intercept {
    proxy_intercept_errors on;
    proxy_pass http://127.0.0.1:8014;
}
```

访问 http://intercept.nginx.com/test1.txt ，测试可以拿到test1.txt的结果

再访问http://intercept.nginx.com/intercept ，可以看到错误被重定到了/test1.txt

```nginx
# curl http://intercept.nginx.com/test1.txt
test1
# curl http://intercept.nginx.com/intercept 
test1
```



## 对上游使用SSL连接

### 双向认证

**双向认证示意图:**

![截屏2021-03-12 上午11.22.21](/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-12 上午11.22.21.png)



#### 下游使用证书

**指令**

```
Syntax: ssl_certificate file;
Default: —
Context: http, server

Syntax: ssl_certificate_key file;
Default: —
Context: http, server
```



#### 验证下游证书

**指令**

```
Syntax: ssl_verify_client on | off | optional | optional_no_ca;
Default: ssl_verify_client off; 
Context: http, server

Syntax: ssl_client_certificate file;
Default: —
Context: http, server
```



#### 上游使用证书

**指令**

```
Syntax: proxy_ssl_certificate file;
Default: —
Context: http, server, location

Syntax: proxy_ssl_certificate_key file;
Default: —
Context: http, server, location
```



#### 验证上游证书

```
Syntax: proxy_ssl_trusted_certificate file;
Default: —
Context: http, server, location

Syntax: proxy_ssl_verify on | off;
Default: proxy_ssl_verify off; 
Context: http, server, location
```



### ssl 模块提供的变量

**安全套件**

- ssl_cipher:本次通讯选用的安全套件，例如ECDHE-RSA-AES128-GCM-SHA256
- ssl_ciphers:客户端支持的所有安全套件
- ssl_protocol:本次通信选用TLS版本，例如TLS1.2
- ssl_curves : 客户端支持的椭圆曲线，例如secp384rl:secp521r1

**证书**

- ssl_client_raw_cert：原始客户端证书内容
- ssl_client_escaped_cert:返回客户端证书做urlencode 编码后的内容
- ssl_client_cert : 对客户端证书每一行内容前加tab制表符，增强可读性
- ssl_client_fingerprint:客户端证书的SHA1指纹

**证书结构化信息**

- ssl_server_name: 通过TLS插件SNI获取到的服务域名
- ssl_client_i_dn:依据RFC2253获取到证书issuer dn信息，例如：CN=…,O=….,L=….,C=….
- ssl_client_i_dn_legacy: 依据RFC2253获取到证书issuer dn信息例如：/C=…/L=…/O=…/CN=…
- ssl_client_s_dn: 依据RFC2253获取到证书issuer dn信息例如：CN=…,OU=…,O=…,L=…,ST=…,C=…
- ssl_client_s_dn_legacy:同样获取issuer dn信息，格式为：/C=…/ST=…/L=…/O=…/OU=…/CN=…

**证书有效期**

- ssl_client_v_end: 返回客户端证书的过期时间；例如Dec 1 11:56:11 2028 GMT
- ssl_client_v_remain: 返回还有多少天客户端证书过期，例如针对上面的ssl_client_v_end其值为3649
- ssl_client_v_start : 客户端证书颁发日期；例如 Dec 4 11:56:11 2018 GMT

**连接有效性**

- ssl_client_serial:返回连接客户端证书的序列号，例如8BE947674841BD44
- ssl_early_data: 在TLS1.3协议中使用了early data且握手未返回1，则返回空字符串
- ssl_client_verify:如果验证失败为FAILED：原因，如果没有验证证书则为NONE，验证成功则为SUCCESS
- ssl_session_id:已建立连接的sessionid
- ssl_session_reused:如果session被复用（参考session）则为r,否则为.（点）

### 创建证书示例

#### **创建根证书**

 **创键CA私钥**

```
openssl genrsa -out ca.key 2048
```

 **制作CA公钥**

```
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt
```

#### **签发证书**

 **创建私钥**

```
openssl genrsa -out a.pem 1024
openssl rsa -in a.pem -out a.key
```

 **生成签发证书请求**

```
openssl req -new -key a.pem -out a.csr
```

 **使CA证书进行签发**

```
openssl x509 -req -sha256 -in a.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 3650 -out a.crt
```

 **验证签发证书是否正确**

```
openssl verify -CAfile ca.crt a.crt
```

### 配置示例

首先创建根证书

```
openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt
```

签发服务器证书a

```
openssl genrsa -out a.pem 1024
openssl rsa -in a.pem -out a.key
openssl req -new -key a.pem -out a.csr
openssl x509 -req -sha256 -in a.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 3650 -out a.crt
openssl verify -CAfile ca.crt a.crt
```

签发客户端证书b

```
openssl genrsa -out b.pem 1024
openssl rsa -in b.pem -out b.key
openssl req -new -key b.pem -out b.csr
openssl x509 -req -sha256 -in b.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 3650 -out b.crt
openssl verify -CAfile ca.crt b.crt
```

上游配置文件 backend.conf

```nginx
server {
    listen 443 ssl;
    server_name ssl.nginx.com;
    ssl_certificate cert/webapp.crt;
    ssl_certificate_key cert/webapp.key;

    ssl_verify_client optional;
    ssl_verify_depth 2;
    ssl_client_certificate cert/ca.crt;

    location /test {
        return 200 'hello world\n';
    }
}
```

代理端配置文件 proxy.conf

```nginx
server {
    listen 8090;
    location /test {
        proxy_pass https://ssl.nginx.com;
        proxy_ssl_name webapp;
        proxy_ssl_verify_depth 4;
        
        proxy_ssl_certificate cert/opennginx.crt;
        proxy_ssl_certificate_key cert/opennginx.key;
        proxy_ssl_server_name on;
    }
}
```

结果测试

```nginx
# curl http://ssl.nginx.com:8090/test
hello world
```

注意⚠️错误提示：error 18 at 0 depth lookup:self signed certificate

解释：生成CA根证书，根据提示填写各个字段, 但注意 Common Name 最好是有效根域名(如 zeali.net ), 并且不能和后来服务器证书签署请求文件中填写的 Common Name 完全一样，否则会导致证书生成的时候出现。





## 浏览器缓存

### 浏览器缓存与nginx缓存

**浏览器缓存**

- 优点
  - 使用有效缓存时，没有网络消耗，速度最快
  - 即使有网络消耗，但对失效缓存使用 304 响应做到网络流量消耗最小化
- 缺点
  - 仅提升一个用户的体验

**nginx缓存**

- 优点
  - 提升所有用户的体验
  - 相比浏览器缓存，有效降低上游服务的负载
  - 通过 304 响应减少nginx 与上游服务器间的流量消耗
- 缺点
  - 用户仍然保持网络消耗

**同时使用浏览器和nginx 缓存**

### Etag 头部

ETag HTTP 响应头是资源的特定版本的标识符。可以是缓存更高效，并节省带宽，因为如果内容没有改变。web服务不需要发送完整的响应。如果内容发生变化，使用ETag有助于防止资源的同时更新互换覆盖(“空中碰撞”)；

如果给定URL中的资源更改,则一定要生成新的Etag值。因此Etge类似于指纹，也可能被某些服务器用于追踪。比较etags能快速确定此资源是否变化，但也可能被追踪服务器永久保存

**W/可选**

‘W/‘（大小写敏感）表示使用弱验证器，弱验证器很容易生成不利于比较，强验证器是比较的理想选择，但很难生成，相同资源的两个弱Etag值可能语义相同，但不是每个字节都相同

### etag指令

```
Syntax: etag on | off;
Default: etag on; 
Context: http, server, location
```

**生成规则：**利用最后修改时间和内容长度生成随机数，极难会重复

### If-None-Match

**`If-None-Match`** 是一个条件式请求首部。对于 GET 和 HEAD 请求方法来说，当且仅当服务器上没有任何资源的 ETag 属性值与这个首部中列出的相匹配的时候，服务器端会才返回所请求的资源，响应码为 200 。对于其他方法来说，当且仅当最终确认没有已存在的资源的 ETag 属性值与这个首部中所列出的相匹配的时候，才会对请求进行相应的处理。

对于 GET 和 HEAD 方法来说，当验证失败的时候，服务器端必须返回响应码 304 （Not Modified，未改变）。对于能够引发服务器状态改变的方法，则返回 412 （Precondition Failed，前置条件失败）。需要注意的是，服务器端在生成状态码为 304 的响应的时候，必须同时生成以下会存在于对应的 200 响应中的首部：Cache-Control、Content-Location、Date、ETag、Expires 和 Vary 。

ETag 属性之间的比较采用的是**弱比较算法**，即两个文件除了每个比特都相同外，内容一致也可以认为是相同的。例如，如果两个页面仅仅在页脚的生成时间有所不同，就可以认为二者是相同的。

当与 `If-Modified-Since` 一同使用的时候，If-None-Match 优先级更高（假如服务器支持的话）。

以下是两个常见的应用场景：

- 采用 GET 或 HEAD 方法，来更新拥有特定的 ETag 属性值的缓存。
- 采用其他方法，尤其是 PUT，将 `If-None-Match` used 的值设置为 * ，用来生成事先并不知道是否存在的文件，可以确保先前并没有进行过类似的上传操作，防止之前操作数据的丢失。这个问题属于更新丢失问题的一种。

注释：信息来自官网[If-None_Match](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/If-None-Match)

### If-Modefied-Since头部

**`If-Modified-Since`** 是一个条件式请求首部，服务器只在所请求的资源在给定的日期时间之后对内容进行过修改的情况下才会将资源返回，状态码为 `200` 。如果请求的资源从那时起未经修改，那么返回一个不带有消息主体的 `304` 响应，而在 `Last-Modified`首部中会带有上次修改时间。 不同于 `If-Unmodified-Since`

当与 `If-None-Match`一同出现时，它（**`If-Modified-Since`**）会被忽略掉，除非服务器不支持 `If-None-Match`。

注释：信息来自官网[If-Modefied-Since](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/If-Modified-Since)



## Nginx决策浏览器过期缓存是否有效

### not_modified 过滤模块

**功能**：客户端拥有缓存，但是不确认缓存是否过期，于是在请求中传入 If-Modified-Since 或者 If-None-Math 头部，该模块通过将其值与响应中的 Last-Modified 值相比较，决定是通过 200 返回全部内容，还是仅返回 304 Not Modified 头部，表示浏览器仍使用之前的缓存

**使用前提**：原返回响应码为200

### expires 指令

```nginx
Syntax: expires [modified] time;
        expires epoch | max | off;
Default: expires off; 
Context: http, server, location, if in location
```

**参数解释**

- max:
  - Expires: Thu, 31 Dec 2037 23:55:55 GMT
  - Cache-Control: max-age=31536000010(10年)
- off : 不添加或者修改Expires 和 Cache-Control 字段
- epoch:
  - Expires: Thu, 01 Jan 1970 00:00:01 GMT
  - Cache-Control: no-cache
- time : 设计具体的时间，可以携带单位
  - 一天内的具体时刻可以加@，比如下午六点半：@18h30m
    - 设定好Expires, 自动计算 Cache-Control
    - 如果当前时间未超过当天的time 时间，则Expires到当天time, 否则就是第二天的 time 时刻
  - 正数：设定Cache-Control 时间，计算出 Expires
  - 负数：Cache-Control:no-cache ，计算出 Expires

### 案例演示

配置文件 proxy.conf

```nginx
location / {
    expires 1h;
}
```

结果测试

```nginx
# curl http://t1.wang.com:8090/ -I
ETag: "5fc0f2b6-264"
Expires: Sun, 06 Dec 2020 04:56:34 GMT
Cache-Control: max-age=3600
```

修改配置文件 proxy.conf

```nginx
location / {
    expires -1h;
}
```

结果测试

```nginx
# curl http://t1.wang.com:8090/ -I
ETag: "5fc0f2b6-264"
Expires: Sun, 06 Dec 2020 02:57:43 GMT
Cache-Control: no-cache
```

修改配置文件 proxy.conf

```nginx
location / {
    expires @20h30m;
}
```

结果测试

```nginx
# curl http://t1.wang.com:8090/ -I
ETag: "5fc0f2b6-264"
Expires: Sun, 06 Dec 2020 12:30:00 GMT
Cache-Control: max-age=30676
```



### not_modified 过滤模块

```nginx
Syntax: if_modified_since off | exact | before;
Default: if_modified_since exact; 
Context: http, server, location
```

参数：

- off : 忽略请求中的 if_modified_since 头部
- exact : 精确匹配 if_modified_since 头部与 last_modified 的值
- before : 若 if_modified_since 大于等于 last_modified 的值，则返回304

### If-Match

请求首部 **`If-Match`** 的使用表示这是一个条件请求。在请求方法为 GET 和 HEAD 的情况下，服务器仅在请求的资源满足此首部列出的 `ETag`值时才会返回资源。而对于 `PUT`或其他非安全方法来说，只有在满足条件的情况下才可以将资源上传。

`ETag` 之间的比较使用的是**强比较算法**，即只有在每一个字节都相同的情况下，才可以认为两个文件是相同的。在 ETag 前面添加 `W/` 前缀表示可以采用相对宽松的算法。

以下是两个常见的应用场景：

- 对于GET 和 HEAD 方法，搭配 `Range`首部使用，可以用来保证新请求的范围与之前请求的范围是对同一份资源的请求。如果 ETag 无法匹配，那么需要返回416 (Range Not Satisfiable，范围请求无法满足) 响应。
- 对于其他方法来说，尤其是 `PUT`, `If-Match` 首部可以用来避免更新丢失问题。它可以用来检测用户想要上传的不会覆盖获取原始资源之后做出的更新。如果请求的条件不满足，那么需要返回 412 (Precondition Failed，先决条件失败) 响应。

注释：内容来自官网 [If-Match](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/If-Match)

### If-Unmodified-Since

HTTP协议中的 **`If-Unmodified-Since`** 消息头用于请求之中，使得当前请求成为条件式请求：只有当资源在指定的时间之后没有进行过修改的情况下，服务器才会返回请求的资源，或是接受 `POST`或其他 non-safe 方法的请求。如果所请求的资源在指定的时间之后发生了修改，那么会返回 412 (Precondition Failed) 错误。

常见的应用场景有两种：

- 与 non-safe 方法如 POST 搭配使用，可以用来优化并发控制，例如在某些wiki应用中的做法：假如在原始副本获取之后，服务器上所存储的文档已经被修改，那么对其作出的编辑会被拒绝提交。
- 与含有 `If-Range`]消息头的范围请求搭配使用，用来确保新的请求片段来自于未经修改的文档。

注释：内容来自官网 [If-Unmodified-Since](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/If-Unmodified-Since)



### 案例演示

对访问连接进行测试，发现如果 If_Modified_Since 为最后一次修改时间，If-None-Match为 ETag 则返回304，否则返回200。

```nginx
# curl http://t1.wang.com:8090/a.txt -I
HTTP/1.1 200 OK
Server: nginx/1.14.0
Date: Sun, 06 Dec 2020 05:58:44 GMT
Content-Type: text/plain
Content-Length: 6
Last-Modified: Wed, 02 Dec 2020 11:59:45 GMT
Connection: keep-alive
ETag: "5fc781b1-6"
Expires: Sun, 06 Dec 2020 12:30:00 GMT
Cache-Control: max-age=23476
Accept-Ranges: bytes

# curl -H 'If_Modified_Since: Wed, 02 Dec 2020 11:59:45 GMT' -H 'If-None-Match: "5fc781b1-6"' http://t1.wang.com:8090/a.txt -I  
HTTP/1.1 304 Not Modified
# curl -H 'If_Modified_Since: Wed, 02 Dec 2020 11:59:45 GMT' -H 'If-None-Match: "5fc781b1-7"' http://t1.wang.com:8090/a.txt -I   
HTTP/1.1 200 OK
```

如果返回304，则只有包头，而没有包体，而如果是200，则会返回内容

```nginx
# curl -H 'If_Modified_Since: Wed, 02 Dec 2020 11:59:45 GMT' -H 'If-None-Match: "5fc781b1-6"' http://t1.wang.com:8090/a.txt 
# curl -H 'If_Modified_Since: Wed, 02 Dec 2020 11:59:45 GMT' -H 'If-None-Match: "5fc781b1-7"' http://t1.wang.com:8090/a.txt
a.txt
```



## 缓存基本用法

### nginx缓存：定义存放缓存的载体

```
Syntax: proxy_cache zone | off;
Default: proxy_cache off; 
Context: http, server, location
```



```
Syntax: proxy_cache_path path [levels=levels] [use_temp_path=on|off] 
        keys_zone=name:size [inactive=time] [max_size=size] [manager_files=number] 
        [manager_sleep=time] [manager_threshold=time] [loader_files=number] 
        [loader_sleep=time] [loader_threshold=time] [purger=on|off] [purger_files=number] 
        [purger_sleep=time] [purger_threshold=time];
Default: —
Context: http
```

### proxy_cache_path指令

- path : 定义缓存文件存放位置
- levels : 定义缓存路径的目录层级，最多3级，每层目录长度为1或者2字节
- user_temp_path
  - on : 使用proxy_temp_path 定义的临时目录
  - off : 直接使用 path 路径存放临时文件
- keys_zone
  - name : 共享内存名字，由 proxy_cache 指令使用
  - size : 共享内存大小，1MB 大约可以存放 8000 个key
- inactive : 在 inactive 时间内没有被访问的缓存，会被淘汰掉；默认10分钟
- max_size : 设置最大的缓存文件大小，超出后由 cache manager 进程按 LRU 链表淘汰

### proxy_cache_path指令

Nginx针对响应缓存有两个处理动作

- 缓存管理器会定时检查缓存的状态。如果缓存的内容大小达到了指令`proxy_cache_path`的参数`max-size`指定的值,则缓存管理器会根据LRU算法删除缓存的内容。 在检查的间隔时间内，总的缓存内容大小可以临时超过设定的大小阈值。

- 缓存加载器只在Nginx启动的时候执行一次，将缓存内容的原信息加载到指定的共享内存区内。一次将所有的缓存内容加载到内存中会耗费大量的资源，并且会影响Nginx启动后几分钟内的性能。为了避免这种问题可以通过在指令`proxy_cache_path`

  后添加下面的参数：

  - loader_threshold – 缓存加载器加载缓存内容的最大执行时间（单位是毫秒，默认值是200毫秒）。
  - loader_files – 在缓存加载器加载缓存内容至共享内存，最多能加载多少个缓存条目，默认100。
  - loader_sleeps – 每两次执行的时间间隔, 单位是毫秒 (默认50毫秒)

- manager_file : cache manager 进程在1次淘汰过程中，淘汰的最大文件数；默认100
- manager_sleep : 执行一次淘汰循环后，cache manager 进程的休眠时间；默认200毫秒
- manager_threshold: 执行一次淘汰循环的最大耗时；默认50毫秒
- loader_file : cache loader 进程载入磁盘中缓存文件，每批最多处理的文件数；默认100
- loader_sleep : 执行一次缓存文件至共享内存后，进程休眠的时间；载入默认200毫秒
- loader_threshold : 每次载入缓存文件至共性内存的最大耗时；默认50毫秒

### 缓存关键字

```
Syntax: proxy_cache_key string;
Default: proxy_cache_key $scheme$proxy_host$request_uri; 
Context: http, server, location
```

### 缓存的内容

```
Syntax: proxy_cache_valid [code ...] time;
Default: —
Context: http, server, location
```

1. 对不同的响应码缓存不等的时长；例如: 404 5m;
2. 只标识时间；仅对以下响应码缓存：200、301、302
3. 通过响应头部控制缓存时长
   - X-Accel-Expires, 单位秒；为0时表示禁止 nginx 缓存内容；通过@设置缓存到一天中的某一刻
   - 响应头若含有 Set-Cookie 则不缓存
   - 响应头含有 Vary: * 则不缓存

### 哪些内容不使用缓存

`proxy_no_cache`指定哪些请求不需要Nginx来缓存，参数为真时，后端响应不存入本地缓存。

```
Syntax: proxy_no_cache string ...;
Default: —
Context: http, server, location
```

参数为真时，客户端不会从缓存中获取响应，Nginx会把请求转发到后端的服务而不会使用缓存。

```
Syntax: proxy_cache_bypass string ...;
Default: —
Context: http, server, location
```



### 变更 HEAD 方法

**指令**

```
Syntax: proxy_cache_convert_head on | off;
Default: proxy_cache_convert_head on; 
Context: http, server, location
```

### upstream_cache_status 变量

**upstream_cache_status参数**

- MISS : 未命中缓存
- HIT : 命中缓存
- EXPIRED : 缓存已经过期
- STALE : 命中了陈旧的缓存
- UPDATING ： 内容陈旧，但正在更新
- REVALIDATED ：nginx 验证了陈旧的内容依然有效
- BYPASS : 响应是从原始服务器获得的

### 配置示例

上游服务 backend.conf

```nginx
server {
    listen 8012;
    # add_header Cache-Control 'max-age=3,stale-while-revalidate=3';
    # add_header Vary *;
    # add_header X-Accel-Expires 3;
    location / {
    }
}
```

配置文件 cache.conf

```nginx
proxy_cache_path /data/nginx/tmpcache levels=2:2 keys_zone=two:10m
        loader_threshold=300 loader_files=200 max_size=200m inactive=1m;

server {
    server_name ngcache.nginx.com;
    location / {
        proxy_pass http://localhost:8012;   
        
        proxy_cache two;
        proxy_cache_valid 200 1m;
        proxy_cache_key $scheme$uri; 
        add_header X-Cache-Status $upstream_cache_status;
    }
}
```

结果测试

```nginx
# curl http://ngcache.nginx.com/a.txt -I
X-Cache-Status: MISS
# curl http://ngcache.nginx.com/a.txt -I
X-Cache-Status: HIT
```

修改backed.conf ，取消注释，改动如下

```nginx
# add_header Cache-Control 'max-age=3,stale-while-revalidate=3';
# add_header Vary *;
add_header X-Accel-Expires 3;
```

结果测试

```nginx
# curl http://ngcache.nginx.com/a.txt -I
X-Cache-Status: MISS

# 三秒钟后
# curl http://ngcache.nginx.com/a.txt -I
X-Cache-Status: EXPIRED
```

修改backed.conf ，取消注释，改动如下: 表示不缓存对上游的添加的头部

```nginx
# add_header Cache-Control 'max-age=3,stale-while-revalidate=3';
add_header Vary *;
#add_header X-Accel-Expires 3;
```

**结果测试**

每次返回X-Cache-Status都是 MISS，数据没有缓存

```nginx
# curl http://ngcache.nginx.com/a.txt -I
X-Cache-Status: MISS
```

修改backed.conf ，取消注释，改动如下

```nginx
add_header Cache-Control 'max-age=3,stale-while-revalidate=3';
add_header Vary *;
# add_header X-Accel-Expires 3;
```

多访问几次http://ngcache.nginx.com/a.txt，发现内容没有被缓存

```nginx
# curl http://ngcache.nginx.com/a.txt -I
X-Cache-Status: MISS
```



## 对客户端请求的缓存处理流程

### 缓存流程

[![image-20201206152030456](https://wangzhangtao.com/img/body/temp/image-20201206152030456.png)](https://wangzhangtao.com/img/body/temp/image-20201206152030456.png)





### 对哪些方法使用缓存返回响应

```
Syntax: proxy_cache_methods GET | HEAD | POST ...;
Default: proxy_cache_methods GET HEAD; 
Context: http, server, location
```



## 接收上游响应的缓存处理流程

### X-Accel-Expires 头部

**X-Accel-Expires**

```
Syntax: X-Accel-Expires [offseconds]
Default: X-Accel-Expires off
```

从上游服务定义缓存多长时间

- 0 表示不缓存当前响应
- @前缀表示缓存到当天的某个时间

### Vary头部

Vary 是一个HTTP响应头部信息，它决定了对于未来的一个请求头，应该用一个缓存的回复(response)还是向源服务器请求一个新的回复。它被服务器用来表明在 content negotiation algorithm（内容协商算法）中选择一个资源代表的时候应该使用哪些头部信息（headers）。

在响应状态码为304 Not Modified 的响应中，也要设置 Vary 首部，而且要与响应的 200 OK 设置的一模一样。

- Vary:*
  - 所有的请求都被视为唯一并且非缓存的，使用 Cache-Control: private, 来实现则更合适，这样用于说明不存储该对象更加清晰
  - 若没有通过 proxy_ingore_headers 设置忽略，则不缓存响应
- Vary: <header-name>, <header-name>，…
  - 逗号分隔的一系列 http 头部名称，用于确定缓存是否可用

### Set-Cookie 头部

若 Set-Cookie 头部没有被 proxy_ingnore_headers 设置忽略，则不对响应进行缓存

```
Set-Cookie: <cookie-name>=<cookie-value> 
Set-Cookie: <cookie-name>=<cookie-value>; Expires=<date> 
Set-Cookie: <cookie-name>=<cookie-value>; Max-Age=<non-zero-digit> 
Set-Cookie: <cookie-name>=<cookie-value>; Domain=<domain-value> 
Set-Cookie: <cookie-name>=<cookie-value>; Path=<path-value> 
Set-Cookie: <cookie-name>=<cookie-value>; Secure 
Set-Cookie: <cookie-name>=<cookie-value>; HttpOnly 
Set-Cookie: <cookie-name>=<cookie-value>; SameSite=Strict 
Set-Cookie: <cookie-name>=<cookie-value>; SameSite=Lax 
Set-Cookie: <cookie-name>=<cookie-value>; Domain=<domain-value>; Secure; HttpOnly
```

[![image-20201206153733692](https://wangzhangtao.com/img/body/temp/image-20201206153733692.png)](https://wangzhangtao.com/img/body/temp/image-20201206153733692.png)

image-20201206153733692





## 如何减轻缓存失效时上游服务的压力

- 合并回源请求-减轻峰值流量下的压力
- 减少回源请求-使用 stale 陈旧的缓存

### 合并回源请求-减轻峰值流量下的压力

如下图所示:

<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-13 上午10.56.41.png" alt="截屏2021-03-13 上午10.56.41" style="zoom:50%;" />



```
Syntax: proxy_cache_lock on | off;
Default: proxy_cache_lock off; 
Context: http, server, location
```

同一时间，仅第一个请求发向上游，其他请求等待第一个响应返回或者超时后，使用缓存响应客户端

```
Syntax: proxy_cache_lock_timeout time;
Default: proxy_cache_lock_timeout 5s; 
Context: http, server, location
```

其它客户端等待第一个请求返回响应的最大时间，到达后直接向上游发送请求，但不缓存响应

```
Syntax: proxy_cache_lock_age time;
Default: proxy_cache_lock_age 5s; 
Context: http, server, location
```

上一个请求返回响应的超时时间，到达后再放行一个请求发向上游，一个一个依次放行



### 减少回源请求-使用 stale 陈旧的缓存

**工作原理如下图:**

<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-13 上午11.00.47.png" alt="截屏2021-03-13 上午11.00.47" style="zoom:50%;" />



```
Syntax: proxy_cache_use_stale error | timeout | invalid_header | 
        updating | http_500 | http_502 | http_503 | http_504 | 
        http_403 | http_404 | http_429 | off ...;
Default: proxy_cache_use_stale off; 
Context: http, server, location
```

第一个请求发往客户端，其他的请求则返回旧缓存内容

```
Syntax: proxy_cache_background_update on | off;
Default: proxy_cache_background_update off; 
Context: http, server, location
```

允许在后台发送子请求来上游更新过期的缓存文件，代理服务器依然使用旧缓存返回给客户端



### 定义陈旧缓存的用法：proxy_cache_use_stale

**updating**

- 当缓存内容过期，有一个请求正在访问上游试图更新缓存时，其他请求直接使用过期内容返回客户端
- stale-while-revalidate
  - 缓存内容过期后，定义一段时间，在这段时间内 updating 设置有效，否则请求仍然访问上游服务
  - 例如：Cache-Control: max-age=600, stale-while-revalidate=30
- stale-if-error
  - 缓存内容过期后，定义一段时间，在这段时间内上游服务出错后就继续使用缓存，否则请求仍然访问上游服务。stale-while-revalidate 包括 stale-if-error 场景
  - 例如：Cache-Control: max-age=600, stale-if-error=1200

**error**：当于上游建立连接、发送请求、读取响应头部等情况出错时，使用缓存

**timeout** : 当于上游建立连接、发送请求、读取响应头部等情况戳线定时器超时，使用缓存

**http_**(500|502|503|504|403|404|429) : 缓存以上错误响应码的内容



### 缓存有问题的响应

```
Syntax: proxy_cache_background_update on | off;
Default: proxy_cache_background_update off; 
Context: http, server, location
```

当使用 proxy_cache_use_stale 允许使用过期响应时，将同步生成一个子请求，通过访问上游服务更新过期的缓存

```
Syntax: proxy_cache_revalidate on | off;
Default: proxy_cache_revalidate off; 
Context: http, server, location
```

更新缓存时，使用 If-Modified-Since 和 If-None-Match 作为请求头部，预期内容未发生变更时，通过304来减少传输的内容



<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-13 上午11.20.05.png" alt="截屏2021-03-13 上午11.20.05" style="zoom: 33%;" />



## 及时清除缓存

### 及时清除缓存

**功能**：接收到指定 HTTP 请求后立刻清除缓存

**模块**

- 第三方模块 ngx_cache_purge : https://github.com/FRiCKLE/ngx_cache_purge
- 使用 --add-module=指令添加模块到 nginx 中

**指令**

```
syntax: proxy_cache_purge on|off|<method> [from all|<ip> [.. <ip>]] 
default: none 
context: http, server, location

syntax: proxy_cache_purge zone_name key 
default: none 
context: location
```



### 案例模拟

重新制作nginx

```
# git clone https://github.com/FRiCKLE/ngx_cache_purge
# ./configure --prefix=/home/jeek/nginx --with-http_ssl_module --with-http_realip_module --add-module=./ngx_cache_purge && make
# cp objs/nginx /home/jeek/nginx/sbin/nginx
```

上游配置文件backend.conf

```
server {
    listen 8012;
    location / {
    }
}
```

配置文件cache.conf

```
proxy_cache_path /data/nginx/tmpcache levels=2:2 keys_zone=two:10m
        loader_threshold=300 loader_files=200 max_size=200m inactive=1m;

server {
    server_name t1.wang.com;
    location / {
        proxy_pass http://localhost:8012;   
        
        proxy_cache two;
        proxy_cache_valid 200 1m;
        proxy_cache_key $scheme$uri; 
        add_header X-Cache-Status $upstream_cache_status;
    }
    location ~ /purge(/.*) {
        proxy_cache_purge two $scheme$1;
    }
}
```

访问 URL http://t1.wang.com/a.txt 第一次返回 MISS, 第二次返回HIT, 这时我们太通过http://t1.wang.com/purge/a.txt 清理缓存，再次访问 http://t1.wang.com/a.txt 仍然返回 MISS



```
# curl http://t1.wang.com/a.txt -I
X-Cache-Status: MISS
# curl http://t1.wang.com/a.txt -I
X-Cache-Status: HIT

# curl http://t1.wang.com/purge/a.txt -I
HTTP/1.1 200 OK
Server: nginx/1.14.0
Date: Mon, 07 Dec 2020 01:39:13 GMT
Content-Type: text/html
Content-Length: 270
Connection: keep-alive

# curl http://t1.wang.com/a.txt -I
X-Cache-Status: MISS
```



## uwsgi、fastcgi、scgi 指令的对照表

### uwsgi、fastcgi、scgi

**uwsgi** : 一种python web server或称为Server/Gateway

**fastcgi** : 一个可伸缩地、高速地在HTTP服务器和动态脚本语言间通信的接口（FastCGI接口在Linux下是socket（可以是文件socket，也可以是ip socket）），主要优点是把动态语言和HTTP服务器分离开来。多数流行的HTTP服务器都支持FastCGI，包括Apache、Nginx和lightpd。

**scgi** : 是一个CGI（通用网关接口）协议的替代品· 它是一个应用与HTTP服务器的接口标准，类似于FastCGI,但是它设计得更为容易实现·

### 七层反向代理对照：构造请求内容

**（略）**

### 七层反向代理对照：建立连接并发送请求

**（略）**

### 七层反向代理对照：接收上游响应

**（略）**

### 七层反向代理对照：转发响应

**（略）**

### 七层反向代理对照：SSL

**（略）**

### 七层反向代理对照：缓存类指令（1）

**（略）**

### 七层反向代理对照：缓存类指令（2）

**（略）**

### 七层反向代理对照：独有配置

**（略）**



## memcached 反向代理

### memcached 反向代理

功能：

- 将HTTP 请求转换为 memcached 协议中的 get 请求，转发请求至上游 memcached 服务
- 只能 get 命令：get <key> * \r\n
- 控制命令 ：<command name> <key> <flags> <exptime> <bytes> [noreply]\r\n
- 通过设置 memcached_key 变量构造 key 键

模块：

- ngx_http_memcached_module
- 默认编译进 Nginx
- 通过 --without-http_memcached_module 禁用模块

### memcached 指令用法

### 配置示例

安装memcached,并添加数据

```
# yum -y install memcached
# systemctl start memcached

# telnet 127.0.0.1 11211
get hello
END
set hello 0 0 5
world
STORED
get hello
VALUE hello 0 5
world
END
set gzipkey 2 0 3
xxx
STORED
```

添加配置文件 memcached.conf

```
location /get {
    set $memcached_key "$arg_key";
    # memcached_gzip_flag 2;
    memcached_pass localhost:11211;
}
```

结果测试

```
# curl http://t1.wang.com/get?key=hello
world
# curl http://t1.wang.com/get?key=gzipkey -I
HTTP/1.1 200 OK
Server: nginx/1.14.0
Date: Mon, 07 Dec 2020 03:51:45 GMT
Content-Type: application/octet-stream
Content-Length: 3
Connection: keep-alive
Accept-Ranges: bytes
```

取消memcached.conf注释，如下

```
memcached_gzip_flag 2;
```

结果测试，对照以前的结果，我们发现 header 头部增加了 Content-Encoding: gzip

```
# curl http://t1.wang.com/get?key=gzipkey -I
HTTP/1.1 200 OK
Server: nginx/1.14.0
Date: Mon, 07 Dec 2020 03:53:04 GMT
Content-Type: application/octet-stream
Content-Length: 3
Connection: keep-alive
Content-Encoding: gzip
Accept-Ranges: bytes
```



## 搭建websocket 反向代理

### websocket反向代理

功能：模块ngx_http_proxy_module

配置

```
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

### websocket协议帧

**略，具体内容看pdf**

### 案例测试

配置文件

```
location / {
    proxy_pass http://echo.websocket.org;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

结果测试

通过界面http://www.websocket.org/echo.html 测试，使用url 地址为 ws://t1.wang.com，我们可以通过tcpdump 对端口进行检测。

[![image-20201207141846107](https://wangzhangtao.com/img/body/temp/image-20201207141846107.png)](https://wangzhangtao.com/img/body/temp/image-20201207141846107.png)

image-20201207141846107





## 用分片提升缓存效率

### slice模块

**功能：**通过 range 协议将大文件分解为多个小文件，更好的用缓存为客户端的 range 协议服务

**模块**：

- http_slice_module
- 默认没有编译进Nginx
- 通过 --with-http_slice_module 启用功能

**指令**

```
Syntax: slice size;
Default: slice 0; 
Context: http, server, location
```

### 案例模拟

重新编译nginx

```
# ./configure --prefix=/home/jeek/nginx --with-http_ssl_module --with-http_realip_module --with-http_slice_module && make
```

nginx后端就是普通服务 backed.conf

```
server {
    listen 8012;
    location / {
    }
}
```

转发配置文件slice.conf

```
proxy_cache_path /data/nginx/tmpcache levels=2:2 keys_zone=three:10m
        loader_threshold=300 loader_files=200 max_size=200m inactive=1m;
server {
    server_name t1.wang.com;
    location / {
        proxy_pass http://127.0.0.1:8012;
        proxy_cache_valid 200 206 1m;
        proxy_cache three;
        add_header X-Cache-Status $upstream_cache_status;
        # slice 1m;
        # proxy_cache_key $uri$is_args$args$slice_range;
        # proxy_set_header Range $slice_range;
    }
}
```

结果测试

```
# curl -r 5000010-5000019 http://t1.wang.com/server.mp4 -I
Content-Length: 10
X-Cache-Status: MISS
Content-Range: bytes 5000010-5000019/70283552
```

修改配置文件，添加参数

```
#按照1m大小发送给上游
slice 1m;
proxy_cache_key $uri$is_args$args$slice_range;
proxy_set_header Range $slice_range;
```

结果测试，返回结果没有变化

```
# curl -r 5000010-5000019 http://t1.wang.com/server.mp4 -I
Content-Length: 10
X-Cache-Status: MISS
Content-Range: bytes 5000010-5000019/70283552
```

但是我们查看日志 logs/access.log，发现访问后端缓存的内容字节数减少，只有1M

```
127.0.0.1 - - [07/Dec/2020:17:56:36 +0800] "GET /server.mp4 HTTP/1.0" 200 70283552 "-" "curl/7.29.0"
127.0.0.1 - - [07/Dec/2020:17:59:06 +0800] "GET /server.mp4 HTTP/1.0" 206 1048576 "-" "curl/7.29.0"
```



## open file cache 提升系统性能

### open_file_cache

**缓存信息**

- 文件句柄
- 文件修改时间
- 文件大小
- 文件查询时的错误信息
- 目录是否存在

**指令**

```
Syntax: open_file_cache off;
        open_file_cache max=N [inactive=time];
Default: open_file_cache off; 
Context: http, server, location
```

**其他open_file_cache指令**

```
Syntax: open_file_cache_errors on | off;
Default: open_file_cache_errors off; 
Context: http, server, location

Syntax: open_file_cache_min_uses number;
Default: open_file_cache_min_uses 1; 
Context: http, server, location

Syntax: open_file_cache_valid time;
Default: open_file_cache_valid 60s; 
Context: http, server, location
```



### 配置示例

nginx后端就是普通服务 backed.conf

```
server {
    listen 8012;
    location / {
        # open_file_cache max=10 inactive=60s;
        # open_file_cache_min_uses 1;
        # open_file_cache_valid 60s;
        # open_file_cache_errors on;
    }
}
```

结果测试，访问首页查看 程序运行过程

打开和关闭文件很耗时间，通过 sendfile 方法，可以直接在内核态将数据返回到网卡

```
# curl http://t1.wang.com:8012/
# strace -p 94787
strace: Process 94787 attached
epoll_wait(12, [{EPOLLIN, {u32=39382016, u64=39382016}}], 512, -1) = 1
accept4(11, {sa_family=AF_INET, sin_port=htons(58278), sin_addr=inet_addr("192.168.70.13")}, [16], SOCK_NONBLOCK) = 3
epoll_ctl(12, EPOLL_CTL_ADD, 3, {EPOLLIN|EPOLLRDHUP|EPOLLET, {u32=39382713, u64=39382713}}) = 0
epoll_wait(12, [{EPOLLIN, {u32=39382713, u64=39382713}}], 512, 60000) = 1
recvfrom(3, "GET / HTTP/1.1\r\nUser-Agent: curl"..., 1024, 0, NULL, NULL) = 80
stat("/home/jeek/nginx/html/index.html", {st_mode=S_IFREG|0777, st_size=612, ...}) = 0
open("/home/jeek/nginx/html/index.html", O_RDONLY|O_NONBLOCK) = 6
fstat(6, {st_mode=S_IFREG|0777, st_size=612, ...}) = 0
writev(3, [{"HTTP/1.1 200 OK\r\nServer: nginx/1"..., 238}], 1) = 238
sendfile(3, 6, [0] => [612], 612)       = 612
write(9, "192.168.70.13 - - [07/Dec/2020:1"..., 90) = 90
close(6)                                = 0
setsockopt(3, SOL_TCP, TCP_NODELAY, [1], 4) = 0
epoll_wait(12, [{EPOLLIN|EPOLLRDHUP, {u32=39382713, u64=39382713}}], 512, 65000) = 1
recvfrom(3, "", 1024, 0, NULL, NULL)    = 0
close(3)                                = 0
epoll_wait(12,
```

修改配置文件backed.conf

```
open_file_cache max=10 inactive=60s;
open_file_cache_min_uses 1;
open_file_cache_valid 60s;
open_file_cache_errors on;
```

结果测试，访问首页查看 程序运行过程,发现没有了stat， open 这两个过程。

```
# curl http://t1.wang.com:8012/
# strace -p 95005
[{EPOLLIN, {u32=39380480, u64=39380480}}], 512, -1) = 1
accept4(11, {sa_family=AF_INET, sin_port=htons(58296), sin_addr=inet_addr("192.168.70.13")}, [16], SOCK_NONBLOCK) = 8
epoll_ctl(12, EPOLL_CTL_ADD, 8, {EPOLLIN|EPOLLRDHUP|EPOLLET, {u32=39381177, u64=39381177}}) = 0
epoll_wait(12, [{EPOLLIN, {u32=39381177, u64=39381177}}], 512, 60000) = 1
recvfrom(8, "GET / HTTP/1.1\r\nUser-Agent: curl"..., 1024, 0, NULL, NULL) = 80
writev(8, [{"HTTP/1.1 200 OK\r\nServer: nginx/1"..., 238}], 1) = 238
sendfile(8, 9, [0] => [612], 612)       = 612
write(4, "192.168.70.13 - - [07/Dec/2020:2"..., 90) = 90
setsockopt(8, SOL_TCP, TCP_NODELAY, [1], 4) = 0
epoll_wait(12, [{EPOLLIN|EPOLLRDHUP, {u32=39381177, u64=39381177}}], 512, 65000) = 1
recvfrom(8, "", 1024, 0, NULL, NULL)    = 0
close(8)                                = 0
epoll_wait(12,
```



## HTTP/2 协议介绍

### HTTP2主要特性

- 传输的数据量大幅减少
  - 以二进制方式传输
  - 标头压缩
- 多路复用及相关功能
  - 消息优先级
- 服务器消息推送
  - 并行推送

### HTTP2.0 核心概念

- 连接Connection : 1个TCP 连接，包含一个或者多个Stream
- 数据流Stream : 一个双向通讯数据流，包含多条 Message
- 消息 Message : 对应 HTTP1 中的请求或者响应，包含一条或者多条Frame
- 数据帧 : 最小单位，以二进制压缩格存放HTTP1 中的内容



### 五、HTTP/2 新特性

#### 1. 二进制传输

HTTP/2 采用二进制格式传输数据，而非 HTTP 1.x 的文本格式，二进制协议解析起来更高效。 HTTP / 1 的请求和响应报文，都是由起始行，首部和实体正文（可选）组成，各部分之间以文本换行符分隔。**HTTP/2 将请求和响应数据分割为更小的帧，并且它们采用二进制编码**。

接下来我们介绍几个重要的概念：

- 流：流是连接中的一个虚拟信道，可以承载双向的消息；每个流都有一个唯一的整数标识符（1、2…N）；
- 消息：是指逻辑上的 HTTP 消息，比如请求、响应等，由一或多个帧组成。
- 帧：HTTP 2.0 通信的最小单位，每个帧包含帧首部，至少也会标识出当前帧所属的流，承载着特定类型的数据，如 HTTP 首部、负荷，等等

<img src="/Users/jinhuaiwang/Desktop/截屏2021-03-13 下午9.26.13.png" alt="截屏2021-03-13 下午9.26.13" style="zoom:50%;" />



HTTP/2 中，同域名下所有通信都在单个连接上完成，该连接可以承载任意数量的双向数据流。每个数据流都以消息的形式发送，而消息又由一个或多个帧组成。多个帧之间可以乱序发送，根据帧首部的流标识可以重新组装。

#### 2. 多路复用

在 HTTP/2 中引入了多路复用的技术。多路复用很好的解决了浏览器限制同一个域名下的请求数量的问题，同时也接更容易实现全速传输，毕竟新开一个 TCP 连接都需要慢慢提升传输速度。

大家可以通过 [该链接](https://http2.akamai.com/demo) 直观感受下 HTTP/2 比 HTTP/1 到底快了多少。

[![img](https://image.fundebug.com/2019-03-06-3.gif)](https://image.fundebug.com/2019-03-06-3.gif)

在 HTTP/2 中，有了二进制分帧之后，HTTP /2 不再依赖 TCP 链接去实现多流并行了，在 HTTP/2 中：

- 同域名下所有通信都在单个连接上完成。
- 单个连接可以承载任意数量的双向数据流。
- 数据流以消息的形式发送，而消息又由一个或多个帧组成，多个帧之间可以乱序发送，因为根据帧首部的流标识可以重新组装。

这一特性，使性能有了极大提升：

- 同个域名只需要占用一个 TCP 连接，使用一个连接并行发送多个请求和响应,消除了因多个 TCP 连接而带来的延时和内存消耗。
- 并行交错地发送多个请求，请求之间互不影响。
- 并行交错地发送多个响应，响应之间互不干扰。
- 在 HTTP/2 中，每个请求都可以带一个 31bit 的优先值，0 表示最高优先级， 数值越大优先级越低。有了这个优先值，客户端和服务器就可以在处理不同的流时采取不同的策略，以最优的方式发送流、消息和帧。

<img src="https://image.fundebug.com/2019-03-06-4.png" alt="img" style="zoom: 50%;" />



如上图所示，多路复用的技术可以只通过一个 TCP 连接就可以传输所有的请求数据。



**传输中无序，接收时组装**

<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-13 下午9.27.47.png" alt="截屏2021-03-13 下午9.27.47" style="zoom: 33%;" />



**设置数据流优先级**：每个数据流有优先级（1-256）；数据流间可以有依赖关系

<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-13 下午9.28.34.png" alt="截屏2021-03-13 下午9.28.34" style="zoom: 33%;" />



#### 3. Header 压缩

**标头数据压缩 ：多次请求时，header头部只返回变化部分**

在 HTTP/1 中，我们使用文本的形式传输 header，在 header 携带 cookie 的情况下，可能每次都需要重复传输几百到几千的字节。

为了减少这块的资源消耗并提升性能， HTTP/2 对这些首部采取了压缩策略：

- HTTP/2 在客户端和服务器端使用“首部表”来跟踪和存储之前发送的键－值对，对于相同的数据，不再通过每次请求和响应发送；
- 首部表在 HTTP/2 的连接存续期内始终存在，由客户端和服务器共同渐进地更新;
- 每个新的首部键－值对要么被追加到当前表的末尾，要么替换表中之前的值

例如下图中的两个请求， 请求一发送了所有的头部字段，第二个请求则只需要发送差异数据，这样可以减少冗余数据，降低开销

<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-13 下午9.29.20.png" alt="截屏2021-03-13 下午9.29.20" style="zoom:50%;" />

**Fram格式**



### 4. Server Push



Server Push 即服务端能通过 push 的方式将客户端需要的内容预先推送过去，也叫“cache push”。

可以想象以下情况，某些资源客户端是一定会请求的，这时就可以采取服务端 push 的技术，提前给客户端推送必要的资源，这样就可以相对减少一点延迟时间。当然在浏览器兼容的情况下你也可以使用 prefetch。
例如服务端可以主动把 JS 和 CSS 文件推送给客户端，而不需要客户端解析 HTML 时再发送这些请求。



<img src="/Users/jinhuaiwang/Library/Application Support/typora-user-images/截屏2021-03-13 下午9.30.10.png" alt="截屏2021-03-13 下午9.30.10" style="zoom:50%;" />



服务端可以主动推送，客户端也有权利选择是否接收。如果服务端推送的资源已经被浏览器缓存过，浏览器可以通过发送 RST_STREAM 帧来拒收。主动推送也遵守同源策略，换句话说，服务器不能随便将第三方资源推送给客户端，而必须是经过双方确认才行。



小技巧：在谷歌浏览器上使用插件 “HTTP/2 and SPDY” 检查服务器是否支持HTTP2

[参考连接](https://blog.fundebug.com/2019/03/07/understand-http2-and-http3/)



## 搭建HTTP/2 服务并推送资源

### http2

- **功能**：对客户端使用http2 协议
- **模块**：ngx_http_v2_module, 通过 --with-http_v2_module 编译nginx，加入对 http2 的支持
- **前提**：开启TLS/SSL 协议
- **使用方法**：listen 443 ssl http2;

### nginx推送资源

指令

```
Syntax: http2_push_preload on | off;
Default: http2_push_preload off; 
Context: http, server, location

Syntax: http2_push uri | off;
Default: http2_push off; 
Context: http, server, location
```



### 测试nginx http2 协议的客户端工具

方式一：在 https://github.com/nghttp2/nghttp2/releases 下载安装

方式二：centos下使用 yum 安装 ：yum install nghttp2

### http2 其他参数

最大并行推送个数

```
Syntax: http2_max_concurrent_pushes number;
Default: http2_max_concurrent_pushes 10; 
Context: http, server
```

超时控制

```
在30s还没有接收到请求,关闭http2连接
Syntax: http2_recv_timeout time;
Default: http2_recv_timeout 30s; 
Context: http, server

#连接在空闲时间到达时,即没有请求又响应,就会把连接关闭
Syntax: http2_idle_timeout time;
Default: http2_idle_timeout 3m; 
Context: http, server
```



并发请求控制

```
#最大并行推送个数
Syntax: http2_max_concurrent_pushes number;
Default: http2_max_concurrent_pushes 10; 
Context: http, server

Syntax: http2_max_concurrent_streams number;
Default: http2_max_concurrent_streams 128; 
Context: http, server

Syntax: http2_max_field_size size;
Default: http2_max_field_size 4k; 
Context: http, server
```

连接最大处理请求数

```
Syntax: http2_max_requests number;
Default: http2_max_requests 1000; 
Context: http, server

Syntax: http2_chunk_size size;
Default: http2_chunk_size 8k; 
Context: http, server, location
```



设置响应包体的分片大小

```
Syntax: http2_chunk_size size;
Default: http2_chunk_size 8k; 
Context: http, server, location
```

缓冲区大小设置

```
Syntax: http2_recv_buffer_size size;
Default: http2_recv_buffer_size 256k; 
Context: http

Syntax: http2_max_header_size size;
Default: http2_max_header_size 16k; 
Context: http, server

Syntax: http2_body_preread_size size;
Default: http2_body_preread_size 64k; 
Context: http, server
```



### 案例模拟

安装nghttps2

```
yum install nghttp2 -y
```

重新编译nginx

```
./configure --prefix=/home/jeek/nginx --with-http_ssl_module --with-http_realip_module --with-http_v2_module && make
```

配置文件htt2.conf

```
server {
    listen 4430 ssl http2;
    server_name test1.wang.com;
    
    ssl_certificate cert/wang.pem;
    ssl_certificate_key cert/wang.key;
    
    location /{
        http2_push /mirror.txt;
        http2_push /server.mp4;
    }
    location /test {
        add_header Link "</style.css>; as=style; rel=preload";
        http2_push_preload on;
    }
}
```

结果测试

```
# nghttp -ns https://127.0.0.1:4430/
id  responseEnd requestStart  process code size request path
 13      +554us       +155us    398us  200  384 /
  2      +590us *     +390us    199us  200   11 /mirror.txt
  4   +132.44ms *     +432us 132.01ms  200  67M /server.mp4

# nghttp -ns https://127.0.0.1:4430/test/  
id  responseEnd requestStart  process code size request path
 13      +296us       +124us    172us  301  185 /test
  2      +316us *     +250us     66us  200   10 /style.css
```



##  gRPC反向代理

### gRPC反向代理

- grpc协议：[https://grpc.io](https://grpc.io/)
- 模块：
  - ngx_http_grpc_module, 通过 --without-http_grpc_module 禁用
  - 依赖 ngx_http_v2_module 模块

### grpc 指令和 http 对照表

|                     |                            | **􏰂􏰓􏰓􏰁􏰏􏰛􏰈􏰡**                |
| ------------------- | -------------------------- | --------------------------- |
| **􏰞􏰌􏰒􏰢**            | grpc_pass                  | proxy_pass                  |
| **􏰣􏰤􏰥􏰌􏰘􏰍**          | grpc_bind                  | proxy_bind                  |
| **􏰤􏰦􏰝􏰚􏰄􏰧􏰨􏰅**        | grpc_buffer_size           | proxy_buffer_size           |
| **􏰣􏰤􏰒􏰢􏰩􏰪􏰪􏰫**        | grpc_connect_timeout       | proxy_connect_timeout       |
| **􏰇􏰬􏰪􏰭􏰮􏰒􏰢**         | grpc_next_upstream         | proxy_next_upstream         |
| **􏰭􏰮􏰒􏰢􏰩􏰪**          | grpc_next_upstream_timeout | proxy_next_upstream_timeout |
| **􏰭􏰮􏰒􏰢􏰯􏰰􏰱􏰲**        | grpc_next_upstream_tries   | proxy_next_upstream_tries   |
| **􏰳􏰐􏰝􏰚􏰩􏰪􏰪􏰫**        | grpc_read_timeout          | proxy_read_timeout          |
| **􏰊􏰴􏰵􏰶􏰩􏰪􏰪􏰫**        | grpc_send_timeout          | proxy_send_timeout          |
| **􏰑􏰷TCP keepalive** | grpc_socket_keepalive      | proxy_socket_keepalive      |
| `􏰔􏰆􏰊􏰛􏰗􏰸􏰹􏰺􏰝􏰚􏰄􏰧 `     | grpc_hide_header           | proxy_hide_header           |
| **􏰻􏰷􏰝􏰚􏰄􏰧􏰎􏰼**        | grpc_ignore_header         | proxy_ignore_header         |
| **􏰽􏰾􏰒􏰢􏰬􏰿􏰝􏰚**        | grpc_intercept_errors      | proxy_intercept_errors      |
| **􏰜􏱀􏰄􏰧􏰖􏰗􏰸􏰹**        | grpc_pass_header           | proxy_pass_header           |
| **􏰙􏱁􏱂􏰵􏰶􏰄􏰧**         | grpc_set_header            | proxy_set_header            |

### grpc 指令和 http SSL 部分对照表

### 配置示例

```
# git clone -b v1.34.0 https://github.com/grpc/grpc  # 方案一（二选一）
# git clone https://gitee.com/local-grpc/grpc.git  # 方案二（二选一）
# cd grpc/examples/python/helloworld/
```

我们启动服务器进行监听，并起一个窗口，执行客户端验证。必须有grpc，没有的看下面。

```
# python  greeter_server.py   
# python greeter_client.py 
Greeter client received: Hello, you!
```

添加nginx代理配置文件 grpc.conf

```
server {
    listen 4431 http2;
    server_name test1.wang.com;
    
    ssl_certificate cert/wang.pem;
    ssl_certificate_key cert/wang.key;
    
    location /{
        grpc_pass 127.0.0.1:50051;
    }  
}
```

结果测试，修改greeter_client.py 端口为4431，并执行脚本测试

```
# python greeter_client.py
Greeter client received: Hello, you!
```

**安装pip**

pip tar包请去官网找链接

```
# wget https://files.pythonhosted.org/packages/cb/5f/ae1eb8bda1cde4952bd12e468ab8a254c345a0189402bf1421457577f4f3/pip-20.3.1.tar.gz
# tar xf pip-20.3.1.tar.gz 
# cd pip-20.3.1
# python3 setup.py build
# python3 setup.py install
```

- [安装pip三种方式](https://www.cnblogs.com/yangmingxianshen/p/11029532.html)

**安装 grpc 模块**

运行python程序，报错
`ImportError: No module named grpc`

解决办法：

```
$ python -m pip install grpcio
$ python -m pip install grpcio-tools
```

- [No module named grpc解决办法](https://blog.csdn.net/lord_y/article/details/100139441)



## stream四层反向代理

### stream模块处理7个阶段

| POST_ACCEPT | realip               |
| ----------- | -------------------- |
| PREACCESS   | limt_conn(同7层)     |
| ACCESS      | access               |
| SSL         | ssl                  |
| PREREAD     | ssl_preread          |
| CONTENT     | return, stream_proxy |
| LOG         | access_log           |

### stream 中的ssl

```
Syntax: stream { ... }
Default: —
Context: main
```

```
Syntax: server { ... }
Default: —
Context: stream
```

```
Syntax: listen address:port [ssl] [udp] [proxy_protocol] [backlog=number] [rcvbuf=size] [sndbuf=size] 
[bind] [ipv6only=on|off] [reuseport] [so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];
Default: —
Context: server
```

### 传输层相关的变量

- binary_remote_addr : 客户端地址的整形格式，对于IPv4 是4字节，对于IPv6是 16字节
- connection : 递增的连接序号
- remote_addr : 客户端地址
- remote_port : 客户端端口
- server_addr : 服务器端地址
- server_port : 服务器端端口
- protocol : 传输层协议，值为 TCP 或者 UDP
- proxy_protocol_addr : 若使用了proxy_protocol 协议则返回协议中的地址，否则返回空
- proxy_protocol_port : 若使用了proxy_protocol 协议则返回协议中的端口，否则返回空

- bytes_received ：从客户端接受的字节数
- bytes_send : 已经发送到客户端的字节数
- status
  - 200 : session 成功结束
  - 400 : 客户端数据无法解析，例如proxy_protocol 协议的格式不正确
  - 403 : 访问权限不足被拒绝，例如access模块限制了客户端IP地址
  - 500 : 服务器内部代码错误
  - 502 : 无法找到或者连接上游服务
  - 503 : 上游服务不可用

### Nginx 系统变量

- time_local : 以本地时间标准输出的当前时间，例如14/Nov/2018:15:55:37 +0800
- time_iso8601 : 使用 ISO 8601 标准输出的当前时间，例如 2018-11-14T15:55:37+08:00
- nginx_version : Nginx 版本号
- pid : 所属 worker 进程的进程id
- pipe : 使用了管道则返回 p, 否则返回 .
- hostname : 所在服务器的主机名，与 hostname 命令输出一致
- msec : 1970年1月1日到现在的时间，单位为妙，小数点后精确到毫秒

### conten阶段：return 模块

```
Syntax: return value;
Default: —
Context: server
```

### 配置示例

重新编译nginx

```
# ./configure --prefix=/home/jeek/nginx --with-http_ssl_module --with-http_realip_module --with-stream && make
```

配置文件 stream.conf

```nginx
stream {
    server {
        listen 10004;
        return '10004 vars:
bytes_received: $bytes_received
bytes_sent : $bytes_sent
proxy_protocol_addr : $proxy_protocol_addr
proxy_protocol_port : $proxy_protocol_port
remote_addr : $remote_addr
remote_port : $remote_port
server_addr : $server_addr
server_port : $server_port
session_time : $session_time
status : $status
protocol : $protocol
\n';
    }
}
```

结果测试

```nginx
# telnet 127.0.0.1 10004
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
10004 vars:
bytes_received: 0
bytes_sent : 0
proxy_protocol_addr : 
proxy_protocol_port : 
remote_addr : 127.0.0.1
remote_port : 33610
server_addr : 127.0.0.1
server_port : 10004
session_time : 0.000
status : 000
protocol : TCP

Connection closed by foreign host.
```



##  proxy protocol协议与realip 模块

### stream 处理 proxy_protocol 流程

1. 连接建立成功，携带 listen proxy_protocol
2. 加入读定时器 proxy_protocol_timeout (默认30秒)
3. 读取 107 字节（proxy_protocol 最大长度）
4. 判断前12字节是否匹配 V2 协议头部
   - 读取v1 协议头部的真实IP地址
   - 读取v2 协议头部的真实IP地址
5. 进入7个阶段的stream 模块处理

### post_accept 阶段 : realip 模块

**功能**：通过 proxy_protocol 协议取出客户端真实地址，并写入remote_addr 及remote_port 变量。同时使用reaplip_remote_addr 和 realip_remote_port 保留 TCP 连接中获得的原始地址

**模块**：ngx_stream_realip_module, 通过 --with-stream_realip_module 启用功能

**指令**

```nginx
Syntax: set_real_ip_from address | CIDR | unix:;
Default: —
Context: stream, server
```

### 配置示例

重新编译nginx

```nginx
# ./configure --prefix=/home/jeek/nginx --with-http_ssl_module --with-http_realip_module --with-stream --with-stream_realip_module && make
```

配置文件

```nginx
stream {
    server {
        listen 10004 proxy_protocol;
        # set_real_ip_from 127.0.0.1;
        return '10004 vars:
bytes_received: $bytes_received
bytes_sent : $bytes_sent
proxy_protocol_addr : $proxy_protocol_addr
proxy_protocol_port : $proxy_protocol_port
remote_addr : $remote_addr
remote_port : $remote_port
realip_remote_addr : $realip_remote_addr
realip_remote_port : $realip_remote_port
server_addr : $server_addr
server_port : $server_port
session_time : $session_time
status : $status
protocol : $protocol
\n';
    }
}
```

结果测试

```shell
# telnet 127.0.0.1 10004
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
PROXY TCP4 172.16.16.19 192.168.7.11 5678 80\r\n
10004 vars:
bytes_received: 0
bytes_sent : 0
proxy_protocol_addr : 172.16.16.19
proxy_protocol_port : 5678
remote_addr : 127.0.0.1
remote_port : 33614
realip_remote_addr : 127.0.0.1
realip_remote_port : 33614
server_addr : 127.0.0.1
server_port : 10004
session_time : 1.689
status : 000
protocol : TCP

Connection closed by foreign host.
```

取消配置文件中的注释

```
set_real_ip_from 127.0.0.1;
```

配置文件

```shell
# telnet 127.0.0.1 10004
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
PROXY TCP4 172.16.16.19 192.168.7.11 5678 80\r\n
10004 vars:
bytes_received: 0
bytes_sent : 0
proxy_protocol_addr : 172.16.16.19
proxy_protocol_port : 5678
remote_addr : 172.16.16.19
remote_port : 5678
realip_remote_addr : 127.0.0.1
realip_remote_port : 33616
server_addr : 127.0.0.1
server_port : 10004
session_time : 3.683
status : 000
protocol : TCP

Connection closed by foreign host.
```



## 限制并发连接、限IP、记日志

### PREACCESS 阶段的 limit_conn 模块

**功能**：限制客户端的并发连接数。使用变量自定义限制依据，基于共享内存所有 worker 进程同时生效。

**模块**：ngx_stream_limit_conn_module, 通过 --without-stream_limit_conn_module 禁用模块

**指令**

```nginx
#定义共享内存,名字,大小
Syntax: limit_conn_zone key zone=name:size;
Default: —
Context: stream

Syntax: limit_conn zone number;
Default: —
Context: stream, server

Syntax: limit_conn_log_level info | notice | warn | error;
Default: limit_conn_log_level error; 
Context: stream, server
```



### ACCESS 阶段的 acess 模块

**功能**：根据客户端地址（realip 模块可以修改地址）决定连接的访问权限

**模块**：ngx_stream_access_module, 通过 –without-stream_access_module 禁用模块

**指令**

```
Syntax: allow address | CIDR | unix: | all;
Default: —
Context: stream, server

Syntax: deny address | CIDR | unix: | all;
Default: —
Context: stream, server
```



### log 阶段：stream_log 模块

```
Syntax: access_log path format [buffer=size] [gzip[=level]] [flush=time] [if=condition];
        access_log off;
Default: access_log off; 
Context: stream, server

Syntax: log_format name [escape=default|json|none] string ...;
Default: —
Context: stream

Syntax: open_log_file_cache max=N [inactive=time] [min_uses=N] [valid=time];
open_log_file_cache off;
Default: open_log_file_cache off; 
Context: stream, server
```

### 配置示例

配置文件

```
stream {
    log_format basic '$remote_addr [$time_local] $protocol'
            '$status $bytes_sent $bytes_received $session_time';
    access_log logs/stream_access.log basic;
    error_log logs/stream_error.log debug;
    
    server {
        listen 10004 proxy_protocol;
        set_real_ip_from 127.0.0.1;
        allow 172.16.16.19;
        deny all;
        
        return '10004 vars:
bytes_received: $bytes_received
bytes_sent : $bytes_sent
proxy_protocol_addr : $proxy_protocol_addr
proxy_protocol_port : $proxy_protocol_port
remote_addr : $remote_addr
remote_port : $remote_port
realip_remote_addr : $realip_remote_addr
realip_remote_port : $realip_remote_port
server_addr : $server_addr
server_port : $server_port
session_time : $session_time
status : $status
protocol : $protocol
\n';
    }
}
```

结果测试.我们访问两次，一次使用地址172.16.16.18，这是权限被拒绝，一次使用172.16.16.19，这时允许访问，测试如下：

```nginx
# telnet 127.0.0.1 10004
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
PROXY TCP4 172.16.16.18 192.168.7.11 5678 80\r\n
Connection closed by foreign host.

]# telnet 127.0.0.1 10004  
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
PROXY TCP4 172.16.16.19 192.168.7.11 5678 80\r\n
10004 vars:
bytes_received: 0
bytes_sent : 0
proxy_protocol_addr : 172.16.16.19
proxy_protocol_port : 5678
remote_addr : 172.16.16.19
remote_port : 5678
realip_remote_addr : 127.0.0.1
realip_remote_port : 33618
server_addr : 127.0.0.1
server_port : 10004
session_time : 5.405
status : 000
protocol : TCP

Connection closed by foreign host.
```

我们查看日志

```nginx
# tail ../logs/stream_access.log 
172.16.16.18 [08/Dec/2020:22:50:00 +0800] TCP403 0 0 8.087
172.16.16.19 [08/Dec/2020:22:49:40 +0800] TCP200 0 0 5.405
```



## stream 四层反向代理处理 SSL 下游流量

### stream 中的ssl

功能：使stream 反向代理对下游支持 TLS/SSL 协议

模块

- ngx_stream_ssl_module
- 默认不编译进 nginx
- 通过 --with-stream_ssl_module加入nginx

### stream ssl 指令对比 http 模块

- 配置基本参数
- 提升性能
- 验证客户端证书

### stream ssl 模块提供的变量

- 安全套件
- 证书
- 证书结构化信息
- 证书有效期

### 配置示例

重新编译nginx

```nginx
# ./configure --prefix=/home/jeek/nginx --with-http_ssl_module --with-http_realip_module --with-stream --with-stream_ssl_module --with-stream_realip_module && make
```

后端配置文件 backend.conf

```nginx
server {
    listen 8011;
    server_name test1.nginx.com;
 
    location / {
    }
}
```

前端配置文件 stream.conf

```nginx
stream {
    log_format basic '$remote_addr [$time_local] $protocol'
            '$status $bytes_sent $bytes_received $session_time';
    access_log logs/stream_access.log basic;
    error_log logs/stream_error.log debug;
        
    server {
        listen 4434 ssl;
        proxy_pass localhost:8011;
        ssl_certificate cert/wang.pem;
        ssl_certificate_key cert/wang.key;
    }
}
```

结果测试

```
# curl https://test1.nginx.com:4434
```

同时监听端口

```nginx
# tcpdump -i lo port 8011 -A -s 0
...
........GET / HTTP/1.1
Host: test1.nginx.com:4434
User-Agent: curl/7.54.0
Accept: */*
...
```



## stream_preread 模块取出 SSL 关键信息

### SSL_PREREAD 模块

**功能**：解析下游TLS 证书中信息，以变量方式赋能其他模块

**模块**：stream_ssl_preread_module, 使用 --with-stream_ssl_preread_module 启用模块

**提供变量**

- $ssl_preread_protocol : 客户端支持的TLS 版本中最高的版本，例如 TLSv1.3
- $ssl_preread_server_name : 从SNI中获取到的服务器域名
- $ssl_preread_alpn_protocols : 通过ALPN 中获取到的客户端建议使用的协议，例如h2, http/1.1

### preread阶段：ssl_preread模块

```
Syntax: preread_buffer_size size;
Default: preread_buffer_size 16k; 
Context: stream, server
```

```
Syntax: preread_timeout timeout;
Default: preread_timeout 30s; 
Context: stream, server
```

```
Syntax: ssl_preread on | off;
Default: ssl_preread off; 
Context: stream, server
```

### 配置示例

重新编译nginx

```
# ./configure --prefix=/home/jeek/nginx --with-http_ssl_module --with-http_realip_module --with-stream --with-stream_ssl_module --with-stream_ssl_preread_module --with-stream_realip_module && make
```

后端配置文件 backend.conf

```
server {
    listen 443 ssl;
    server_name streampreread.nginx.com;
    ssl_certificate cert/wang.pem;
    ssl_certificate_key cert/wang.key; 
    location / {
    }
}
```

前端配置文件 stream.conf

```
stream {
    log_format basic '$remote_addr [$time_local] $protocol'
            '$status $bytes_sent $bytes_received $session_time'
            'ssl_preread=[$ssl_preread_server_name]';
    access_log logs/stream_access.log basic;
    error_log logs/stream_error.log debug;
        
    server {
        listen 4433;
        proxy_pass $ssl_preread_server_name:443;
        ssl_preread on;
        
        resolver 114.114.114.114; # 必须要加，否则报错
        resolver_timeout 60s;
    }
}
```

结果测试: 访问 [https://test1.wang.com:4433](https://test1.wang.com:4433/)

- [Nginx解决“no resolver defined to resolve xxx.xxx”](https://blog.csdn.net/mimei123/article/details/65446732/)



## stream proxy四层反向代理

### STREAM SSL_PREREAD 模块实战

基于stream_ssl_preread_module 模块中取得的证书中域名，选择上游的服务

**功能**：

- 提供 TCP/UDP 协议的方向代理
- 支持与上游的连接使用 TLS/SSL 协议
- 支持与上游的连接使用 proxy protocol 协议

**模块**：ngx_stream_proxy_module, 默认在Nginx中

<img src="/Users/jinhuaiwang/Desktop/截屏2021-03-16 上午11.52.00.png" alt="截屏2021-03-16 上午11.52.00" style="zoom:50%;" />

为什么nginx不对上图蓝色的线做限速？

答案：只要限制了上行的速率，下行的速率自然就被限制了。

### proxy 模块对上下游的限度指令

限制读取上游服务数据的速度

```
Syntax: proxy_download_rate rate;
Default: proxy_download_rate 0; 
Context: stream, server
```

限制读取客户端数据的速度

```
Syntax: proxy_upload_rate rate;
Default: proxy_upload_rate 0; 
Context: stream, server
```

### stream 反向代理指令和 http 模块对照表

### 配置示例

后端http服务

```
server {
    server_name "t1.wang.com";
    listen 9001 proxy_protocol;
    location / {
        return 200 'proxy_protocol_addr:$proxy_protocol_addr proxy_protocol_port:$proxy_protocol_port\n';
    }
}
```

stream转发配置文件 stream.conf

```
server {
    listen 4435;
    proxy_pass localhost:9001;
    proxy_protocol on;
}
```

结果测试

```
# curl http://t1.wang.com:4435
proxy_protocol_addr:192.168.70.13 proxy_protocol_port:34074
```

通过tcpdump 监听一下端口，确认是转发了 proxy_protocol 协议

```
# tcpdump -i lo port 9001 -A  -s 0
```

[![image-20201209205859745](https://wangzhangtao.com/img/body/temp/image-20201209205859745.png)](https://wangzhangtao.com/img/body/temp/image-20201209205859745.png)





将配置文件 stream.conf 注释下面一行

```
# proxy_protocol on;
```

结果测试

```
# telnet localhost 4435                
Trying ::1...
telnet: connect to address ::1: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
PROXY TCP4 202.112.144.236 10.210.12.10 5678 80\r\n
GET / HTTP/1.1
HOST: localhost    

HTTP/1.1 200 OK
Server: nginx/1.14.0
Date: Wed, 09 Dec 2020 13:02:02 GMT
Content-Type: application/octet-stream
Content-Length: 60
Connection: keep-alive

proxy_protocol_addr:202.112.144.236 proxy_protocol_port:5678
Connection closed by foreign host.
```



## UDP 反向代理

### UDP 反向代理

指定一次会话 session 中最多从客户端收到多少报文就结束 session

- 仅会话结束才会记录access 日志
- 同一个会话中，nginx 使用同一端口连接上游服务
- 设置为0 表示不限制，每次请求都会记录access 日志

指令

```
Syntax: proxy_requests number;
Default: proxy_requests 0; 
Context: stream, server
```

指定对应一个请求报文，上游返回多少个响应报文

- 和 proxy_timeout 结合使用，控制上游服务是否不可用

```
Syntax: proxy_responses number;
Default: —
Context: stream, server
```



### 配置示例

nginx 版本需要1.15.7以上

配置文件 stream.conf

接收到3个请求，2次响应算一次会话

```
server {
    listen 4436 udp;
    proxy_pass localhost:9999;
    proxy_requests 3;
    proxy_responses 2;
    proxy_timeout 2s;
    access_log logs/udp_access.log;
}
```

客户端python 文件client.py

```python
import socket
import sys

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
if len(sys.argv) == 2:
    port = int(sys.argv[1])
else:
    port = 9999
for data in ['a', 'b', 'c']:
    s.sendto(str.encode(data), ('127.0.0.1', port))
    print('first recv:',s.recv(1024))
    print('second recv:',s.recv(1024))

s.close()
```



# 性能优化

## 优化方法论

从软件层面提升硬件使用效率

* 增大cpu的利用率
* 增大内存的利用率
* 增大硬盘IO的利用率
* 增大网络带宽的利用率



提升硬件规格

* 网卡: 万兆网卡
* 磁盘: 固态硬盘
* cpu: 更快的主频,更多的核心,更大的缓存,更好的架构
* 内存:更快的访问速度

超出硬件性能上限后使用DNS



## Nginx 如何增大nginx使用cpu有效时长

设置worker进程的数量

```
worker_processes auto;
```



设置worker进程的静态优先级

```
worker_priority -20;
```

首先要知道问题： NICE 表示友好 也就是会让出时间切片 

所以我们会将静态优先级设置比较低 让他很不友好

Priority 表示动态优先级 ： 0-139



提高cpu缓存命中率:

```
worker_cpu_affinity
```



## nginx 磁盘IO优化



**磁盘IO优化**

优化读取

* Sendfile 零拷贝、
* 内存盘、SSD盘

减少写入

* AIO
* 增大error_log级别的日志
* 关闭access_log 
* 压缩access_log
* 是否启用proxy buffering
* syslog替代本地IO

线程池 thread pool

 

**适用于大文件的直接IO**

当磁盘文件超过size大小之后，使用directIO功能，避免Buffered IO模式下磁盘页缓存中的拷贝消耗

```
Syntax: directio size | off;  #配置文件最大后表示大于大小
Default: directio off;
Context: http, server, location Syntax: directio_alignment size;  读取文件缓冲区
Default: directio_alignment 512;
Context: http, server, location
```

异步IO

普通IO：当程序发起一个系统调用去读一个文件时，程序这时会被阻塞住等待读取到文件再次执行，这是先到内核空间发起一个read请求，开始去读磁盘数据，读到高速缓存（内存）里，这时唤醒进程继续执行；写的时候是直接写到高速缓存(内存)里，之后自动同步

异步IO： 当用户发起一个读操作时，程序不会被阻塞在哪里，可以去处理其他请求

![img](https://bbsmax.ikafan.com/static/L3Byb3h5L2h0dHBzL2ltZzIwMTguY25ibG9ncy5jb20vYmxvZy8xNDY4MjMxLzIwMTkwNy8xNDY4MjMxLTIwMTkwNzIwMTkwNTE0NTYwLTEwMDc5ODUyNS5wbmc=.jpg)

nginx指令启用异步IO

```
Syntax: aio on | off | threads[=pool];  # 最后这个是线程池；调应的
Default: aio off;
Context: http, server, location Syntax: aio_write on | off;  #设置写时启用AIO；默认是关闭的；
Default: aio_write off;
Context: http, server, location
```

异步IO线程池的定义，默认未编译 --with-threads

线程池：worker进程在处理时，有一些请求可能会发生一些阻塞，这是我们就不能接受worker进程的阻塞，而是在worker进程里定义一些线程池，由线程池里的线程处理这些可能发生系统阻塞的工作；为什么会出现这样的场景呢：因为nginx在做静态资源服务器的时候，处理了太多的文件，因为处理文件太多，会导致文件缓存的inode失效，因为内存不够大而导致的，一些操作大部分情况下会命中内存中缓存的。

![img](https://bbsmax.ikafan.com/static/L3Byb3h5L2h0dHBzL2ltZzIwMTguY25ibG9ncy5jb20vYmxvZy8xNDY4MjMxLzIwMTkwNy8xNDY4MjMxLTIwMTkwNzIwMTkxMTI1ODQzLTE4Mzg4ODE3ODUucG5n.jpg)

定义线程池

```
Syntax: thread_pool name threads=number [max_queue=number];  #在静态服务的情况下使用线程池
Default: thread_pool default threads=32 max_queue=65536; # max_queue是定义队列最大长度；threads=32 线程池里线程个数
Context: main
```

异步IO中缓存

```
Syntax: output_buffers number size;
Default: output_buffers 2 32k;
Context: http, server, location
```



**empty_gif 模块默认是编译进nginx中的**

ngx_http_empty_gif_module

功能：从前端用户做用户行为分析时，由于跨域等请求，前端打点的上报数据是get请求，且考虑到浏览器接卸DOM树的性能消耗，所以请求透明图片消耗最小，而1*1的gift图片体积最小（仅43字节），故通常请求gif图片，并在请求中把用户行为信息上报服务器；Nginx可以在access日志中获取到请求参数，进而统计用户行为，但若在磁盘中读取1x1的文件有磁盘IO消耗，empty_gif模块将图片放在内存中，加速了处理速度

```
Syntax: empty_gif;
Default: —
Context: location
```

记录日志时启用压缩功能

```
Syntax: access_log path [format [buffer=size] [gzip[=level]] [flush=time][if=condition]];  #[buffer=缓存大小][gzip[=压缩比例可选1-9，数字越大压缩的越小，话的时间越多]] [flush=最长刷新时间]
Default: access_log logs/access.log combined;
Context: http, server, location, if in location, limit_except
```

error.log 日志内容输出到内存中

场景：开发环境下定位，若需要打开debug级别日志，但大量的debug日志引发性能问题不能容忍，可以将日志输出到内存中

配置语法

```
error_log memory:32m debug；
```

查看中日志方法

gdb-p[worker 进程 ID ] -ex "source nginx.gdb" --batch nginx.gdb脚本内容

```
set $log = ngx_cycle->log
while $log->writer != ngx_log_memory_writer
set $log = $log->next
end
set $buf = (ngx_log_memory_buf_t *) $log->wdata
dump binary memory debug_log.txt $buf->start $buf->end
```

syslog协议

![img](https://bbsmax.ikafan.com/static/L3Byb3h5L2h0dHBzL2ltZzIwMTguY25ibG9ncy5jb20vYmxvZy8xNDY4MjMxLzIwMTkwNy8xNDY4MjMxLTIwMTkwNzIyMTI0NjA1MTkwLTEzMzA4Mjc5OTMucG5n.jpg)

## sendfile 零拷贝

**作用:**

* 减少进程间切换
* 减少内存拷贝次数

![img](https://bbsmax.ikafan.com/static/L3Byb3h5L2h0dHBzL2ltZzIwMTguY25ibG9ncy5jb20vYmxvZy8xNDY4MjMxLzIwMTkwNy8xNDY4MjMxLTIwMTkwNzIyMTI1MzUzNTQ1LTEyNzA1MjI1NzMucG5n.jpg)

应用程序普通调用：应用程序先发起一个读请求，从磁盘读到内核再从内核读到应用程序缓存里，然后程序再把缓存里的数据写到内核的socket缓冲再进行发送

sendfile技术：程序程序只发起一个sendfile 的调用，告诉内核我要把磁盘数据从哪里开始读读取多少字节，然后把读到的数据发送到那个socket套接字上

**sendfile 、直接IO、异步IO同时启用时**

直接IO会禁用sendfile技术

```
location /video/ {
sendfile on;
aio on;
directio 8m;
}
  当文件大小超过8M时，启用AIO与directio
```

　　

gzip_static 模块： ngx_http_gzip_static_module，通过--with-http_gzip_static_module启用该模块

功能：检测到同名.gz文件时，response 中通过gzip相关header返回.gz文件的内容

```
Syntax: gzip_static on | off | always;    #不管客户端是否支持压缩我都把压缩文件发给客户端always ；on是会判断客户端是否会支持压缩
Default: gzip_static off; Context: http, server, location
```

gunzip ： 模块ngx_http_gunzip_module，通过--with-http_gunzip_module启用该模块

功能：当客户端不支持gzip压缩时，且磁盘上仅有压缩文件，则实时解压缩并将其发送给客户端

```
Syntax: gunzip on | off;
Default: gunzip off;
Context: http, server, location Syntax: gunzip_buffers number size;  #打开内存缓存区
Default: gunzip_buffers 32 4k|16 8k;
Context: http, server, location
```

　　

## tcmalloc内存分配器

更快的内存分配器：并发能力强于glibc;并发线程数越多，性能越好 ；减少内存碎片；擅长管理小块内存。这是谷歌提供的第三方模块介绍：http://goog-perftools.sourceforge.net/doc/tcmalloc.html

地址：https://github.com/gperftools/gperftools/

安装此系统模块

```
 wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.9/gperftools-2.9.tar.gz
[root@python ]# tar xf gperftools-2.7.tar.gz
[root@python ]# cd gperftools-2.7/
[root@python gperftools-2.7]# ./configure
[root@python gperftools-2.7]# make && make install
查看生成库文件路径/usr/local/lib/
ll /usr/local/lib/libtcmalloc.so
```



# Nginx Troubleshoot



配置完proxy_cache, 通过查看error日志文件，发现有下面的错误提示：

> 2019/03/13 01:22:17 [crit] 3331#0: *10 open() "/usr/local/lnmp/nginx/fastcgi_temp/3/00/0000000003" failed (13: Permission denied)

**解决方法:**

1. 通过如下命令获取运行work进程的用户

```nginx
ps aux | grep "nginx: worker process" | awk '{print $1}'
```

2. 修改proxy_temp目录的所有者

```nginx
chown -R nginx:nginx /etc/nginx/proxy_temp
```









# HTTP Header 详解

HTTP（HyperTextTransferProtocol）即超文本传输协议，目前网页传输的的通用协议。HTTP协议采用了请求/响应模型，浏览器或其他客户端发出请求，服务器给与响应。就整个网络资源传输而言，包括message-header和message-body两部分。首先传递message- header，即**http** **header**消息 **。**http header 消息通常被分为4个部分：general header, request header, response header, entity header。但是这种分法就理解而言，感觉界限不太明确。根据维基百科对http header内容的组织形式，大体分为Request和Response两部分。

## Requests部分

|       Header        |                             解释                             |                          示例                           |
| :-----------------: | :----------------------------------------------------------: | :-----------------------------------------------------: |
|       Accept        |                 指定客户端能够接收的内容类型                 |              Accept: text/plain, text/html              |
|   Accept-Charset    |                 浏览器可以接受的字符编码集。                 |               Accept-Charset: iso-8859-5                |
|   Accept-Encoding   |     指定浏览器可以支持的web服务器返回内容压缩编码类型。      |             Accept-Encoding: compress, gzip             |
|   Accept-Language   |                      浏览器可接受的语言                      |                 Accept-Language: en,zh                  |
|    Accept-Ranges    |           可以请求网页实体的一个或者多个子范围字段           |                  Accept-Ranges: bytes                   |
|    Authorization    |                      HTTP授权的授权证书                      |    Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==    |
|    Cache-Control    |                 指定请求和响应遵循的缓存机制                 |                 Cache-Control: no-cache                 |
|     Connection      |      表示是否需要持久连接。（HTTP 1.1默认进行持久连接）      |                    Connection: close                    |
|       Cookie        | HTTP请求发送时，会把保存在该请求域名下的所有cookie值一起发送给web服务器。 |              Cookie: $Version=1; Skin=new;              |
|   Content-Length    |                        请求的内容长度                        |                   Content-Length: 348                   |
|    Content-Type     |                  请求的与实体对应的MIME信息                  |     Content-Type: application/x-www-form-urlencoded     |
|        Date         |                     请求发送的日期和时间                     |           Date: Tue, 15 Nov 2010 08:12:31 GMT           |
|       Expect        |                    请求的特定的服务器行为                    |                  Expect: 100-continue                   |
|        From         |                    发出请求的用户的Email                     |                  From: user@email.com                   |
|        Host         |                指定请求的服务器的域名和端口号                |                   Host: www.zcmhi.com                   |
|      If-Match       |                只有请求内容与实体相匹配才有效                |      If-Match: “737060cd8c284d8af7ad3082f209582d”       |
|  If-Modified-Since  | 如果请求的部分在指定时间之后被修改则请求成功，未被修改则返回304代码 |    If-Modified-Since: Sat, 29 Oct 2010 19:43:31 GMT     |
|    If-None-Match    | 如果内容未改变返回304代码，参数为服务器先前发送的Etag，与服务器回应的Etag比较判断是否改变 |    If-None-Match: “737060cd8c284d8af7ad3082f209582d”    |
|      If-Range       | 如果实体未改变，服务器发送客户端丢失的部分，否则发送整个实体。参数也为Etag |      If-Range: “737060cd8c284d8af7ad3082f209582d”       |
| If-Unmodified-Since |           只在实体在指定时间之后未被修改才请求成功           |   If-Unmodified-Since: Sat, 29 Oct 2010 19:43:31 GMT    |
|    Max-Forwards     |               限制信息通过代理和网关传送的时间               |                    Max-Forwards: 10                     |
|       Pragma        |                    用来包含实现特定的指令                    |                    Pragma: no-cache                     |
| Proxy-Authorization |                     连接到代理的授权证书                     | Proxy-Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ== |
|        Range        |                 只请求实体的一部分，指定范围                 |                  Range: bytes=500-999                   |
|       Referer       |         先前网页的地址，当前请求网页紧随其后,即来路          |     Referer: http://www.zcmhi.com/archives/71.html      |
|         TE          |   客户端愿意接受的传输编码，并通知服务器接受接受尾加头信息   |               TE: trailers,deflate;q=0.5                |
|       Upgrade       |    向服务器指定某种传输协议以便服务器进行转换（如果支持）    |     Upgrade: HTTP/2.0, SHTTP/1.3, IRC/6.9, RTA/x11      |
|     User-Agent      |            User-Agent的内容包含发出请求的用户信息            |          User-Agent: Mozilla/5.0 (Linux; X11)           |
|         Via         |            通知中间网关或代理服务器地址，通信协议            |       Via: 1.0 fred, 1.1 nowhere.com (Apache/1.1)       |
|       Warning       |                    关于消息实体的警告信息                    |             Warn: 199 Miscellaneous warning             |

## Responses 部分 

|       Header       |                             解释                             |                         示例                          |
| :----------------: | :----------------------------------------------------------: | :---------------------------------------------------: |
|   Accept-Ranges    |      表明服务器是否支持指定范围请求及哪种类型的分段请求      |                 Accept-Ranges: bytes                  |
|        Age         |     从原始服务器到代理缓存形成的估算时间（以秒计，非负）     |                        Age: 12                        |
|       Allow        |        对某网络资源的有效的请求行为，不允许则返回405         |                   Allow: GET, HEAD                    |
|   Cache-Control    |           告诉所有的缓存机制是否可以缓存及哪种类型           |                Cache-Control: no-cache                |
|  Content-Encoding  |            web服务器支持的返回内容压缩编码类型。             |                Content-Encoding: gzip                 |
|  Content-Language  |                         响应体的语言                         |                Content-Language: en,zh                |
|   Content-Length   |                         响应体的长度                         |                  Content-Length: 348                  |
|  Content-Location  |                请求资源可替代的备用的另一地址                |             Content-Location: /index.htm              |
|    Content-MD5     |                     返回资源的MD5校验值                      |         Content-MD5: Q2hlY2sgSW50ZWdyaXR5IQ==         |
|   Content-Range    |                在整个返回体中本部分的字节位置                |        Content-Range: bytes 21010-47021/47022         |
|    Content-Type    |                      返回内容的MIME类型                      |        Content-Type: text/html; charset=utf-8         |
|        Date        |                   原始服务器消息发出的时间                   |          Date: Tue, 15 Nov 2010 08:12:31 GMT          |
|        ETag        |                  请求变量的实体标签的当前值                  |       ETag: “737060cd8c284d8af7ad3082f209582d”        |
|      Expires       |                     响应过期的日期和时间                     |        Expires: Thu, 01 Dec 2010 16:00:00 GMT         |
|   Last-Modified    |                    请求资源的最后修改时间                    |     Last-Modified: Tue, 15 Nov 2010 12:45:26 GMT      |
|      Location      |  用来重定向接收方到非请求URL的位置来完成请求或标识新的资源   |    Location: http://www.zcmhi.com/archives/94.html    |
|       Pragma       |      包括实现特定的指令，它可应用到响应链上的任何接收方      |                   Pragma: no-cache                    |
| Proxy-Authenticate |         它指出认证方案和可应用到代理的该URL上的参数          |               Proxy-Authenticate: Basic               |
|      refresh       | 应用于重定向或一个新的资源被创造，在5秒之后重定向（由网景提出，被大部分浏览器支持） | Refresh: 5; url=http://www.zcmhi.com/archives/94.html |
|    Retry-After     |     如果实体暂时不可取，通知客户端在指定时间之后再次尝试     |                   Retry-After: 120                    |
|       Server       |                      web服务器软件名称                       |     Server: Apache/1.3.27 (Unix) (Red-Hat/Linux)      |
|     Set-Cookie     |                       设置Http Cookie                        |  Set-Cookie: UserID=JohnDoe; Max-Age=3600; Version=1  |
|      Trailer       |               指出头域在分块传输编码的尾部存在               |                 Trailer: Max-Forwards                 |
| Transfer-Encoding  |                         文件传输编码                         |               Transfer-Encoding:chunked               |
|        Vary        |        告诉下游代理是使用缓存响应还是从原始服务器请求        |                        Vary: *                        |
|        Via         |              告知代理客户端响应是通过哪里发送的              |      Via: 1.0 fred, 1.1 nowhere.com (Apache/1.1)      |
|      Warning       |                    警告实体可能存在的问题                    |          Warning: 199 Miscellaneous warning           |
|  WWW-Authenticate  |             表明客户端请求实体应该使用的授权方案             |                WWW-Authenticate: Basic                |





应用案例:

这里列举几个应用场景，下文会针对这几个场景并结合代码进行分析。

1. **proxy_pass + upstream**

```cpp
    upstream foo.example.com {
        server 127.0.0.1:8001;
    }

    server {
        listen       80;
        server_name  localhost;

        location /foo {
            proxy_pass http://foo.example.com;
        }
    }
```

访问http://localhost/foo，proxy模块会将请求转发到127.0.0.1的8001端口上。

2. **只有proxy_pass，没有upstream与resolver**

```cpp
    server {
        listen       80;
        server_name  localhost;

        location /foo {
            proxy_pass http://foo.example.com;
        }
    }
```

实际上是隐式创建了upstream，upstream名字就是[foo.example.com](http://foo.example.com)。upstream模块利用本机设置的DNS服务器（或/etc/hosts），将[foo.example.com](http://foo.example.com)解析成IP，访问http://localhost/foo，proxy模块会将请求转发到解析后的IP上。

如果本机未设置DNS服务器，或者DNS服务器无法解析域名，则nginx启动时会报类似如下错误：

> nginx: [emerg] host not found in upstream "foo.example.com" in /path/nginx/conf/nginx.conf:110

3. **proxy_pass + resolver（变量设置域名）**

```nginx

    server {
        listen       80;
        server_name  localhost;

        resolver 114.114.114.114;
        location /foo {
            set $foo foo.example.com;
            proxy_pass http://$foo;
        }
    }

```

访问http://localhost/foo，nginx会动态利用resolver设置的DNS服务器（本机设置的DNS服务器或/etc/hosts无效），将域名解析成IP，proxy模块会将请求转发到解析后的IP上。

4. **proxy_pass + upstream（显式） + resolver（变量设置域名）**

    upstream foo.example.com {
        server 127.0.0.1:8001;
    }
    
    server {
        listen       80;
        server_name  localhost;
    
        resolver 114.114.114.114;
        location /foo {
            set $foo foo.example.com;
            proxy_pass http://$foo;
        }
    }

访问http://localhost/foo时，upstream模块会优先查找是否有定义upstream后端服务器，如果有定义则直接利用，不再走DNS解析。所以proxy模块会将请求转发到127.0.0.1的8001端口上。

5. **proxy_pass + upstream（隐式） + resolver（变量设置域名）**

    server {
        listen       80;
        server_name  localhost;
    
        resolver 114.114.114.114;
        location /foo {
            set $foo foo.example.com;
            proxy_pass http://$foo;
        }
    
        location /foo2 {
            proxy_pass http://foo.example.com;
        }
    }
location /foo2实际上是隐式定义了upstream foo.example.com，并由本地DNS服务器进行了域名解析，访问http://localhost/foo时，upstream模块会优先查找upstream，即隐式定义的foo.example.com，proxy模块会将请求转发到解析后的IP上。

6. **proxy_pass + resolver（不用变量设置域名）**

```cpp
    server {
        listen       80;
        server_name  localhost;

        resolver 114.114.114.114;
        location /foo {
            proxy_pass http://foo.example.com;
        }
    }
```

不使用变量设置域名，则resolver的设置不起作用，此时相当于场景2，只有proxy_pass的场景。

7. **proxy_pass + upstream + resolver（不用变量设置域名）**

```cpp
    upstream foo.example.com {
        server 127.0.0.1:8001;
    }

    server {
        listen       80;
        server_name  localhost;

        resolver 114.114.114.114;
        location /foo {
            proxy_pass http://foo.example.com;
        }
    }
```

不使用变量设置域名，则resolver的设置不起作用，此时相当于场景1 proxy_pass + upstream。

8. **proxy_pass 直接指定IP加端口号**

```cpp
    server {
        listen       80;
        server_name  localhost;

        location /foo {
            proxy_pass http://127.0.0.1:8001/;
        }
    }
```

实际上是隐式创建了upstream，proxy_pass会将请求转发到127.0.0.1的8001端口上。



**总结**

* **proxy_pass + upstream **，是属于典型的显式创建，也是我们经常用到的方式。
* **只有proxy_pass，没有upstream与resolver** ，属于隐式创建, 通过本地dns解析,将请求转发到上游ip。
* **proxy_pass + resolver（变量设置域名）**，nginx会动态利用resolver设置的DNS服务器（本机设置的DNS服务器或/etc/hosts无效），将域名解析成IP，proxy模块会将请求转发到解析后的IP上。
* **proxy_pass + upstream（显式） + resolver（变量设置域名）**, upstream模块会优先查找是否有定义upstream后端服务器，如果有定义则直接利用，不再走DNS解析。
* **proxy_pass + upstream（隐式） + resolver（变量设置域名）**, 隐式定义了upstream，并由本地DNS服务器进行了域名解析。



