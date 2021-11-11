# Install Xray
#!/bin/bash
domain=$(cat /root/domain)
apt install iptables iptables-persistent -y
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion ntpdate -y
ntpdate pool.ntp.org
apt -y install chrony
timedatectl set-ntp true
systemctl enable chronyd && systemctl restart chronyd
systemctl enable chrony && systemctl restart chrony
timedatectl set-timezone Asia/Jakarta
chronyc sourcestats -v
chronyc tracking -v
date
# install Xray
curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s -- install
systemctl restart nginx
systemctl stop nginx
mkdir /dani/xray
mkdir /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --install-cert -d $domain --fullchainpath /dani/xray/xray.crt --keypath /dani/xray/xray.key --ecc
uuid=$(cat /proc/sys/kernel/random/uuid)
wget -qO /usr/local/etc/xray/config.json "https://raw.githubusercontent.com/kor8/volt/beta/modul/xray.json"
wget -qO /etc/nginx/conf.d/${domain}.conf "https://raw.githubusercontent.com/kor8/volt/beta/modul/web.conf"
sed -i "s/xxx/${domain}/g" /etc/nginx/conf.d/${domain}.conf
sed -i "s/x.x.x.x/${ip}/g" /etc/nginx/conf.d/${domain}.conf
wget -qO web.tar.gz "https://github.com/kor8/volt/raw/beta/modul/web.tar.gz"
rm -rf /var/www/html/*
tar xzf web.tar.gz -C /var/www/html
rm -f web.tar.gz
sed -i "6s/^/#/" /etc/nginx/conf.d/${domain}.conf
sed -i "6a\\\troot /var/www/html/;" /etc/nginx/conf.d/${domain}.conf
sed -i "7d" /etc/nginx/conf.d/${domain}.conf
sed -i "6s/#//" /etc/nginx/conf.d/${domain}.conf
chown -R nobody.nogroup /dani/xray/xray.crt
chown -R nobody.nogroup /dani/xray/xray.key
touch /dani/xray/xray-clients.txt
sed -i "s/\tinclude \/etc\/nginx\/sites-enabled\/\*;/\t# include \/etc\/nginx\/sites-enabled\/\*;asd/g" /etc/nginx/nginx.conf
mkdir /etc/systemd/system/nginx.service.d
printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" | tee /etc/systemd/system/nginx.service.d/override.conf
systemctl daemon-reload
systemctl restart nginx
systemctl enable xray
systemctl restart xray

#MENU XRAY
cd /usr/local
wget -O menu-xtls "https://raw.githubusercontent.com/kor8/volt/beta/script2/menu-xray.sh"
chmod +x menu-xtls
cd


