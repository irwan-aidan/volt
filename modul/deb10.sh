#!/bin/bash
# VPS Installer
# Script by Dark
# 

MyScriptName='AlienVpn'

# OpenSSH Ports
SSH_Port1='22'
SSH_Port2='225'

# Your SSH Banner
SSH_Banner='https://raw.githubusercontent.com/kor8/eco/beta/banner'

# Dropbear Ports
Dropbear_Port1='555'
Dropbear_Port2='550'

# Stunnel Ports
Stunnel_Port1='444' # through Dropbear
Stunnel_Port2='445' # through OpenSSH

#Squid Proxy
Proxy_Port1='80'
Proxy_Port2='8000'

# OpenVPN Ports
OpenVPN_Port1='1194'
OpenVPN_Port2='465'
OpenVPN_Port3='2200'
OpenVPN_Port4='2500'

# Privoxy Ports (must be 1024 or higher)
Privoxy_Port1='25800'
# OpenVPN Config Download Port
OvpnDownload_Port='88' # Before changing this value, please read this document. It contains all unsafe ports for Google Chrome Browser, please read from line #23 to line #89: https://chromium.googlesource.com/chromium/src.git/+/refs/heads/master/net/base/port_util.cc

# Server local time
MyVPS_Time='Asia/Kuala_Lumpur'

# initializing var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";
ANU=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID

# go to root
cd

# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Ubah izin akses
chmod +x /etc/rc.local

# enable rc local
systemctl enable rc-local
systemctl start rc-local.service

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

apt-get update
apt-get upgrade -y

apt install fail2ban -y
 
# Removing some firewall tools that may affect other services
apt-get remove --purge ufw firewalld -y
apt-get remove --purge exim4 -y
 
# Installing some important machine essentials
apt-get install nano wget curl zip unzip tar gzip p7zip-full bc rc openssl cron net-tools dnsutils dos2unix screen bzip2 ccrypt -y
 
# Now installing all our wanted services
apt-get install dropbear stunnel4 privoxy ca-certificates nginx ruby apt-transport-https lsb-release squid screenfetch -y
apt install iptables iptables-persistent -y
systemctl restart netfilter-persistent
systemctl enable netfilter-persistent

apt install tuned -y
systemctl enable tuned
systemctl restart tuned
tuned-adm profile throughput-performance

# Installing all required packages to install Webmin
apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python dbus libxml-parser-perl -y
apt-get install shared-mime-info jq -y
 
# Installing a text colorizer
gem install lolcat
# set time GMT +8

# Trying to remove obsolette packages after installation
apt-get autoremove -y

rm -f /etc/localtime
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime
timedatectl set-timezone Asia/Kuala_Lumpur

# NeoFetch
apt-get --reinstall --fix-missing install -y bzip2 gzip coreutils wget screen rsyslog iftop htop net-tools zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr libxml-parser-perl neofetch git lsof -y
chmod +x /usr/bin/screenfetch
echo "clear" >> .profile
echo 'echo '' > /var/log/syslog' >> .profile
echo "neofetch -p -A Android" >> .profile
echo "echo 'DARKNET PREM SCRIPT '" >> .profile
echo "echo 't.me/cyberbossz '" >> .profile

sudo tee /etc/apt/sources.list.d/pritunl.list << EOF
deb http://repo.pritunl.com/stable/apt buster main
EOF
sudo apt-get install dirmngr -y
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
sudo apt-get update -y
sudo apt-get install pritunl-client-electron -y

# Removing some duplicated sshd server configs
rm -f /etc/ssh/sshd_config*
 
# Creating a SSH server config using cat eof tricks
cat <<'MySSHConfig' > /etc/ssh/sshd_config
# My OpenSSH Server config
Port myPORT1
Port myPORT2
AddressFamily inet
ListenAddress 0.0.0.0
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
PermitRootLogin yes
MaxSessions 1024
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
ClientAliveInterval 240
ClientAliveCountMax 2
UseDNS no
Banner /etc/banner
AcceptEnv LANG LC_*
Subsystem   sftp  /usr/lib/openssh/sftp-server
MySSHConfig

# Now we'll put our ssh ports inside of sshd_config
sed -i "s|myPORT1|$SSH_Port1|g" /etc/ssh/sshd_config
sed -i "s|myPORT2|$SSH_Port2|g" /etc/ssh/sshd_config

# Download our SSH Banner
rm -f /etc/banner
wget -qO /etc/banner "$SSH_Banner"
dos2unix -q /etc/banner

# My workaround code to remove `BAD Password error` from passwd command, it will fix password-related error on their ssh accounts.
sed -i '/password\s*requisite\s*pam_cracklib.s.*/d' /etc/pam.d/common-password
sed -i 's/use_authtok //g' /etc/pam.d/common-password

# Some command to identify null shells when you tunnel through SSH or using Stunnel, it will fix user/pass authentication error on HTTP Injector, KPN Tunnel, eProxy, SVI, HTTP Proxy Injector etc ssh/ssl tunneling apps.
sed -i '/\/bin\/false/d' /etc/shells
sed -i '/\/usr\/sbin\/nologin/d' /etc/shells
echo '/bin/false' >> /etc/shells
echo '/usr/sbin/nologin' >> /etc/shells
 
