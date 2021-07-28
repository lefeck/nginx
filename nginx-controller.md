# NGINX控制器

## 技术要求

### 支持版本

NGINX Controller v3支持以下发行版和体系结构：

- CentOS 7（x86_64）
- Debian 9（x86_64）
- Readhat Linux 7（x86_64）与NGINX Controller 3.5及更高版本一起使用。
- Ubuntu 16.04 LTS（x86_64）
- Ubuntu 18.04 LTS（x86_64）

### 硬件要求

NGINX Controller v3需要以下最低硬件规格：

- 内存：8 GB RAM
- CPU：8核CPU 2.40 GHz
- 磁盘空间：255 GB可用磁盘空间



## 安装NGINX Controller

**离线安装NGINX Controller**

1. 从[MyF5客户门户](https://account.f5.com/myf5)下载NGINX Controller安装程序包。

2. 上传`controller-installer-<version>.tar.gz`程序包到本地ncinstall目录，制作成压缩包

   ```sh
   tar -zcf ncinstall.tar.gz ncinstall
   ```

3. 将`ncinstall.tar.gz` 压缩包上传到机器，解压缩

   ```sh
   tar -zxf ncinstall.tar.gz && cd ncinstall
   ```

4. 运行安装脚本：

   ```bash
   # 执行 ./ncinstall.sh 脚本会提示如下信息, 需要手动更具自己实际情况填写.
   ./ncinstall.sh 
   ....
   + su ncadmin 
     Enabling EPEL repository.
     [sudo] password for ncadmin:  # 输入ncadmin
      Fetching the required packages: bash coreutils curl gawk gettext grep gzip jq less openssl sed tar mount util-linux iptables socat ebtables ethtool iproute conntrack-tools.
      Fetching the required packages: yum-utils.
      Installing Docker CE.
      Fetching the required packages: nfs-utils.
   + su ncadmin -s /bin/bash /home/ncadmin/controller-installer/install.sh
   
    --- This script will install the NGINX Controller system ---
   
       1. Checking for existing installation...
          Install logs will be stored in /var/log/nginx-controller/nginx-controller-install.log
       2. Checking required ports... OK
       3. Attempting to detect your Operating System... Found core
       4. Checking for required tools: grep basename comm sort head openssl dirname cat tee rev sed ps envsubst awk mkdir jq id less tar numfmt gunzip getent base64 yum-plugin-versionlock. All found.
       5. Checking Docker version...
          Docker version 18.09.9, build 039a7df
       6. Config database configuration
          Do you want to use an embedded config DB? [y/n]: y  # 输入y采用内置的数据库
          Provide config DB volume type [local, nfs, aws]: local  # local指数据库的卷也采用本地
       7. Analytics database configuration 
          Provide time series DB volume type [local, nfs, aws]: local # #local指时序数据库依然采用本地
       8. Checking Kubernetes...
          Loading required packages: kubectl
          Checking for required packages: coreutils util-linux iptables socat ebtables ethtool iproute conntrack-tools . All found.
           Installing k8s components. This can take up to 4m0s
          Loading required packages: kubeadm kubernetes-cni cri-tools kubelet
          Loaded image: k8s.gcr.io/kube-apiserver:v1.15.5
          Loaded image: k8s.gcr.io/kube-controller-manager:v1.15.5
          Loaded image: k8s.gcr.io/kube-scheduler:v1.15.5
          Loaded image: k8s.gcr.io/kube-proxy:v1.15.5
          Loaded image: k8s.gcr.io/pause:3.1
          Loaded image: k8s.gcr.io/etcd:3.3.10
          Loaded image: quay.io/coreos/flannel:v0.11.0-amd64
          Completed k8s components installation
       9. Checking resource requirements...
          Warning: Available disk space on node localhost.localdomain: 39GB. The Controller needs at least 80GB of disk space to work effectively.
          Warning: Available CPU cores on all nodes: 4. The Controller needs at least 8 CPU cores to work effectively.
   
   In order to avoid performance issues, consider installing the Controller with the recommended specifications.
   
       10. End User License Agreement 
           END USER LICENSE AGREEMENT
   
   DOC-0355-13
   
   IMPORTANT - READ BEFORE INSTALLING OR OPERATING THIS PRODUCT
   
   YOU AGREE TO BE BOUND BY THE TERMS OF THIS AGREEMENT BY INSTALLING, HAVING 
   INSTALLED, COPYING, OR OTHERWISE USING THE PRODUCT.  IF YOU DO NOT AGREE, DO NOT 
   INSTALL OR USE THE PRODUCT.
   
   Use the Up/Down arrows to scroll, q to quit. End User License Agreement # 按q退出阅读
   Do you accept this End User License Agreement [y/n] y # y接受license 
   
       11. Loading Docker images...
           [sudo] password for ncadmin: 
           Loaded image: controller-analytics/analytics-mgr:0.220.2-310332907.release-3-18
           Loaded image: controller-analytics/clickhouse-secured-migrations:0.220.2-310332907.release-3-18
           Loaded image: controller-backend/controller-init:3.18.0-316403047
           Loaded image: controller-installer/postgres:3.18.0-316472213
           Loaded image: vault:1.2.2
           Loaded image: controller-installer/nginx-init:3.18.0-316472213
           Loaded image: controller-infra/secrets:0.2.12
           Loaded image: controller-analytics/db-rollup-job:0.220.2-310332907.release-3-18
           Loaded image: nats/nats-streaming:0.1.1
           Loaded image: nats/nats:0.0.6
           Loaded image: nats/tls-proxy:0.0.5
           Loaded image: controller-analytics/db-consumer:0.220.2-310332907.release-3-18
           Loaded image: controller-installer/apigw:3.18.0-316472213
           Loaded image: metallb/speaker:v0.9.5
           Loaded image: controller-backend/controller-prod:3.18.0-316403047
           Loaded image: metallb/controller:v0.9.5
           Loaded image: vault-startup/vault-startup:0.3.0
           Loaded image: controller-analytics/events:0.220.2-310332907.release-3-18
           Loaded image: controller-backend/controller-cron:3.18.0-316403047
           Loaded image: controller-backend/controller-openapi-engine:3.18.0-316403047
           Loaded image: controller-data-plane/declarative-ext-api:0.137.0-307494645.release-3-18
           Loaded image: controller-infra/cloud-mgr:0.42.8
           Loaded image: controller-analytics/catalogs:0.220.2-310332907.release-3-18
           Loaded image: nats/stan-proxy:0.0.39
           Loaded image: certificate-container/certificate-container:0.5.8-306906720.release-3-18
           Loaded image: controller-analytics/forwarder-manager:0.220.2-310332907.release-3-18
           Loaded image: controller-analytics/metrics:0.220.2-310332907.release-3-18
       12. SMTP settings 
           Provide the SMTP host: 192.168.10.192 # smtp ip 地址
           Provide the SMTP port: 25             # smtp 端口
           Use SMTP authentication? [y/n]: n # n 不启用 smtp 认证
           Use TLS for SMTP communication? [y/n]: n                  #  n 不配置 smtp ssl证书
           Provide a do-not-reply email address: admin@localhost.com # do-not-reply email 地址
       13. Admin user configuration 
           Agents and Users use the FQDN to connect to the Controller
           Provide the FQDN for your Controller: www.ngxcontroller.com # 配置dns域名, 确保能被解析到, 如果写本地hosts只是临时解决方案
           rovide the admin's first name: tuner                   #名字
           Provide the admin's last name: zhang                   # 姓氏
           Provide the admin's email address: admin@localhost.com # 管理员邮件地址
           [sudo] password for ncadmin: # 输入密码ncadmin
           Provide the admin's password. Passwords must be 8 to 64 characters, and must include letters and digits: # 输入管理员登录的密码
           Repeat password:  再次输入管理员登录的密码
       14. Checking HTTPS certificates... 
           An SSL/TLS cert and key location for HTTPS was not supplied by the --apigw-cert and --apigw-key flags 
           to install.sh invocation or through the CTR_APIGW_CERT and CTR_APIGW_KEY environment vars. There is no cert/key pair 
           at /opt/nginx-controller/certs/controller/server.crt (and server.key) either. 
           This certificate is required to establish a TLS connection between NGINX Controller 
           and your web browser or agents.
           If you choose not to generate a self-signed certificate, 
           you will be prompted to provide the path to your certificate and key files.
            WARNING: Generating a self-signed certificate is not recommended for production systems.
            Would you like to generate a self-signed certificate now? [y/n]? y # y 生成本地自签证书
           Generating a 4096 bit RSA private key
           ...++
           ................................................................................................++
           writing new private key to '/home/ncadmin/controller-installer/files/k8s/base/certs/controller/server.key'
   
   -----
   
     15. Generating password and session salts... OK.
         NGINX Controller is using a local for the configuration and/or analytics database
         and cannot be configured as a resilient cluster. To configure NGINX Controller
         as a resilient cluster, use external volumes for the analytics and config databases.
         For more information, refer to
         https://docs.nginx.com/nginx-controller/admin-guides/install/resilient-cluster-private-cloud/.
     16. Initializing the database...
         The NGINX Controller database has been initialized.
   
     17. Starting the NGINX Controller stack...
         NGINX Controller services are ready.
          OK, everything went just fine!
          Thank you for installing NGINX Controller.
          You can find your installation in /opt/nginx-controller.
          You can find the install log file in /var/log/nginx-controller/nginx-controller-install.log.
          Access the system using your web browser at https://www.ngxcontroller.com.
          Documentation is available at https://www.ngxcontroller.com/docs/.
   
    Warning!
    NGINX Controller will create a backup of your cluster configuration and encryption keys.
    You’ll need this backup if you ever need to restore the NGINX config database on top of a new NGINX Controller installation.
    You should store this backup in a secure location.
    Backup file: /opt/nginx-controller/cluster-backup/cluster-config-backup-28-07-2021.tgz
    ....
   ```


5. 命令行登录到安装NGINX Controller机器，执行如下操作:

```sh
# kubectl  edit svc apigw  -o yaml 
type: NodePort
```

6. web登录

浏览器输入https://www.ngxcontroller.com或https://ip，输入之前填写的邮箱和密码，即可登录



## 添加license

将license添加到NGINX Controller，请执行以下步骤：

1. 转到`https://<Controller-FQDN>/platform/license`并登录。
2. 在**上载许可证**部分中，选择一个上载选项：
   - **上载许可证文件**–在文件资源管理器中找到并选择您的许可证文件。
   - **粘贴您的协会令牌或许可证文件**–粘贴您的客户协会令牌或NGINX Controller许可证文件的内容。这些在[MyF5客户门户](https://account.f5.com/myf5)上可用。
3. 选择**保存许可证**。



## 安装NGINX Plus

### 先决条件

- 确保查看《[NGINX Plus技术规范指南》](https://docs.nginx.com/nginx/technical-specs/)以了解您的发行要求和所需的配置。
- 您需要注册试用许可证时提供的NGINX Plus证书和公共密钥文件（`nginx-repo.crt`和`nginx-repo.key`）。如果没有这些文件，则可以使用[NGINX Controller REST API](https://docs.nginx.com/nginx-controller/api/api-reference/)来下载它们。

#### 如何使用NGINX控制器API下载NGINX Plus证书和密钥

NGINX Controller API使用会话cookie来验证请求。会话cookie被返回以响应`GET /api/v1/platform/login`请求。有关会话cookie超时和无效的信息，请参阅[API参考](https://docs.nginx.com/nginx-controller/api/api-reference/)文档中的Login端点。

> **提示：**
> 您可以向登录端点发送GET请求以查找会话令牌的状态。

例如：

- 登录并捕获会话cookie：

  ```fallback
  curl -c cookie.txt -X POST --url 'https://198.51.100.10/api/v1/platform/login' --header 'Content-Type: application/json' --data '{"credentials": {"type": "BASIC","username": "arthur@arthurdent.net","password": "Towel$123"}}'
  ```

- 使用会话cookie进行身份验证并获取会话状态：

  ```fallback
  curl -b cookie.txt -c cookie.txt -X GET --url 'https://198.51.100.10/api/v1/platform/login'
  ```



要使用NGINX Controller API将您的NGINX Plus证书和密钥捆绑下载为gzip或JSON文件，请向`/platform/licenses/nginx-plus-licenses/controller-provided`端点发送GET请求。

例如：

```bash
curl -b cookie.txt -c cookie.txt -X GET --url 'https://192.0.2.0
/api/v1/platform/licenses/nginx-plus-licenses/controller-provided' --output nginx-plus-certs.gz
```

### 脚步

要安装NGINX Plus，请按照《[NGINX Plus安装指南》中](https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-plus/)的说明进行操作。请参阅相关部分以进行分配。



## 将NGINX Plus实例添加到NGINX控制器

采取以下步骤将现有实例添加到NGINX Controller：

1. 打开NGINX Controller用户界面并登录。
2. 选择NGINX Controller菜单图标，然后选择**Infrastructure**。
3. 在**基础结构**菜单上，选择**实例**。
4. 在“**实例**概述”页面上，选择“**创建”**以添加实例。
5. 在“**创建实例”**页面上，选择**添加现有实例**。
6. 为实例添加名称。如果不提供名称，则默认使用实例的主机名。
7. 要将实例添加到现有位置，请从列表中选择一个位置。或选择**新建**以创建位置。
8. （可选）默认情况下，NGINX Plus 实例的注册是通过安全连接执行的。要将自签名证书与控制器代理一起使用，请选择**Allow insecure server connections to NGINX Controller using TLS**。出于安全目的，我们建议您尽可能使用签名证书保护控制器代理。
9. 使用 SSH 连接并登录要连接到 NGINX Controller 的 NGINX 实例。
10. 在 NGINX 实例上运行**安装说明**部分中显示的`curl`or`wget`命令以下载并安装控制器代理包。指定后，脚本的和选项分别指实



## 删除nginx实例

**注意：**
		在删除实例之前，请确保先卸载Controller Agent。如果您不先卸载Controller Agent，则实例在删除后可能会重新出现在NGINX Controller中。

移除` nginx-controller-agent`在NGINX Plus实例上运行命令以卸载Controller Agent

```bash
yum remove nginx-controller-agent -y 
```

还原安装的权限：

```bash
sudo semodule -r nginx
```

删除以下文件：

- `nginx.te`
- `nginx.mod`
- `nginx.pp`

## 启动和停止controller-agent

```bash
service controller-agent start
service controller-agent stop
service controller-agent restart
```



## 验证代理状态

验证NGINX代理控制器是否启动：agent会监听514端口

```bash
$ service controller-agent status
$ ps ax | grep -i 'controller\-'
2552 ?        S      0:00 controller-agent
```

当状态不是running说明有问题, 用命令看日志:

```
tail -f /var/log/nginx-controller/agent.log
```



### 管理NGINX Controller

```sh
# view  NGINX Controller version
/opt/nginx-controller/helper.sh version

#Start, Stop, and Restart NGINX Controller
/opt/nginx-controller/helper.sh controller start
/opt/nginx-controller/helper.sh controller stop
/opt/nginx-controller/helper.sh controller restart
/opt/nginx-controller/helper.sh controller status
```



# 配置NGINX Controller服务



NGINX Controller分为四个顶级区域：

- **分析**：启用NGINX Controller的数据可视化。
- **基础架构**：管理NGINX Plus实例以及运行NGINX Controller和NGINX Plus实例的主机的某些方面。
- **平台**：管理NGINX控制器的选项和配置，包括用户，角色，许可证和全局设置。
- **服务**：管理应用程序和API。

下图说明了服务级别上的不同对象如何相互关联：

1. 所有服务对象都是环境的一部分。

2. 网关和证书可以在环境级别或组件级别定义。下图显示了流量如何通过网关流向应用程序的示例。

3. 组件是代表托管您的应用程序或API的后端服务器的子对象。

   > **注意：**
   > 组件可以代表应用程序**或**API。相同的组件不能同时用于App Delivery和API Management。

4. 可以将证书添加到网关或单个组件。



![该图显示了服务区域内环境中对象的关系。](https://docs.nginx.com/nginx-controller/img/services-object-model-example.png)

![示例流量通过网关流向代表后端应用程序的应用程序组件。 可以在网关或应用程序组件级别配置证书。](https://docs.nginx.com/nginx-controller/img/traffic-flow-example-1.png)



## 共同资源

就像在NGINX控制器体系结构中一样，这些文档的“**服务”**部分包含使用NGINX控制器部署和管理应用程序和API所需的信息。但是，在任何团队可以部署应用程序或发布API之前，NGINX Controller管理员需要创建使两者都可行的公共资源。

以下是任何NGINX控制器服务的基本构建块：

1. [环境在](https://docs.nginx.com/nginx-controller/services/setup/manage-environments/)逻辑上将所有其他Service对象分组。您可以使用[访问管理](https://docs.nginx.com/nginx-controller/platform/access-management/)向用户或用户组授予访问特定环境中资源的权限。
2. [证书](https://docs.nginx.com/nginx-controller/services/setup/manage-certs/)可用于保护往返于API和应用程序的流量。
3. [网关](https://docs.nginx.com/nginx-controller/services/setup/manage-gateways/)定义如何处理传入（传入）和传出（出口）流量。
4. [身份提供者](https://docs.nginx.com/nginx-controller/services/setup/manage-identity-providers/)定义使用者如何对您组织的API进行身份验证。

这些共享资源到位后，您组织中的团队就可以创建管理应用程序或发布API所需的资源。





# 配置 Environments

* 由一组apps，gateway和certs组成的域。比如：常见的"develop"和"produce"等。



# 管理 Apps&Components

* component --> location配置段,包括proxy_pass和upstream配置信息

## 1. 创建 App



## 2. 创建 Component

### 生成 Configuration

component类型:

- Web
- TCP/UDP

Component命名: 名称



### 配置URIs

**Web`(七层)`**

- URI格式: `<schema://host>[:port][/path]`，或者相对路径`</path>[/...]`。

**示例：**

	http://www.f5.com:8080/sales
	http://*.f5.com:5050/test
	/images
	/*.jpg
	/locations/us/wa*
**TCP/UDP `(四层)`**

* URI格式: `<tcp|udp|tcp+tls://*|IP:port|portRange>`

**示例：**

```
tcp://192.168.1.1:12345
tcp+tls://192.168.1.1:12346
tcp://192.168.1.1:12345-12350
tcp://*:12345
udp://192.168.1.1:12345
udp://*:12345
```



### 配置Workload Groups

* 提供工作负载组名称。
* 定义后端工作负载URI。
* （可选）定义DNS服务器。
* （可选）选择负载均衡方法。默认值为“ Round Robin”。
* （可选）选择会话持久性类型。
* （可选）选择所需的代理设置。

### 配置Ingress

* 选择支持的HTTP方法。

* 设置"Client Max Body Size"。



### 配置Monitoring

* 启用监控。默认情况下，运行状况监控是禁用的
* 指定要在运行状况检查请求中使用的URI（仅适用于Web组件）。默认值为`/`。对于TCP / UDP组件，指定发送字符串。
* 指定连接到服务器以执行运行状况检查时要使用的端口。默认情况下使用服务器端口。
* 两次连续运行状况检查之间等待的间隔。默认值为5秒。
* 健康检查的次数，服务器才能被视为运行状况良好。预设值为1。
* 健康检查多少次, 服务器被认为不正常。预设值为1。
* 指定服务器的默认状态。默认状态为`HEALTHY`。
* 指定要匹配的起始HTTP状态代码（仅适用于Web组件）。
* 指定要匹配的结尾HTTP状态代码（仅适用于Web组件）。
* 选择是否通过响应以使运行状况检查通过（仅适用于Web组件）。默认情况下，响应应带有状态码`2xx`或`3xx`。



### 配置Security

* 选择“**启用Web应用程序防火墙（WAF）”**以监视或阻止可疑请求或攻击。
* 选择“**仅监视”**以允许流量通过而不会被拒绝。仍然会生成安全事件，并且仍会收集度量。
* 您要WAF忽略的签名。您可以将多个签名指定为以逗号分隔的列表。



### 配置Errors and Logs

启用log日志功能:

- Error Log
- Access Log

指定日志格式:



# 配置 Gateways

* gateway就是nginx实例相关的配置, server配置段的内容

## 创建gateway

### 配置configure

1. 网关的名称。

1. （可选）提供显示名称。
2. （可选）提供描述。
3. （可选）添加任何所需的标签。
4. （可选）选择错误响应格式。
5. 选择将包含网关资源的环境

### 配置Placements

* 选择要部署的NGINX实例。
* 添加NGINX实例的IP地址。



### 配置Hostnames

主机名URI格式。包括协议和端口（如果非标准）：

- `http://<fqdn>`
- `https//<fqdn>`
- `http://<fqdn>:<port>`
- `https://<fqdn>:<port>`
- `tcp[+tls]://<fqdn>:<port>`
- `udp://<fqdn>:<port>`

**Shared TLS Settings**

* （可选）在"Cert Reference"列表中，选择要添加的证书，或选择"**新建**"添加证书。



### 配置Request Methods

* 请求使用的HTTP方法



### 配置Advanced

1. （可选）在“**接收缓冲区大小”**框中，设置用于读取客户端请求的缓冲区大小。默认缓冲区大小为16k。
2. （可选）在“**发送缓冲区大小”**框中，设置用于读取磁盘响应的缓冲区大小。默认缓冲区大小为32k。
3. （可选）在“**客户端最大**正文**大小”**框中，设置在`Content-Length`请求标头字段中指定的客户端请求正文允许的最大大小。默认的最大主体大小为1 MB。
4. （可选）选择“**允许**标头中使用下划线”切换以允许在客户端请求标头字段中使用下划线。设置为禁用（默认设置）时，名称包含下划线的请求标头将被视为无效并且将被忽略。
5. （可选）选择**"允许TCP长连接"**切换以配置“保持活动”探针的空闲，间隔和计数设置。



# 配置Identity Providers

### 启用API身份验证为NGINX Plus实例

如果将API密钥身份验证用于NGINX控制器，必须`njs`在所有NGINX Plus实例上安装该模块。

Centos 系统使用如下命令:

```
yum -y install nginx-plus-module-njs
```

在nginx.conf文件中,添加如下配置:

```
load_module modules/ngx_http_js_module.so;
load_module modules/ngx_stream_js_module.so;
```

重新加载配置:

```
nginx -t && nginx -s reload
```



### 添加Identity Provider

请执行以下步骤来创建身份提供者：

1. 打开NGINX Controller用户界面并登录。

2. 选择NGINX控制器菜单图标，然后选择**服务**。

3. 在“**服务”**菜单上，选择“**身份提供者”**。

4. 在“**身份提供者”**页面上，选择**创建身份提供者**。

5. 提供一个名字。

6. 选择一个环境。

7. 选择使用**API密钥**或**JWT**（JSON Web令牌）的选项。

   **API密钥**：

   - 选择**导入**以上传`.csv`包含客户端名称和密钥的文件。

   - 选择“**创建客户端”**并提供**客户端**名称。您可以使用系统生成的密钥，也可以提供自己的密钥。

   **JWT**：

   通过选择以下选项之一来创建新的JWT客户组：

   - 将`.jwk`文件内容粘贴到文本框中
   - 提供`.jwk`文件位置的URL 。NGINX控制器获取URL，对其进行缓存，然后每12小时刷新一次缓存。如果无法刷新缓存，`.jwk`则使用的先前版本。

8. 选择**创建**。