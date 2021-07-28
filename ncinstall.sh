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
BasePath=$(cd `dirname $0`; pwd)

USER="ncadmin"
PASSWD="ncadmin"
USER_HOME="/home/$USER/"
NC_USER_HOME="/home/ncadmin/controller-installer"


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
    # disable firewall
    systemctl stop firewalld
    systemctl disable firewalld
    # disable swap parttion
    swapoff -a

    grep "nginxcontroller" /etc/hosts || echo "192.168.10.193 www.nginxcontroller.com" >> /etc/hosts

    #configure ssh
    cat /etc/ssh/sshd_config | grep "UseDNS no" || {
        sed -i '/#VersionAddendum none/a\UseDNS no' /etc/ssh/sshd_config
        log_info "disabled ssh reverse domain name resolution"
    }
    sed -i "s/GSSAPIAuthentication yes/GSSAPIAuthentication no/g" /etc/ssh/sshd_config
    systemctl restart sshd
}

function install_pkg() {
    ${BasePath}
    yum -y localinstall pkg/*
    fn_log "Load the installation package"
    systemctl start docker; systemctl enable docker
    fn_log "start docker"
}


function add_ncuser() {
    id $USER >& /dev/null
    if [ $? -eq 0 ];then
        log_info "$USER is exist."
    else
       useradd $USER
       fn_log "Add user $USER"
    fi
    echo $PASSWD | passwd $USER --stdin  &>/dev/null
    fn_log "Add password to $USER"
    chmod 777 /etc/sudoers
    cat /etc/sudoers | grep "$USER"
    if [ $? -eq 0 ]; then
       echo  -e "\033[32m $USER is exist \033[0m" 
       log_info "Allow $USER user to execute any command under any path already exists"
    else
       sed -i '/^root/a\ncadmin    ALL=(ALL)    ALL' /etc/sudoers
       fn_log "Set allow $USER to run any commands anywhere"
    fi   
    chmod 440 /etc/sudoers
}

# Deployment controller-installer 
function install_nc() {
    ${BasePath}
    tar xf controller-installer*.tar
    cp -r controller-installer $USER_HOME
    fn_log "copy data to $USER_HOME"
    chown -R $USER:$USER  $USER_HOME

    su $USER << EOF 
    $NC_USER_HOME/helper.sh  prereqs 
EOF
    fn_log "Pre-installation dependencies"

    su $USER -s /bin/bash $NC_USER_HOME/install.sh 
    fn_log "ginx_controller install" 

    cat /root/.bash_profile | grep "KUBECONFIG" || {
    echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /root/.bash_profile
    source /root/.bash_profile
    }
    # Check that the cluster state is normal
    while true; do
    kubectl get cs | grep "Healthy"
    if [ $? = 0 ]; then
      log_info "the kubernetes cluster is Healthy"
      break
    fi
    done
}

function main() {
    log_trap
    os_prechecks
    add_ncuser
    install_pkg
    install_nc
}

main
