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
IZIN=$( curl (wget -qO- icanhazip.com) | grep $MYIP )
if [ $MYIP = $IZIN ]; then
echo -e "${green}Permission Accepted...${NC}"
else
echo -e "${green}Permission Accepted...${NC}"
fi
mkdir /var/lib/premium-script;
echo "Enter the VPS Subdomain Hostname, if not available, please click Enter"
read -p "Hostname / Domain: " host
echo "IP=$host" >> /var/lib/premium-script/ipvps.conf
apt update -y
apt upgrade -y
apt install -y net-tools unzip curl screen
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
