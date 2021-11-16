apt install iptables iptables-persistent -y
systemctl restart netfilter-persistent
systemctl enable netfilter-persistent
netfilter-persistent save
netfilter-persistent reload
apt-get install -y lsb-release gnupg2 wget lsof tar unzip curl libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev jq nginx uuid-runtime
curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s -- install
echo $domain > /usr/local/etc/xray/domain
wget -qO /usr/local/etc/xray/config.json "https://raw.githubusercontent.com/kor8/volt/beta/modul/xray.json"
wget -qO /etc/nginx/conf.d/${domain}.conf "https://raw.githubusercontent.com/kor8/volt/beta/modul/web.conf"
sed -i "s/xxx/${domain}/g" /etc/nginx/conf.d/${domain}.conf
wget -qO web.tar.gz "https://raw.githubusercontent.com/kor8/volt/beta/modul/web.tar.gz"
rm -rf /var/www/html/*
tar xzf web.tar.gz -C /var/www/html
rm -f web.tar.gz
mkdir /voltnet/xray
curl -L get.acme.sh | bash
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
sed -i "6s/^/#/" /etc/nginx/conf.d/${domain}.conf
sed -i "6a\\\troot /var/www/html/;" /etc/nginx/conf.d/${domain}.conf
systemctl restart nginx
/root/.acme.sh/acme.sh --issue -d "${domain}" --webroot "/var/www/html/" -k ec-256 --force
/root/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /voltnet/xray/xray.crt --keypath /voltnet/xray/xray.key --reloadcmd "systemctl restart xray" --ecc --force
sed -i "7d" /etc/nginx/conf.d/${domain}.conf
sed -i "6s/#//" /etc/nginx/conf.d/${domain}.conf
chown -R nobody.nogroup /voltnet/xray/xray.crt
chown -R nobody.nogroup /voltnet/xray/xray.key
touch /iriszz/xray/xray-clients.txt
sed -i "s/\tinclude \/etc\/nginx\/sites-enabled\/\*;/\t# include \/etc\/nginx\/sites-enabled\/\*;asd/g" /etc/nginx/nginx.conf
mkdir /etc/systemd/system/nginx.service.d
printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" | tee /etc/systemd/system/nginx.service.d/override.conf
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 443 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload
systemctl daemon-reload
systemctl restart nginx
systemctl restart xray

cd /usr/bin/
wget -O menu-xtls "https://raw.githubusercontent.com/kor8/volt/beta/script2/menu-xray.sh"
chmod +x menu-xtls
