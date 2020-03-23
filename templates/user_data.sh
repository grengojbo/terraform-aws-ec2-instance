#!/bin/bash

echo "LANG=en_US.utf-8" >> /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment
echo "node_name=${node_name}" >> /etc/environment
echo "etcd_cluster_name=${cluster_name}" >> /etc/environment
echo "etcd_enabled=${etcd_enabled}" >> /etc/environment
echo "k8s_enabled=${k8s_enabled}" >> /etc/environment
echo "pke_etcd_version=${pke_etcd_version}" >> /etc/environment
echo "bucket_data=${bucket_data}" >> /etc/environment
echo "s3_region=${s3_region}" >> /etc/environment
echo "s3_bucket=${s3_bucket}" >> /etc/environment
echo "etcd_provider=${etcd_provider}" >> /etc/environment
echo "node_exporter_enabled=${node_exporter_enabled}" >> /etc/environment
echo "fluetbit_enabled=${fluetbit_enabled}" >> /etc/environment
echo "etcd_recovery=${etcd_recovery}" >> /etc/environment
echo "etcd_dns_srv_enabled=${etcd_dns_srv_enabled}" >> /etc/environment
echo "etcd_lb_enabled=${etcd_lb_enabled}" >> /etc/environment
echo "install_packages=${install_packages}" >> /etc/environment
echo "is_last_kernel=${is_last_kernel}" >> /etc/environment
# echo "" >> /etc/environment

%{ if domain_name != "none" }
echo "domain_name=${domain_name}" >> /etc/environment
%{ endif }

DT_START=$(date)

SUDO_USER=${remote_user}

mkdir -p /opt/libs
chmod 0777 /opt/libs

mkdir -p /home/${remote_user}/bin
chown -R ${remote_user}:${remote_user} /home/${remote_user}/bin

%{ if install_packages }
yum -y update
# https://www.liquidweb.com/kb/enable-epel-repository/
yum -y install epel-release
yum -y update

yum -y install awscli wget jq vim ethtool ipset
yum -y install htop mc
# No package fond
# yum -y install realpath dbus-tools 
%{ endif }

wget https://releases.hashicorp.com/vault/1.3.4/vault_1.3.4_linux_amd64.zip
unzip ./vault_1.3.4_linux_amd64.zip
rm ./vault_1.3.4_linux_amd64.zip
chown 0777 ./vault
mv ./vault /usr/local/bin/
# sudo chown 0777 ./vault
# sudo mv ./vault /usr/local/bin/

# https://www.terraform.io/docs/configuration/expressions.html#string-templates
%{ if lvm_enabled }
yum -y install lvm2
%{ endif }

%{ if k8s_enabled }
echo "TODO: add kubernetes cluster"
%{ endif }
# Author prefers network tools to be baked part of the image
#sudo yum -y install bind-utils mtr nc nmap traceroute

# And git
#sudo yum -y install git

# Disable NetworkManager and firewalld
#/usr/bin/systemctl disable NetworkManager
#/usr/bin/systemctl disable firewalld
#/usr/bin/systemctl enable network

echo "[$DT_START] Start" >> /.first
echo "[$(date)] End" >> /.first
# chown ${remote_user}:${remote_user} /home/${remote_user}/.first

# while test ! -f /home/centos/.first
# do
#   echo wait.
#   sleep 2
# done
# echo "Done install packages..."
# exit 0;

