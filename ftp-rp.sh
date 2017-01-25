# # ftp port setup for reverse proxy
iptables -A PREROUTING -d 118.122.94.42/32 -i eth0 -p tcp -m tcp --dport 20000:25000 -j DNAT --to-destination sc-tcc-01
iptables -A PREROUTING -d 118.122.94.42/32 -i eth0 -p tcp -m tcp --dport 25001:30000 -j DNAT --to-destination sc-tcc-02