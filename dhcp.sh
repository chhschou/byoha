# #!/usr/bin/env bash
# # deploy dhcp server with specified IP pool to help with setting up cluster
# # must run as root!

apt-get install -y isc-dhcp-server

# setup ddns
sed -i 's/ddns-update-style none/ddns-update-style interim/' /etc/dhcp/dhcpd.conf
# make authoritative
sed -i 's/#authoritative/authoritative/' /etc/dhcp/dhcpd.conf

sed -i 's/option domain-name \"example.org\"/option domain-name \"sc.lccs.com\"/' /etc/dhcp/dhcpd.conf
sed -i 's/option domain-name-servers ns1.example.org, ns2.example.org/option domain-name-servers \"sc-dc-01.sc.lccs.com\"/' /etc/dhcp/dhcpd.conf

echo "
class \"filestores\" {
	match if substring (option host-name, 0, 6) = \"sc-fsc\";
}

class \"db-masters\" {
	match if substring (option host-name, 0, 7) = \"sc-db-m\";
}

class \"db-slaves\" {
	match if substring (option host-name, 0, 7) = \"sc-db-s\";
}

class \"apps\" {
	match if substring (option host-name, 0, 6) = \"sc-app\";
}

class \"tccs\" {
	match if substring (option host-name, 0, 6) = \"sc-tcc\";
}

subnet 192.168.2.0 netmask 255.255.255.0 {
	option routers 192.168.2.1;

	pool {
		allow members of \"filestores\";
		range 192.168.2.201 192.168.2.240;
	}

	pool {
		allow members of \"db-masters\";
		range 192.168.2.101 192.168.2.105;
	}

	pool {
		allow members of \"db-slaves\";
		range 192.168.2.106 192.168.2.150; 
	}

	pool {
		allow members of \"apps\";
		range 192.168.2.11 192.168.2.20; 
	}

	pool {
		allow members of \"tccs\";
		range 192.168.2.21 192.168.2.30; 
	}

	pool {
		deny members of \"filestores\";
		deny members of \"db-masters\";
		deny members of \"db-slaves\";
		deny members of \"apps\";
		deny members of \"tccs\";
		range 192.168.2.151 192.168.2.200;
	}
}
" >> /etc/dhcp/dhcpd.conf

# start dhcp service
service isc-dhcp-server restart