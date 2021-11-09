#!/bin/bash

#!/bin/sh

Green_font_prefix="\033[32m" 
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m" 
Font_color_suffix="\033[0m"

Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

check_sys(){
    if test -f "/etc/redhat-release"; then
        release="centos"
    elif cat /etc/issue | grep -q -E -i "debian"; then
        release="debian"
    elif cat /etc/issue | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    elif cat /proc/version | grep -q -E -i "debian"; then
        release="debian"
    elif cat /proc/version | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    fi
}

install_docker_on_centos() {
    sudo yum update -y
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce
    sudo systemctl enable docker
    sudo systemctl start docker
}

install_docker_on_ubuntu() {    
    sudo apt-get remove -y docker docker-engine docker.io containerd runc
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update -y
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io
    sudo systemctl enable docker
    sudo systemctl start docker
}

install_docker() {
    if test -f "/usr/bin/docker"; then
        echo -e ${Info} "发现Docker，无需安装！"
        return
    fi    
    check_sys
    if test "${release}" = "centos"; then
        install_docker_on_centos
    elif test "${release}" = "ubuntu"; then
	install_docker_on_ubuntu
	return
    else
        echo -e ${Error} "无法在此系统自动安装Docker。请手工安装"
        exit 1
    fi
    
    sudo usermod -aG docker ${USER}
    exec newgrp docker
}

get_info(){
    while :
    do
        read -p $1 _info
        if test ${_info}; then             
            break
        fi
        if test $2; then
            set $_info = $2
            break
        fi
        echo ${Error} "输入错误"
    done
}

####################################
### Install Docker               ###
####################################
install_docker

####################################
### Retrieve Info                ###
####################################
get_info "请输入域名："
domain_name=${_info}
get_info "请输入Trojan口令："
password=${_info}
get_info "请输入v2ray的UUID："
v2ray_client_id=${_info} #$(cat /proc/sys/kernel/random/uuid)
get_info "请输入流媒体解锁DNS（回车确认无流媒体解锁服务）：" "None"
if test _info = "None"
then
    streaming_dns=""
else
    streaming_dns=${_info}
fi

if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    yum install -y bind-utils
    yum install -y dnsmasq
elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
    apt-get update
    apt-get install dnsutils
    apt install -y dnsmasq
elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
    apt-get update
    apt-get install dnsutils
    apt install -y dnsmasq
else
    echo "This script only supports CentOS, Ubuntu and Debian."
    exit 1
fi

if [ $? -eq 0 ]; then
    systemctl enable dnsmasq
    rm -f /etc/resolv.conf
    echo "nameserver 127.0.0.1" > /etc/resolv.conf
    touch /etc/dnsmasq.d/unlock.conf
    echo "server=8.8.8.8" > /etc/dnsmasq.d/unlock.conf
    echo "server=8.8.4.4" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/netflix.com/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/netflix.net/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/nflximg.net/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/nflximg.com/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/nflxvideo.net/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/nflxso.net/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/nflxext.com/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/scdn.co/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/spotify.com/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/spoti.fi/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/hulu.com/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/huluim.com/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/hbo.com/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/hbogoasia.hk/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/hbogo.com/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/hbonow.com/$1" >> /etc/dnsmasq.d/unlock.conf
    echo "server=/hboasia.com/$1" >> /etc/dnsmasq.d/unlock.conf

    systemctl restart dnsmasq
    echo "dnsmasq started successfully"
else
    echo "dnsmasqinstallation failed, Please check the warehouse condition"
fi

### Build dnsmasq
docker build -t dnsmasq --rm --build-arg DNS=${streaming_dns} -f Dockerfile.dnsmasq .
docker run -d --name dnsmasq_instance --restart=always dnsmasq
dns_addr=$(docker exec dnsmasq_instance sh -c "hostname -i")
