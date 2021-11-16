red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- icanhazip.com);
echo "Checking VPS"
CEK=0123456
if [ "$CEK" != "0123456" ]; then
		echo -e "${red}Permission Denied!${NC}";
        echo $CEK;
        exit 0;
else
echo -e "${green}Permission Accepted...${NC}"
sleep 1
clear
fi
wget https://raw.githubusercontent.com/kor8/volt/beta/modul/exmod.sh
chmod +x exmod.sh
./exmod.sh
rm -f /root/exmod.sh
rm -f /root/installer.sh