# Restarting openssh service
systemctl restart ssh
 
# Removing some duplicate config file
rm -rf /etc/default/dropbear*
 
# creating dropbear config using cat eof tricks
cat <<'MyDropbear' > /etc/default/dropbear
# My Dropbear Config
NO_START=0
DROPBEAR_PORT=PORT01
DROPBEAR_EXTRA_ARGS="-p PORT02"
DROPBEAR_BANNER="/etc/banner"
DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"
DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"
DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"
DROPBEAR_RECEIVE_WINDOW=65536
MyDropbear

# Now changing our desired dropbear ports
sed -i "s|PORT01|$Dropbear_Port1|g" /etc/default/dropbear
sed -i "s|PORT02|$Dropbear_Port2|g" /etc/default/dropbear
 
# Restarting dropbear service
systemctl restart dropbear

StunnelDir=$(ls /etc/default | grep stunnel | head -n1)

# Creating stunnel startup config using cat eof tricks
cat <<'MyStunnelD' > /etc/default/$StunnelDir
# My Stunnel Config
ENABLED=1
FILES="/etc/stunnel/*.conf"
OPTIONS="/etc/banner"
BANNER="/etc/banner"
PPP_RESTART=0
# RLIMITS="-n 4096 -d unlimited"
RLIMITS=""
MyStunnelD

