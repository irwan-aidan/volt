# Install Xray
apt-get install -y lsb-release gnupg2 wget lsof tar unzip curl libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev jq nginx uuid-runtime
curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s -- install
echo $domain > /usr/local/etc/xray/domain
wget -qO /usr/local/etc/xray/config.json "https://raw.githubusercontent.com/kor8/volt/beta/modul/xray.json"
wget -qO /etc/nginx/conf.d/${domain}.conf "https://raw.githubusercontent.com/kor8/volt/beta/modul/web.conf"
sed -i "s/xxx/${domain}/g" /etc/nginx/conf.d/${domain}.conf
sed -i "s/x.x.x.x/${ip}/g" /etc/nginx/conf.d/${domain}.conf
wget -qO web.tar.gz "https://github.com/kor8/volt/raw/beta/modul/web.tar.gz"
rm -rf /var/www/html/*
tar xzf web.tar.gz -C /var/www/html
rm -f web.tar.gz
mkdir /dani/xray
mkdir /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
sed -i "6s/^/#/" /etc/nginx/conf.d/${domain}.conf
sed -i "6a\\\troot /var/www/html/;" /etc/nginx/conf.d/${domain}.conf
systemctl restart nginx
systemctl stop nginx
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --install-cert -d $domain --fullchainpath /dani/xray/xray.crt --keypath /dani/xray/xray.key --ecc
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


