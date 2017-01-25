# #!/bin/sh
# # must run this as root!

# Variables
IP=192.168.2.5
NM=255.255.255.0
GW=192.168.2.1
NSI=192.168.2.5 # internal nameserver
# NSI2= X.X.X.X
NSE=8.8.8.8 # external/forwarder nameserver
# NSE2= X.X.X.X
FQDN=sc.lccs.com
HN=sc-dc-01

echo ================NETWORK CONFIGURATION=======================

# configure for static network, assume eth0 is available
sed -i 's/dhcp/static/g' /etc/network/interfaces
echo "	address $IP
	netmask $NM
	gateway $GW 
	dns-nameservers $NSI $NSE
	dns-search $FQDN ">> /etc/network/interfaces
	
# configure hosts for dns-less resolution 	
sed -i 's/127.0.0.1	localhost/127.0.0.1	localhost.localdomain	localhost/' /etc/hosts
sed -i  "s/127.0.1.1	$HN"/"$IP	$HN"."$FQDN	$HN"/"" /etc/hosts
# set hostname
echo $HN'.'$FQDN > /etc/hostname
/etc/init.d/hostname restart
/etc/init.d/networking restart
sleep 10
echo ================PREREQUISITES SETUP=====================
# add apt-fast to speed up apt work
apt-get install -y python-software-properties
add-apt-repository -y ppa:apt-fast/stable
apt-get update && apt-get install -y apt-fast
# make sure we suppress apt-fast's confirmation dialog
sed -i "s/DOWNLOADBEFORE=/DOWNLOADBEFORE=true/" /etc/apt-fast.conf
# add mirrors to apt-fast config (very important for speedup)
sed -i "s/#MIRRORS=( 'none' )/MIRRORS=( 'http:\/\/mirrors.ustc.edu.cn\/ubuntu\/,http:\/\/mirror.lzu.edu.cn\/ubuntu\/,http:\/\/ubuntu.dormforce.net\/ubuntu\/' )/" /etc/apt-fast.conf
apt-fast upgrade -y
# install build and essential packages
apt-fast install dialog git build-essential libacl1-dev libattr1-dev libblkid-dev libgnutls-dev libreadline-dev python-dev python-dnspython gdb pkg-config libpopt-dev libldap2-dev dnsutils libbsd-dev attr krb5-user docbook-xsl libcups2-dev libpam0g-dev ntp -y

echo ================SAMBA4 DOWNLOAD AND SETUP=====================
cd /home
# git maybe too slow to work with in china, so use download packages instead
wget http://ftp.samba.org/pub/samba/stable/samba-4.1.4.tar.gz
tar -xzf samba-4.1.4.tar.gz
cd samba-4.1.4
./configure --enable-debug --enable-selftest #Configuration
make # Compilation
make install # Installation
echo ========================REBOOT NOW==========================
exit