# Removing all stunnel folder contents
rm -rf /etc/stunnel/*
 
# Creating stunnel certifcate using openssl
openssl req -new -x509 -days 9999 -nodes -subj "/C=MY/ST=NCR/L=Kuala_Lumpur/O=$MyScriptName/OU=$MyScriptName/CN=$MyScriptName" -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem &> /dev/null
##  > /dev/null 2>&1

# Creating stunnel server config
cat <<'MyStunnelC' > /etc/stunnel/stunnel.conf
# My Stunnel Config
pid = /var/run/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
TIMEOUTclose = 0
[dropbear]
accept = Stunnel_Port1
connect = 127.0.0.1:dropbear_port_c
[openssh]
accept = Stunnel_Port2
connect = 127.0.0.1:openssh_port_c
MyStunnelC

# setting stunnel ports
sed -i "s|Stunnel_Port1|$Stunnel_Port1|g" /etc/stunnel/stunnel.conf
sed -i "s|dropbear_port_c|$(netstat -tlnp | grep -i dropbear | awk '{print $4}' | cut -d: -f2 | xargs | awk '{print $2}' | head -n1)|g" /etc/stunnel/stunnel.conf
sed -i "s|Stunnel_Port2|$Stunnel_Port2|g" /etc/stunnel/stunnel.conf
sed -i "s|openssh_port_c|$(netstat -tlnp | grep -i ssh | awk '{print $4}' | cut -d: -f2 | xargs | awk '{print $2}' | head -n1)|g" /etc/stunnel/stunnel.conf

# Restarting stunnel service
systemctl restart $StunnelDir

# Checking if openvpn folder is accidentally deleted or purged
if [[ ! -e /etc/openvpn ]]; then
 mkdir -p /etc/openvpn
fi

# Removing all existing openvpn server files
rm -rf /etc/openvpn/*

# Creating server.conf, ca.crt, server.crt and server.key
cat <<'myOpenVPNconf1' > /etc/openvpn/server_tcp.conf
port MyOvpnPort1
dev tun
proto tcp
ca /etc/openvpn/ca.crt
cert /etc/openvpn/volt.crt
key /etc/openvpn/volt.key
dh /etc/openvpn/dh.pem
duplicate-cn
persist-tun
persist-key
persist-remote-ip
cipher none
ncp-disable
auth none
comp-lzo
tun-mtu 1500
reneg-sec 0
plugin /etc/openvpn/openvpn-auth-pam.so /etc/pam.d/login
verify-client-cert none
username-as-common-name
max-clients 4000
topology subnet
server 192.168.1.0 255.255.255.0
push "redirect-gateway def1"
keepalive 5 60
status /etc/openvpn/tcp_stats.log
log /etc/openvpn/tcp.log
verb 2
script-security 2
socket-flags TCP_NODELAY
push "socket-flags TCP_NODELAY"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
myOpenVPNconf1
cat <<'myOpenVPNconf2' > /etc/openvpn/server_tcp1.conf
port MyOvpnPort2
dev tun
proto tcp
ca /etc/openvpn/ca.crt
cert /etc/openvpn/volt.crt
key /etc/openvpn/volt.key
dh /etc/openvpn/dh.pem
duplicate-cn
persist-tun
persist-key
persist-remote-ip
cipher none
ncp-disable
auth none
comp-lzo
tun-mtu 1500
reneg-sec 0
plugin /etc/openvpn/openvpn-auth-pam.so /etc/pam.d/login
verify-client-cert none
username-as-common-name
max-clients 4000
topology subnet
server 192.168.2.0 255.255.255.0
push "redirect-gateway def1"
keepalive 5 60
status /etc/openvpn/tcp_stats.log
log /etc/openvpn/tcp.log
verb 2
script-security 2
socket-flags TCP_NODELAY
push "socket-flags TCP_NODELAY"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
myOpenVPNconf2
 cat <<'myOpenVPNconf3' > /etc/openvpn/server_udp.conf
port MyOvpnPort3
dev tun
proto udp
ca /etc/openvpn/ca.crt
cert /etc/openvpn/volt.crt
key /etc/openvpn/volt.key
dh /etc/openvpn/dh.pem
duplicate-cn
persist-tun
persist-key
persist-remote-ip
cipher none
ncp-disable
auth none
comp-lzo
tun-mtu 1500
reneg-sec 0
plugin /etc/openvpn/openvpn-auth-pam.so /etc/pam.d/login
verify-client-cert none
username-as-common-name
max-clients 4000
topology subnet
server 192.168.3.0 255.255.255.0
push "redirect-gateway def1"
keepalive 5 60
status /etc/openvpn/tcp_stats.log
log /etc/openvpn/tcp.log
verb 2
script-security 2
socket-flags TCP_NODELAY
push "socket-flags TCP_NODELAY"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
myOpenVPNconf3
 cat <<'myOpenVPNconf4' > /etc/openvpn/server_udp1.conf
port MyOvpnPort4
dev tun
proto udp
ca /etc/openvpn/ca.crt
cert /etc/openvpn/volt.crt
key /etc/openvpn/volt.key
dh /etc/openvpn/dh.pem
duplicate-cn
persist-tun
persist-key
persist-remote-ip
cipher none
ncp-disable
auth none
comp-lzo
tun-mtu 1500
reneg-sec 0
plugin /etc/openvpn/openvpn-auth-pam.so /etc/pam.d/login
verify-client-cert none
username-as-common-name
max-clients 4000
topology subnet
server 192.168.4.0 255.255.255.0
push "redirect-gateway def1"
keepalive 5 60
status /etc/openvpn/tcp_stats.log
log /etc/openvpn/tcp.log
verb 2
script-security 2
socket-flags TCP_NODELAY
push "socket-flags TCP_NODELAY"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
myOpenVPNconf4
cat <<'EOF7'> /etc/openvpn/ca.crt
-----BEGIN CERTIFICATE-----
MIIDxjCCA02gAwIBAgIUHOYpgZtNLLVaLXdqWXPl2wXN7zAwCgYIKoZIzj0EAwIw
gasxCzAJBgNVBAYTAlBIMREwDwYDVQQIDAhCYXRhbmdhczEWMBQGA1UEBwwNQmF0
YW5nYXMgQ2l0eTEXMBUGA1UECgwOR2FtZXJzIFZQTiBIdWIxGTAXBgNVBAsMEFBo
Q29ybmVyLUdWUE5IVUIxFzAVBgNVBAMMDkdWUE5IVUItU2VydmVyMSQwIgYJKoZI
hvcNAQkBFhVpbWFwc3ljaG8yOEBnbWFpbC5jb20wIBcNMjEwMTI4MTM0NTI3WhgP
MjA4MDAzMTkxMzQ1MjdaMIGrMQswCQYDVQQGEwJQSDERMA8GA1UECAwIQmF0YW5n
YXMxFjAUBgNVBAcMDUJhdGFuZ2FzIENpdHkxFzAVBgNVBAoMDkdhbWVycyBWUE4g
SHViMRkwFwYDVQQLDBBQaENvcm5lci1HVlBOSFVCMRcwFQYDVQQDDA5HVlBOSFVC
LVNlcnZlcjEkMCIGCSqGSIb3DQEJARYVaW1hcHN5Y2hvMjhAZ21haWwuY29tMHYw
EAYHKoZIzj0CAQYFK4EEACIDYgAEDY0BO/SRsYYGZy+PKyCf7jruD/Sanr2GrNxC
YQ8vzbUqKvyjP+wIQXBJ//Ba8bOJH3K2dtKh3hzbaDdxzSjCxG9W36YdBCXxbDl8
kWMNjugeNySZ4QgVm5mFEA4r4uEYo4IBLDCCASgwHQYDVR0OBBYEFOxhLQt+r3qA
q173jqObhxF3BnESMIHrBgNVHSMEgeMwgeCAFOxhLQt+r3qAq173jqObhxF3BnES
oYGxpIGuMIGrMQswCQYDVQQGEwJQSDERMA8GA1UECAwIQmF0YW5nYXMxFjAUBgNV
BAcMDUJhdGFuZ2FzIENpdHkxFzAVBgNVBAoMDkdhbWVycyBWUE4gSHViMRkwFwYD
VQQLDBBQaENvcm5lci1HVlBOSFVCMRcwFQYDVQQDDA5HVlBOSFVCLVNlcnZlcjEk
MCIGCSqGSIb3DQEJARYVaW1hcHN5Y2hvMjhAZ21haWwuY29tghQc5imBm00stVot
d2pZc+XbBc3vMDAMBgNVHRMEBTADAQH/MAsGA1UdDwQEAwIBBjAKBggqhkjOPQQD
AgNnADBkAjAlVh2EtpofZcHyTPD6u/GrKCPvSPqdz2+6/ybXuXa+VRGzoTrQ3cRf
VZPAbgSqEskCMHnvJ9Pm/bGbaXQ6pLgYeUBWRr1wWPeXFVs4caKRpSzZC73dKFdZ
Al+0Oxso76FBPg==
-----END CERTIFICATE-----
EOF7
cat <<'EOF9'> /etc/openvpn/volt.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            74:6e:46:3f:6b:45:3e:d4:f2:38:ba:4f:fb:74:31:c8
        Signature Algorithm: ecdsa-with-SHA256
        Issuer: C=PH, ST=Batangas, L=Batangas City, O=Gamers VPN Hub, OU=PhCorner-GVPNHUB, CN=GVPNHUB-Server/emailAddress=imapsycho28@gmail.com
        Validity
            Not Before: Jan 28 13:49:05 2021 GMT
            Not After : Mar 19 13:49:05 2080 GMT
        Subject: C=PH, ST=Batangas, L=Batangas City, O=Gamers VPN Hub, OU=PhCorner-GVPNHUB, CN=GVPNHUB-Server/emailAddress=imapsycho28@gmail.com
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (384 bit)
                pub:
                    04:58:ef:b8:3d:fb:4b:59:26:c4:99:c4:9d:a9:c0:
                    d5:2a:a8:b2:85:8c:c3:8b:bf:c8:c7:05:1a:0b:bb:
                    75:df:91:38:03:6b:a7:be:b5:c4:b9:81:0a:8e:8f:
                    75:63:72:7e:3c:9e:37:12:d8:5c:25:af:0c:25:9c:
                    5d:85:ce:96:91:9f:be:6f:0b:a8:06:a9:ad:18:cf:
                    f9:76:8a:24:10:b4:89:b7:00:9d:72:f8:70:00:8f:
                    de:4b:2e:35:77:cb:b4
                ASN1 OID: secp384r1
                NIST CURVE: P-384
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            X509v3 Subject Key Identifier: 
                03:62:1C:3D:ED:E9:5B:F2:A6:0F:41:37:AD:AE:BB:8A:86:2A:E1:12
            X509v3 Authority Key Identifier: 
                keyid:EC:61:2D:0B:7E:AF:7A:80:AB:5E:F7:8E:A3:9B:87:11:77:06:71:12
                DirName:/C=PH/ST=Batangas/L=Batangas City/O=Gamers VPN Hub/OU=PhCorner-GVPNHUB/CN=GVPNHUB-Server/emailAddress=imapsycho28@gmail.com
                serial:1C:E6:29:81:9B:4D:2C:B5:5A:2D:77:6A:59:73:E5:DB:05:CD:EF:30
            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
            X509v3 Key Usage: 
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name: 
                DNS:GVPNHUB-Server
    Signature Algorithm: ecdsa-with-SHA256
         30:65:02:31:00:ea:63:07:9e:9f:ae:0a:bf:0e:c7:07:bc:e4:
         68:83:ea:5f:1a:af:11:f0:ef:47:a7:c7:42:eb:cd:d2:9e:76:
         00:9c:34:f7:aa:23:f9:2d:c3:39:a5:9a:19:a0:dc:32:f2:02:
         30:16:f9:d9:0d:46:e9:b4:f3:1a:18:e1:36:f3:e6:62:8c:2f:
         a5:77:30:30:6a:9c:4f:13:11:a9:69:68:21:8a:31:f1:dc:8a:
         56:44:81:c9:1e:f3:17:d2:e7:38:7c:c1:52
-----BEGIN CERTIFICATE-----
MIID8DCCA3agAwIBAgIQdG5GP2tFPtTyOLpP+3QxyDAKBggqhkjOPQQDAjCBqzEL
MAkGA1UEBhMCUEgxETAPBgNVBAgMCEJhdGFuZ2FzMRYwFAYDVQQHDA1CYXRhbmdh
cyBDaXR5MRcwFQYDVQQKDA5HYW1lcnMgVlBOIEh1YjEZMBcGA1UECwwQUGhDb3Ju
ZXItR1ZQTkhVQjEXMBUGA1UEAwwOR1ZQTkhVQi1TZXJ2ZXIxJDAiBgkqhkiG9w0B
CQEWFWltYXBzeWNobzI4QGdtYWlsLmNvbTAgFw0yMTAxMjgxMzQ5MDVaGA8yMDgw
MDMxOTEzNDkwNVowgasxCzAJBgNVBAYTAlBIMREwDwYDVQQIDAhCYXRhbmdhczEW
MBQGA1UEBwwNQmF0YW5nYXMgQ2l0eTEXMBUGA1UECgwOR2FtZXJzIFZQTiBIdWIx
GTAXBgNVBAsMEFBoQ29ybmVyLUdWUE5IVUIxFzAVBgNVBAMMDkdWUE5IVUItU2Vy
dmVyMSQwIgYJKoZIhvcNAQkBFhVpbWFwc3ljaG8yOEBnbWFpbC5jb20wdjAQBgcq
hkjOPQIBBgUrgQQAIgNiAARY77g9+0tZJsSZxJ2pwNUqqLKFjMOLv8jHBRoLu3Xf
kTgDa6e+tcS5gQqOj3Vjcn48njcS2FwlrwwlnF2FzpaRn75vC6gGqa0Yz/l2iiQQ
tIm3AJ1y+HAAj95LLjV3y7SjggFZMIIBVTAJBgNVHRMEAjAAMB0GA1UdDgQWBBQD
Yhw97elb8qYPQTetrruKhirhEjCB6wYDVR0jBIHjMIHggBTsYS0Lfq96gKte946j
m4cRdwZxEqGBsaSBrjCBqzELMAkGA1UEBhMCUEgxETAPBgNVBAgMCEJhdGFuZ2Fz
MRYwFAYDVQQHDA1CYXRhbmdhcyBDaXR5MRcwFQYDVQQKDA5HYW1lcnMgVlBOIEh1
YjEZMBcGA1UECwwQUGhDb3JuZXItR1ZQTkhVQjEXMBUGA1UEAwwOR1ZQTkhVQi1T
ZXJ2ZXIxJDAiBgkqhkiG9w0BCQEWFWltYXBzeWNobzI4QGdtYWlsLmNvbYIUHOYp
gZtNLLVaLXdqWXPl2wXN7zAwEwYDVR0lBAwwCgYIKwYBBQUHAwEwCwYDVR0PBAQD
AgWgMBkGA1UdEQQSMBCCDkdWUE5IVUItU2VydmVyMAoGCCqGSM49BAMCA2gAMGUC
MQDqYween64Kvw7HB7zkaIPqXxqvEfDvR6fHQuvN0p52AJw096oj+S3DOaWaGaDc
MvICMBb52Q1G6bTzGhjhNvPmYowvpXcwMGqcTxMRqWloIYox8dyKVkSByR7zF9Ln
OHzBUg==
-----END CERTIFICATE-----
EOF9
cat <<'EOF10' > /etc/openvpn/volt.key
-----BEGIN PRIVATE KEY-----
MIG2AgEAMBAGByqGSM49AgEGBSuBBAAiBIGeMIGbAgEBBDCbbP09CnIUSkg7Y4qV
jl/Owf/AXFtDs+8E0moCX0L6lGREiHeGre9Wzziyg2qqS/ehZANiAARY77g9+0tZ
JsSZxJ2pwNUqqLKFjMOLv8jHBRoLu3XfkTgDa6e+tcS5gQqOj3Vjcn48njcS2Fwl
rwwlnF2FzpaRn75vC6gGqa0Yz/l2iiQQtIm3AJ1y+HAAj95LLjV3y7Q=
-----END PRIVATE KEY-----
EOF10
cat <<'EOF28' > /etc/openvpn/dh.pem
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEAlVC6TGc5lslb4j30NJ8VdH7iAmd3mM23FtYdgoz/wPzeWplDgnej
N39TK4pRfg2g3IdhtIdqgbgYFJveaxJhY1TOyaiwx5jHlq5mq2nPQtIQiOmk/LzZ
bxSuF+/kMDITbG04Ed6HQfTvUi2AAjM5w2S2CbiNB8fQp/ppCOekakkaHxxgLcc8
c0KP+6LkGAZM01IJIozNAqQ5k/uVC4MzkgE9EmSIz5a6p48k3WyJu2j8tBjQJuRb
z3pFYMzJx0RniuRVRRjIUF2hW6JLEQhqhTQZEDhnO7vW8rEcAfqwsaQ3sr8j7+FD
k/KPGLimSf3dMSKhb/T9JY7J96/lXiPUewIBAg==
-----END DH PARAMETERS-----
EOF28
cat <<'EOF29' > /etc/openvpn/ta.key
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
7e15f11cddf9604647bc0fe181f174c1
3f6a9ecda3a4f0d759b4cf1bc4e092a4
fffe34d9c5d98eaab6e19572cc0c4153
753c9446209b737de772f938090705fd
5151e51ae95248b30723542fcf71d9c3
d60a12a1e35dcd73e2ac3acffaf33763
0753eede6eecee0536e7165ca4525ba2
c16e1fbc38b5bc2259f5200baab1b1bb
66e32855aab2d4a1d9e898adbc8486dc
64d87e3b1a164fc54f125a04fa572796
0f888b16d409cd3785bd8086153485eb
3af1dac1fe1f11170af786e56283f305
dfff819a87fefca63dd88cee89d39089
04c871b897fb30c2c405bf1fd6fcdfea
babf56ffea17c525a94e1c403b742c29
d43e69d056f19f5ed6b91c6696271a44
-----END OpenVPN Static key V1-----
EOF29
cat <<'EOF30' > /etc/openvpn/CLIENT.key
-----BEGIN PRIVATE KEY-----
MIG2AgEAMBAGByqGSM49AgEGBSuBBAAiBIGeMIGbAgEBBDD9JqzDjCtqrpDBtMM6
nkTbX+t8eq0U1qB5F3q6ykCm8E5gGrLLOQllP0nyFBZHGRyhZANiAASY+qLrArcf
EMIJ1Vc4RPrQS+XIirwXmB7Xj94ROlpHF38otKbYpJkKXXHdgIIKwYmmRK7MMNlt
4HWCg3YIzXdoC976X/5Y94sBii4b5lMm75btNVpOEEz5akG59J5j5hw=
-----END PRIVATE KEY-----
EOF30
cat <<'EOF31' > /etc/openvpn/CLIENT.crt
-----BEGIN CERTIFICATE-----
MIID1TCCA1ugAwIBAgIQP3A8M99pxRMyOIEH8ZoG/jAKBggqhkjOPQQDAjCBqzEL
MAkGA1UEBhMCUEgxETAPBgNVBAgMCEJhdGFuZ2FzMRYwFAYDVQQHDA1CYXRhbmdh
cyBDaXR5MRcwFQYDVQQKDA5HYW1lcnMgVlBOIEh1YjEZMBcGA1UECwwQUGhDb3Ju
ZXItR1ZQTkhVQjEXMBUGA1UEAwwOR1ZQTkhVQi1TZXJ2ZXIxJDAiBgkqhkiG9w0B
CQEWFWltYXBzeWNobzI4QGdtYWlsLmNvbTAgFw0yMTAxMjgxMzU5MTBaGA8yMDgw
MDMxOTEzNTkxMFowgasxCzAJBgNVBAYTAlBIMREwDwYDVQQIDAhCYXRhbmdhczEW
MBQGA1UEBwwNQmF0YW5nYXMgQ2l0eTEXMBUGA1UECgwOR2FtZXJzIFZQTiBIdWIx
GTAXBgNVBAsMEFBoQ29ybmVyLUdWUE5IVUIxFzAVBgNVBAMMDkdWUE5IVUItQ2xp
ZW50MSQwIgYJKoZIhvcNAQkBFhVpbWFwc3ljaG8yOEBnbWFpbC5jb20wdjAQBgcq
hkjOPQIBBgUrgQQAIgNiAASY+qLrArcfEMIJ1Vc4RPrQS+XIirwXmB7Xj94ROlpH
F38otKbYpJkKXXHdgIIKwYmmRK7MMNlt4HWCg3YIzXdoC976X/5Y94sBii4b5lMm
75btNVpOEEz5akG59J5j5hyjggE+MIIBOjAJBgNVHRMEAjAAMB0GA1UdDgQWBBQ7
k1OI68EH8CWjQ0EyeIVF7fewGDCB6wYDVR0jBIHjMIHggBTsYS0Lfq96gKte946j
m4cRdwZxEqGBsaSBrjCBqzELMAkGA1UEBhMCUEgxETAPBgNVBAgMCEJhdGFuZ2Fz
MRYwFAYDVQQHDA1CYXRhbmdhcyBDaXR5MRcwFQYDVQQKDA5HYW1lcnMgVlBOIEh1
YjEZMBcGA1UECwwQUGhDb3JuZXItR1ZQTkhVQjEXMBUGA1UEAwwOR1ZQTkhVQi1T
ZXJ2ZXIxJDAiBgkqhkiG9w0BCQEWFWltYXBzeWNobzI4QGdtYWlsLmNvbYIUHOYp
gZtNLLVaLXdqWXPl2wXN7zAwEwYDVR0lBAwwCgYIKwYBBQUHAwIwCwYDVR0PBAQD
AgeAMAoGCCqGSM49BAMCA2gAMGUCMQCcX8H4y/yh0FX+KfMlr0pddojAMgDxDzcL
5VfOMho4C3M391KsvzQX2NBkays6k+ICMEzaiI32hS2zvkspVCAsSANl/4nxKSdG
FPFq6nTFawZekRJycKDCTCXDXUaCpIXbAw==
-----END CERTIFICATE-----
EOF31

# setting openvpn server port
sed -i "s|MyOvpnPort1|$OpenVPN_Port1|g" /etc/openvpn/server_tcp.conf
sed -i "s|MyOvpnPort2|$OpenVPN_Port2|g" /etc/openvpn/server_tcp1.conf
sed -i "s|MyOvpnPort3|$OpenVPN_Port3|g" /etc/openvpn/server_udp.conf
sed -i "s|MyOvpnPort4|$OpenVPN_Port4|g" /etc/openvpn/server_udp1.conf
 
# Generating openvpn dh.pem file using openssl
#openssl dhparam -out /etc/openvpn/dh.pem 1024
 
# Getting some OpenVPN plugins for unix authentication
wget -qO /etc/openvpn/b.zip 'https://github.com/imaPSYCHO/Parts/raw/main/openvpn_plugin64'
unzip -qq /etc/openvpn/b.zip -d /etc/openvpn
rm -f /etc/openvpn/b.zip
 
# Some workaround for OpenVZ machines for "Startup error" openvpn service
if [[ "$(hostnamectl | grep -i Virtualization | awk '{print $2}' | head -n1)" == 'openvz' ]]; then
sed -i 's|LimitNPROC|#LimitNPROC|g' /lib/systemd/system/openvpn*
systemctl daemon-reload
fi

# Allow IPv4 Forwarding
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/20-openvpn.conf && sysctl --system &> /dev/null && echo 1 > /proc/sys/net/ipv4/ip_forward

systemctl stop ufw
systemctl disable ufw
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o $ANU -j SNAT --to xxxxxxxxx
iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -o $ANU -j SNAT --to xxxxxxxxx
iptables -t nat -A POSTROUTING -s 192.168.3.0/24 -o $ANU -j SNAT --to xxxxxxxxx
iptables -t nat -A POSTROUTING -s 192.168.4.0/24 -o $ANU -j SNAT --to xxxxxxxxx
iptables -A INPUT -s $(wget -4qO- http://ipinfo.io/ip) -p tcp -m multiport --dport 1:65535 -j ACCEPT
iptables -I INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -I OUTPUT -o eth0 -d 0.0.0.0/0 -j ACCEPT
iptables-save > /etc/iptables.up.rules
chmod +x /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload
 
# Enabling IPv4 Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

 
# Starting OpenVPN server
systemctl start openvpn@server_tcp
systemctl start openvpn@server_tcp1
systemctl start openvpn@server_udp
systemctl start openvpn@server_udp1
systemctl enable openvpn@server_tcp
systemctl enable openvpn@server_tcp1
systemctl enable openvpn@server_udp
systemctl enable openvpn@server_udp1
systemctl restart openvpn@server_tcp
systemctl restart openvpn@server_tcp1
systemctl restart openvpn@server_udp
systemctl restart openvpn@server_udp1

# Removing Duplicate privoxy config
rm -rf /etc/privoxy/config*
 
# Creating Privoxy server config using cat eof tricks
cat <<'myPrivoxy' > /etc/privoxy/config
# My Privoxy Server Config
user-manual /usr/share/doc/privoxy/user-manual
confdir /etc/privoxy
logdir /var/log/privoxy
filterfile default.filter
logfile logfile
listen-address 0.0.0.0:Privoxy_Port1
toggle 1
enable-remote-toggle 0
enable-remote-http-toggle 0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
enable-proxy-authentication-forwarding 1
forwarded-connect-retries 1
accept-intercepted-requests 1
allow-cgi-request-crunching 1
split-large-forms 0
keep-alive-timeout 5
tolerate-pipelining 1
socket-timeout 300
permit-access 0.0.0.0/0 IP-ADDRESS
myPrivoxy

# Setting machine's IP Address inside of our privoxy config(security that only allows this machine to use this proxy server)
sed -i "s|IP-ADDRESS|$MYIP|g" /etc/privoxy/config
 
# Setting privoxy ports
sed -i "s|Privoxy_Port1|$Privoxy_Port1|g" /etc/privoxy/config
sed -i "s|Privoxy_Port2|$Privoxy_Port2|g" /etc/privoxy/config

apt remove --purge squid -y
wget "http://security.debian.org/debian-security/pool/updates/main/s/squid3/squid_3.5.23-5+deb9u7_amd64.deb" -qO squid.deb
dpkg -i squid.deb
rm -f squid.deb

apt install libecap3 squid-common squid-langpack -y
wget "http://security.debian.org/debian-security/pool/updates/main/s/squid3/squid_3.5.23-5+deb9u7_amd64.deb" -qO squid.deb
dpkg -i squid.deb
rm -f squid.deb
 
# Squid Ports (must be 1024 or higher)

cat <<mySquid > /etc/squid/squid.conf
acl VPN dst $(wget -4qO- http://ipinfo.io/ip)
http_access allow VPN
http_access deny all 
http_port 0.0.0.0:$Proxy_Port1
http_port 0.0.0.0:$Proxy_Port2
coredump_dir /var/spool/squid
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
visible_hostname Volt
mySquid

sed -i "s|SquidCacheHelper|$Proxy_Port1|g" /etc/squid/squid.conf
sed -i "s|SquidCacheHelper|$Proxy_Port2|g" /etc/squid/squid.conf

# Creating nginx config for our ovpn config downloads webserver
cat <<'myNginxC' > /etc/nginx/conf.d/alien-config.conf
# My OpenVPN Config Download Directory
server {
 listen 0.0.0.0:88;
 server_name localhost;
 root /home/vps/public_html;
 index index.html;
}
myNginxC

# Removing Default nginx page(port 80)
rm -rf /etc/nginx/sites-*

# Creating our root directory for all of our .ovpn configs
rm -rf /var/www/openvpn
mkdir -p /home/vps/public_html

# Now creating all of our OpenVPN Configs 
cat <<vpn1> /home/vps/public_html/alien-tcp1.ovpn
# Premium Script Ovpn
# AlienVpn
client
dev tun
proto tcp
remote $MYIP 1194
remote-cert-tls server
tun-mtu 1500
mssfix 1450
auth-user-pass
auth none
cipher none
comp-lzo
setenv CLIENT_CERT 0
<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
vpn1
cat <<vpn2> /home/vps/public_html/alien-tcp2.ovpn
# Premium Script Ovpn
# AlienVpn
client
dev tun
proto tcp
remote $MYIP 465
remote-cert-tls server
tun-mtu 1500
mssfix 1450
auth-user-pass
auth none
cipher none
comp-lzo
setenv CLIENT_CERT 0
<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
vpn2
cat <<vpn3> /home/vps/public_html/alien-udp1.ovpn
# Premium Script Ovpn
# AlienVpn
client
dev tun
proto tcp
remote $MYIP 2200
remote-cert-tls server
tun-mtu 1500
mssfix 1450
auth-user-pass
auth none
cipher none
comp-lzo
setenv CLIENT_CERT 0
<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
vpn3
cat <<vpn4> /home/vps/public_html/alien-udp2.ovpn
# Premium Script Ovpn
# AlienVpn
client
dev tun
proto tcp
remote $MYIP 2500
remote-cert-tls server
tun-mtu 1500
mssfix 1450
auth-user-pass
auth none
cipher none
comp-lzo
setenv CLIENT_CERT 0
<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
vpn4
# Creating OVPN download site index.html
cat <<'mySiteOvpn' > /home/vps/public_html/index.html
Setup By AlienVpn
mySiteOvpn
 
# Restarting nginx service
systemctl restart nginx
 
# Creating all .ovpn config archives
cd /home/vps/public_html 
zip -qq -r configs.zip *.ovpn *.txt
cd
# install fail2ban
apt -y install fail2ban
# Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'
# xml parser
cd
apt install -y libxml-parser-perl
# blockir torrent
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# install badvpn
cd
cd
wget -O /usr/bin/badvpn-udpgw "https://github.com/kor8/volt/raw/beta/modul/badvpn-udpgw64"
chmod +x /usr/bin/badvpn-udpgw
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 4000' /etc/rc.local
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 4000

# setting vnstat
apt -y install vnstat
/etc/init.d/vnstat restart
apt -y install libsqlite3-dev
wget https://humdi.net/vnstat/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc && make && make install
cd
vnstat -u -i $NET
sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat
/etc/init.d/vnstat restart
rm -f /root/vnstat-2.6.tar.gz
rm -rf /root/vnstat-2.6
echo "12 0 * * * root reboot" >> /etc/crontab
echo "0 0 * * * root xp" >> /etc/crontab

cd /usr/local/sbin/
rm -rf {menu-ssh,base-ports,base-ports-wc,base-script,bench-network,clearcache,connections,create,create_random,create_trial,delete_expired,delete_all,diagnose,edit_dropbear,edit_openssh,edit_openvpn,edit_ports,edit_squid3,edit_stunnel4,locked_list,menu,options,ram,reboot_sys,reboot_sys_auto,restart_services,server,set_multilogin_autokill,set_multilogin_autokill_lib,show_ports,speedtest,user_delete,user_details,user_details_lib,user_extend,user_list,user_lock,user_unlock}
wget -q 'https://github.com/kor8/volt/raw/beta/script/fixed1.zip'
unzip -qq fixed1.zip
rm -f fixed1.zip
chmod +x ./*
dos2unix ./*
sed -i 's|/etc/squid/squid.conf|/etc/privoxy/config|g' ./*
sed -i 's|http_port|listen-address|g' ./*
cd ~

# Turning Off Multi-login Auto Kill
rm -f /etc/cron.d/set_multilogin_autokill_lib

wget -N --no-check-certificate https://github.com/ylx2016/kernel/releases/download/4.14.168bbrplus/linux-headers-4.14.168-bbrplus_4.14.168-bbrplus-1-d10_amd64.deb
wget -N --no-check-certificate https://github.com/ylx2016/kernel/releases/download/4.14.168bbrplus/linux-image-4.14.168-bbrplus_4.14.168-bbrplus-1-d10_amd64.deb
					
dpkg -i linux-headers-4.14.168-bbrplus_4.14.168-bbrplus-1-d10_amd64.deb
dpkg -i linux-image-4.14.168-bbrplus_4.14.168-bbrplus-1-d10_amd64.deb

sed -i '/fs.file-max/d' /etc/sysctl.conf
sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
echo "fs.file-max = 1000000
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbrplus" >> /etc/sysctl.conf
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
# forward ipv4
net.ipv4.ip_forward = 1">>/etc/sysctl.conf

# remove unnecessary files
cd
apt autoclean -y
apt -y remove --purge unscd
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove bind9*;
apt-get -y remove sendmail*
apt autoremove -y
# finishing
cd
chown -R www-data:www-data /home/vps/public_html
/etc/init.d/nginx restart
/etc/init.d/openvpn restart
/etc/init.d/cron restart
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/fail2ban restart
/etc/init.d/stunnel4 restart
/etc/init.d/vnstat restart
/etc/init.d/squid restart
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 4000
history -c
echo "unset HISTFILE" >> /etc/profile
# finihsing
clear
rm -rf /root/deb10.sh
rm -rf deb10.sh
exit 1
cd .. && rm -rf bbrplus
detele_kernel -y
BBR_grub -y
reboot
