# #!/bin/sh
# # must run as root!

#Variables
FQDN=sc.lccs.com
HN=sc-dc-01
UppercaseFQDN=$( echo "$FQDN" | tr '[:lower:]' '[:upper:]' )
DN=sc
NSE=8.8.8.8 # external/forwarder nameserver
APW=123456a_ # domain administrator password

# ntp servers
NTPSRV1=210.72.145.44
NTPSRV2=
NTPSRV3=
NTPSRV4=

# provision domain
/usr/local/samba/bin/samba-tool domain provision --use-rfc2307 --realm=$FQDN --domain=$DN --adminpass="$APW" --server-role=dc --dns-backend=SAMBA_INTERNAL 
# start samba
/usr/local/samba/sbin/samba 
# check samba and samba client version, they should match
/usr/local/samba/sbin/samba -V
/usr/local/samba/bin/smbclient -V
sleep 2
# list samba volume on this host, this should show sysvol, netlogon shares etc.
/usr/local/samba/bin/smbclient -L localhost -U%
sleep 2
# check administrator can authenticate
/usr/local/samba/bin/smbclient //localhost/netlogon -UAdministrator%"$APW" -c 'ls'

echo ================DNS CONFIGURATION SAMBA_INTERNAL=====================
sed -i "s/.*dns forwarder =.*/	dns forwarder = $NSE\n	allow dns updates = nonsecure/g" /usr/local/samba/etc/smb.conf # add dns forwarder
echo ====================DNS TEST==========================
# verify DNS functionality
host -t SRV _ldap._tcp.$FQDN.
host -t SRV _kerberos._udp.$FQDN.
host -t A $FQDN.
# Create reverse lookup zone, you will be prompt admin password
/usr/local/samba/bin/samba-tool dns zonecreate $HN 2.168.192.in-addr.arpa --username=administrator
sleep 5
echo ==================KERBEROS CONFIGURATION==============
# configure kerberos
sed -i "s/\${REALM\([^}]*\)}"/$UppercaseFQDN"/g" /usr/local/samba/share/setup/krb5.conf 
kinit administrator@$UppercaseFQDN
klist -e
echo =================NTP CONFIGURATION====================
# add more ntp server here as required
sed -i "s/0.ubuntu.pool.ntp.org/$NTPSRV1/" /etc/ntp.conf
sed -i "s/1.ubuntu.pool.ntp.org/$NTPSRV2/" /etc/ntp.conf
sed -i "s/2.ubuntu.pool.ntp.org/$NTPSRV3/" /etc/ntp.conf
sed -i "s/3.ubuntu.pool.ntp.org/$NTPSRV4/" /etc/ntp.conf
service ntp restart
ntpdate $NTPSRV1
ntpq -p

echo =================HOMEFOLDERS CONFIGURATION============
#Configuration des homefolders
mkdir -m 770 /Users
chmod g+s /Users
chown root:users /Users

echo "
[Users]
directory_mode: parameter = 0700
read only = no
path = /Users
csc policy = documents" >> /usr/local/samba/etc/smb.conf

echo ================= Autostart Samba4============
# create a startup script
echo "
description \"SMB/CIFS File and Active Directory Server\"
author      \"Jelmer Vernooij <jelmer@ubuntu.com>\"
start on (local-filesystems and net-device-up)
stop on runlevel [!2345]
expect fork
normal exit 0
pre-start script
    [ -r /etc/default/samba4 ] && . /etc/default/samba4
    install -o root -g root -m 755 -d /var/run/samba
    install -o root -g root -m 755 -d /var/log/samba
end script
exec /usr/local/samba/sbin/samba -D" > /etc/init/samba.conf

chmod 755 /etc/init/samba.conf # make startup script executable
ln -s -T /lib/init/upstart-job /etc/init.d/samba # notify upstart system

echo ================== Optional =====================
echo "# If you wish to disable AD administrator password expiry because it is seldomly used do:
/usr/local/samba/bin/samba-tool user setexpiry administrator --noexpiry

# to check for invalid configuration in /usr/local/samba/etc/smb.conf and print out current configuration
/usr/local/samba/bin/samba-tool testparm"


echo ========================REBOOT==========================
exit


