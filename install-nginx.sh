# Compile and install nginx source code
# author wangjinhuai

# Using the operating system centos 7

#!/bin/bash
export PATH=$PATH:/bin:/usr/bin:/usr/local/bin:/usr/sbin


# define variable parameter
NGINX_PATH=/etc/nginx
BIN_PATH="/usr/sbin"
LOG_PATH="/var/log/nginx"
NGINX_USER=nginx
NGINX_GROUP=nginx
NGINX_VERSION="nginx-1.19.1"
NGINX_PCRE_VERSION="pcre-8.40"
NGINX_ZLIB_VERSION="zlib-1.2.11"
NGINX_OPENSSL_VERSION="openssl-1.1.0l"
NGINX_COMPILE_COMMAND="./configure \
--prefix=${NGINX_PATH} \
--sbin-path=${BIN_PATH}/nginx \
--conf-path=${NGINX_PATH}/nginx.conf \
--error-log-path=${LOG_PATH}/error.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/lock/nginx.lock  \
--http-log-path=${LOG_PATH}/access.log \
--http-client-body-temp-path=${NGINX_PATH}/client_temp \
--http-proxy-temp-path=${NGINX_PATH}/proxy_temp \
--http-fastcgi-temp-path=${NGINX_PATH}/fastcgi_temp \
--http-uwsgi-temp-path=${NGINX_PATH}/uwsgi_temp \
--http-scgi-temp-path=${NGINX_PATH}/scgi_temp \
--with-pcre=../${NGINX_PCRE_VERSION} \
--with-openssl=../${NGINX_OPENSSL_VERSION} \
--with-zlib=../${NGINX_ZLIB_VERSION} \
--user=${NGINX_USER} \
--group=${NGINX_GROUP} \
--with-stream \
--with-http_ssl_module \
--with-http_v2_module \
--with-http_gzip_static_module  \
--with-file-aio \
--with-ipv6 \
--with-http_realip_module \
--with-http_gunzip_module \
--with-http_secure_link_module \
--with-debug \
--with-http_stub_status_module"

printf "clear all environments\n"
rm -rf zlib* pcre* nginx*  openssl*
rm -rf /etc/yum.repos.d/epel*

echo "install dependent package"
yum install -y nmap unzip wget lsof xz net-tools gcc make gcc-c++ epel-release ntp

echo "sync ntp"
ntpdate asia.pool.ntp.org
timedatectl set-timezone "Asia/Shanghai"

echo "stop firewalld"
systemctl stop firewalld
systemctl disable firewalld
  
if [[ $(id nginx) = "0" ]]; then
    printf "nginx group and user is exist\n"
else
    groupadd -r nginx
    useradd -r -g nginx -s /bin/false -M nginx
fi

#install zlib package

if [ -f $NGINX_ZLIB_VERSION.tar.gz ]; then
    echo $NGINX_ZLIB_VERSION.tar.gz is exist.
else
    wget -c https://www.zlib.net/$NGINX_ZLIB_VERSION.tar.gz --no-check-certificate
fi
tar zxvf $NGINX_ZLIB_VERSION.tar.gz 
cd $NGINX_ZLIB_VERSION
./configure && make && make install
cd ../

#install pcre package
# the package is not real package instead of it.
if [ -f $NGINX_PCRE_VERSION.tar.gz ]; then
    echo $NGINX_PCRE_VERSION.tar.gz is exist.
else
    wget https://ftp.pcre.org/pub/pcre/${NGINX_PCRE_VERSION}.tar.gz --no-check-certificate
fi
tar zxvf $NGINX_PCRE_VERSION.tar.gz 
cd $NGINX_PCRE_VERSION
./configure && make && make install
cd ../

#install openssl and nginx package

if [ -f  $NGINX_OPENSSL_VERSION.tar.gz ]; then
    echo $NGINX_OPENSSL_VERSION.tar.gz is exist.
else
    wget https://www.openssl.org/source/${NGINX_OPENSSL_VERSION}.tar.gz --no-check-certificate
fi

if [ -f  $NGINX_VERSION.tar.gz ]; then
    echo $NGINX_VERSION.tar.gz is exist.
else
    wget -c http://nginx.org/download/$NGINX_VERSION.tar.gz
fi   
tar zxvf $NGINX_OPENSSL_VERSION.tar.gz
tar zxvf $NGINX_VERSION.tar.gz
cd $NGINX_VERSION
useradd nginx -s /sbin/nologin -M
$NGINX_COMPILE_COMMAND
make && make install
cd ../

cat > /usr/lib/systemd/system/nginx.service << EOF
[Unit]
Description=nginx 
After=network.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/bin/rm -f /var/run/nginx.pid
ExecStartPre=${BIN_PATH}/nginx -t
ExecStart=${BIN_PATH}/nginx
ExecReload=${BIN_PATH}/nginx -s reload
ExecStop=${BIN_PATH}/nginx -s stop
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nginx.service
systemctl start nginx.service

ss -tunlp | grep nginx
if [ $? -eq 0 ];then
    echo "install nginx sucessful"
else
    echo "install nginx failed"
    exit 1
fi

