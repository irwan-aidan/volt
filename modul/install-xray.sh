# Install Xray
	apt-get install -y lsb-release gnupg2 wget lsof tar unzip curl libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev jq nginx uuid-runtime
	curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s -- install
	echo $domain > /usr/local/etc/xray/domain
	wget -qO /usr/local/etc/xray/config.json "https://raw.githubusercontent.com/akuhaa021/autoscript/main/FILES/xray/xray.json"
	wget -qO /etc/nginx/conf.d/${domain}.conf "https://raw.githubusercontent.com/akuhaa021/autoscript/main/FILES/xray/web.conf"
	sed -i "s/xxx/${domain}/g" /etc/nginx/conf.d/${domain}.conf
	sed -i "s/x.x.x.x/${ip}/g" /etc/nginx/conf.d/${domain}.conf
	wget -qO web.tar.gz "https://raw.githubusercontent.com/akuhaa021/autoscript/main/FILES/web.tar.gz"
	rm -rf /var/www/html/*
	tar xzf web.tar.gz -C /var/www/html
	rm -f web.tar.gz
	mkdir /donb/xray
	curl -L get.acme.sh | bash
	/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
	sed -i "6s/^/#/" /etc/nginx/conf.d/${domain}.conf
	sed -i "6a\\\troot /var/www/html/;" /etc/nginx/conf.d/${domain}.conf
	systemctl restart nginx
	/root/.acme.sh/acme.sh --issue -d "${domain}" --webroot "/var/www/html/" -k ec-256 --force
	/root/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /donb/xray/xray.crt --keypath /donb/xray/xray.key --reloadcmd "systemctl restart xray" --ecc --force
	sed -i "7d" /etc/nginx/conf.d/${domain}.conf
	sed -i "6s/#//" /etc/nginx/conf.d/${domain}.conf
	chown -R nobody.nogroup /donb/xray/xray.crt
	chown -R nobody.nogroup /donb/xray/xray.key
	touch /donb/xray/xray-clients.txt
	sed -i "s/\tinclude \/etc\/nginx\/sites-enabled\/\*;/\t# include \/etc\/nginx\/sites-enabled\/\*;asd/g" /etc/nginx/nginx.conf
	mkdir /etc/systemd/system/nginx.service.d
	printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" | tee /etc/systemd/system/nginx.service.d/override.conf
	systemctl daemon-reload
	systemctl restart nginx
	systemctl restart xray
elif [[ "$variant" == 2 ]]; then
	# Install V2Ray
	apt-get install -y jq uuid-runtime socat
	bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
	echo $domain > /usr/local/etc/v2ray/domain
	wget -qO /usr/local/etc/v2ray/ws-tls.json "https://raw.githubusercontent.com/akuhaa021/autoscript/main/FILES/v2ray/v2ray-ws-tls.json"
	wget -qO /usr/local/etc/v2ray/ws.json "https://raw.githubusercontent.com/akuhaa021/autoscript/main/FILES/v2ray/v2ray-ws.json"
	sed -i "s/xx/${domain}/g" /usr/local/etc/v2ray/ws-tls.json
	sed -i "s/xx/${domain}/g" /usr/local/etc/v2ray/ws.json
	mkdir /donb/v2ray
	curl -L get.acme.sh | bash
	/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
	/root/.acme.sh/acme.sh --issue -d "${domain}" --standalone -k ec-256 --force
	/root/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /donb/v2ray/v2ray.crt --keypath /donb/v2ray/v2ray.key --ecc --force
	chown -R nobody.nogroup /donb/v2ray/v2ray.crt
	chown -R nobody.nogroup /donb/v2ray/v2ray.key
	touch /donb/v2ray/v2ray-clients.txt
	systemctl enable v2ray@ws-tls
	systemctl enable v2ray@ws
	systemctl start v2ray@ws-tls
	systemctl start v2ray@ws
