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
mkdir /var/lib/premium-script;
echo "Enter the VPS Subdomain Hostname, REQUIRED aka WAJIB"
read -p "Hostname / Domain: " host
echo "IP=$host" >> /var/lib/premium-script/ipvps.conf
wget https://raw.githubusercontent.com/kor8/volt/beta/modul/deb10.sh && chmod +x deb10.sh && ./deb10.sh 
rm -f /root/deb10.sh.sh
history -c
echo "1.1" > /home/ver
clear
echo " Reboot 10 Sec"
