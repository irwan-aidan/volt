#!/bin/bash
source /usr/local/sbin/base-script
#Menu VPN
merah="\e[1;31m"
kuning="\e[1;33m"
biru="\e[1;34m"
putih="\e[1;37m"
cyan="\e[1;36m"
clear
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "\E[41;1;30m           MENU VPN              \E[0m"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "\E[44;1;37m           SSH/OVPN            \E[0m"
echo -e "$merah 1$putih. Create $biru(New ID)"
echo -e "$merah 2$putih. Create Random $biru(Random ID)"
echo -e "$merah 3$putih. Create Trial $biru(Trial ID)"
echo -e "$merah 4$putih. User List $biru(User Created)"
echo -e "$merah 5$putih. User Details $biru(Show Detail ID)"
echo -e "$merah 6$putih. User Extend $biru(Extend ID)"
echo -e "$merah 7$putih. User Delete $biru(Delete ID)"
echo -e "$merah 8$putih. User Lock $biru(Lock ID)"
echo -e "$merah 9$putih. User Unlock $biru(Unlock ID)"
echo -e "$merah 10$putih. Connections $biru(Show Login ID)"
echo -e "$merah 11$putih. Delete Expired $biru(Delete Exp ID)"
echo -e "$merah 12$putih. Locked List $biru(Lock List ID)"
echo -e "$merah 13$putih. Exit/Menu $biru(Go Main Menu)"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "\e[46mTo exit the menu press CTRL + C \E[0m"
echo -e "$putih━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\E[0m"
read -rp "  Please Enter The Number [1-12] : " -e Menu-Vpn
echo -e "\n\n"
sleep 1
clear
case $Menu-Vpn in
		1)
		clear
		create
		exit
		;;
		2)
		clear
		create_random
		exit
		;;
		3)
		clear
		create_trial
		exit
		;;
		4)
		clear
		user_list
		exit
		;;
		5)
		clear
		user_details
		exit
		;;
		6)
		clear
		user_extend
		exit
		;;
		7)
		clear
		user_delete
		exit
		;;
		8)
		clear
		user_lock
		exit
		;;
		9)
		clear
		user_unlock
		exit
		;;
		10)
		clear
		connections
		exit
		;;
		11)
		clear
		delete_expired
		exit
		;;
		12)
		clear
		locked_list
		exit
		;;
		13)
		clear
		menu
		exit
		;;
	esac