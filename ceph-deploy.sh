# #!/usr/bin/env bash
# # Deploy ceph
# # must run this as root!

CephA=cephadmin
CephAPW=123456c_

# install ceph-deploy
wget -q -O- https://raw.github.com/ceph/ceph/master/keys/release.asc | apt-key add -
echo deb http://ceph.com/debian/ $(lsb_release -sc) main | tee /etc/apt/sources.list.d/ceph.list
apt-get update && apt-get install -y ceph-deploy openssh-server

# create ceph admin user, note password needs to be "hashed" by openssl
useradd -d /home/ceph -m -p `openssl passwd $CephAPW` -s /bin/bash $CephA
echo "cephadmin ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ceph # give admin right
sudo chmod 0440 /etc/sudoers.d/ceph

# use ceph administrator for all admin operation from this point on
su $CephA # you will be prompt password

# ceph cluster for use in command line arguments (do not delete the space either side)
CephClusterArg= --cluster fsc01 

