# #!/usr/bin/env bash
# # deploy centrify tools on a client
# # must run as root!



# download and extract installer
cd /home
# download and install centrify-suite
CentrifySuiteFN=centrify-suite
mkdir -p "$CentrifySuiteFN"
wget -O "$CentrifySuiteFN".tgz http://downloads.centrify.com/products/centrify-suite/2013-update-3/installers/centrify-suite-2013.3-deb5-x86_64.tgz
tar -C "$CentrifySuiteFN" -zxf "$CentrifySuiteFN".tgz
cd "$CentrifySuiteFN"
./install.sh # kickoff installation

# download and install centrify enabled krb5
CentrifyEnabledKrb5FN=centrify-krb5
mkdir -p "$CentrifyEnabledKrb5FN"
wget -O "$CentrifyEnabledKrb5FN".tgz http://downloads.centrify.com/products/opensource/kerberos-5.1.0/centrify-krb5-5.1.0-deb5-x86_64.tgz
tar -C "$CentrifyEnabledKrb5FN" -zxf "$CentrifyEnabledKrb5FN".tgz
cd "$CentrifyEnabledKrb5FN"
dpkg -i *.deb

# wget http://downloads.centrify.com/products/opensource/samba-4.5.6/centrify-samba-4.5.6-deb5-x86_64.tgz