if [ "${EUID}" -ne 0 ]; then
echo "You need to run this script as root"
exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
echo "OpenVZ is not supported"
exit 1
fi
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- icanhazip.com);
echo "Checking VPS"
IZIN=$( curl http://ipinfo.io/ip | grep $MYIP )
if [ $MYIP = $IZIN ]; then
echo -e "${green}Permintaan Diterima...${NC}"
else
echo -e "${red}Permintaan Ditolak!${NC}";
echo "Hanya untuk pengguna terdaftar"
rm -f installer.sh
exit 0
fi
done
echo -e ""
read -p "Please enter your domain : " domain
echo -e ""
ip=$(wget -qO- ipv4.icanhazip.com)
domain_ip=$(ping "${domain}" -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')
if [[ ${domain_ip} == "${ip}" ]]; then
	echo -e "IP matched with the server. The installation will continue."
	sleep 2
	clear
else
	echo -e "IP does not match with the server. Make sure to point A record to your server."
	echo -e ""
	exit 1
fi
#Install Xray
wget https://raw.githubusercontent.com/kor8/volt/beta/modul/install-xray.sh
chmod +x install-xray.sh
./install-xray.sh
#Install Local Vpn
wget https://raw.githubusercontent.com/kor8/volt/beta/modul/deb10.sh
chmod +x deb10.sh
./deb10.sh 
#Removing Installer File
rm -f /root/install-xray.sh
rm -f /root/deb10.sh
history -c
echo "1.1" > /home/ver
clear
echo " Reboot 10 Sec"
reboot
