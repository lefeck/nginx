#!/bin/bash
# author wangjinhuai

#
# ubuntu/centos installnginx controller of the method
#
# exec shell script file  chmod +x ncinstall.sh && ./ncinstall.sh


# set variable value
DATE_N=`date "+%Y-%m-%d %H:%M:%S"`
USER_N=`whoami`
HOST_NAME=`hostname`
LOGFILE="/var/log/nginx_controller_install.log"

# View the directory where the current script is located
DIR_T="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

USER="ncadmin"
PASSWD="ncadmin"
USER_HOME="/home/$USER/"


# Execution successful log printing path
function log_info () {
    echo "${DATE_N} ${HOST_NAME} ${USER_N} execute $0 [INFO] $@" >> ${LOGFILE}
}

# Execution successful warning log print path
function log_warn () {
    echo "${DATE_N} ${HOST_NAME} ${USER_N} execute $0 [WARN] $@" >> ${LOGFILE} 
}

# Execution failure log print path
function log_error () {
    echo -e "\033[41;37m ${DATE_N} ${HOST_NAME} ${USER_N} execute $0 [ERROR] $@ \033[0m"  >> ${LOGFILE}  
}

function fn_log ()  {
    if [  $? -eq 0  ]
    then
            log_info "$@ sucessed."
            echo -e "\033[32m $@ sucessed. \033[0m"
    else
            log_error "$@ failed."
            echo -e "\033[41;37m $@ failed. \033[0m"
            exit 1
    fi

}

function log_trap() {
    # Disconnect the connection by sending a signal
    trap 'fn_log "DO NOT SEND CTR + C WHEN EXECUTE SCRIPT !!!! "' 2
}



function os_prechecks() {

    # check whether it is root user login
    if [[ $(id -u) != "0" ]]; then
        echo  -e "\033[32m not root user \033[0m"
        log_error "You must be root to run this install script."
        exit 1
    fi
    
    # Check whether it is CentOS/RedHat 7.4 or above version
    if [[ $(grep "release 7." /etc/redhat-release 2>/dev/null | wc -l) -eq 0 ]]; then
        echo  -e "\033[32m Your OS is NOT CentOS 7.4 or above RHEL 7.4 \033[0m"
        log_error "Your OS is NOT CentOS 7.4 or above RHEL 7.4"
        exit 1
    fi

    # disable selinux
    setenforce 0
    sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/selinux/config
    systemctl stop firewalld
    systemctl disable firewalld
    # disable swap parttion
    swapoff -a

    #configure ssh
    ssh=$(cat /etc/ssh/sshd_config | grep "UseDNS no")
    echo ${ssh}
    if [ $? -eq 0 ]; then
        log_info "the sshd configure "UseDNS no" already exists in file "
    else
        sed -i '/#VersionAddendum none/a\UseDNS no' /etc/ssh/sshd_config
    fi
    sed -i "s/GSSAPIAuthentication yes/GSSAPIAuthentication no/g" /etc/ssh/sshd_config
    systemctl restart sshd

}


function add_ncuser() {
    useradd $USER
    echo $PASSWD | passwd $USER --stdin  &>/dev/null
    chmod 777 /etc/sudoers
    ncuser=$(cat /etc/sudoers | grep "$USER")
    echo ${ncuser}
    if [ $? -eq 0 ]; then
       echo  -e "\033[32m $USER is exist \033[0m" 
       log_info "$USER is exist"
    else
       sed -i '/^root /a\ncadmin    ALL=(ALL)    ALL' /etc/sudoers
    fi   
    chmod 440 /etc/sudoers
}


function install_pkg() {
    $DIR_T
    echo  -e "\033[32m offline install nginx controller Utilities \033[0m"
    # offline install nginx controller Utilities
    yum -y localinstall pkg/*; rm -rf pkg*
    fn_log "offline install nginx controller"
}

# Deployment controller-installer 
function install_nc() {
    tar xf controller-installer*.tar &>/dev/null
    cp -r controller-installer /home/ncadmin/
    su - $USER << eof
    cd /home/ncadmin/controller-installer
    ./install.sh -n
eof
}


function main() {
    log_trap
    log_info
    log_warn
    os_prechecks
    add_ncuser
    install_pkg
    install_nc
}

main
