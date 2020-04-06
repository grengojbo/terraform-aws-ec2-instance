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

yum -y install awscli wget jq vim ethtool ipset yum-utils
yum -y install htop mc 
# No package fond
# yum -y install realpath dbus-tools 
%{ endif }

%{ if is_last_kernel }
# https://www.howtoforge.com/tutorial/how-to-upgrade-kernel-in-centos-7-server/?__cf_chl_captcha_tk__=2dcf1941ae5b8744e03dbdb9b743e57fadd034d3-1586087805-0-AXpYGdSYjjVQukaXA-uyYuQZhcejM7vmUymbe8B7DLCMhK1030e_8AEK7vEWjNq79oSyDJLHX7348fmfcSQNcJec9z7VXxvYQadLu-Xhk9VfAInag2t56pgGnbruginZwbqGTZtnkyLD90mANH2T44mXmBtmBWABBhX-Fd8L0JxTy_moz58FsWQrW4HFqkMED3lxIUDx9moHghdfeUV4DKuEFCxhC81Bf1ghVyzkWtSKqhvpQUt9NwB3sO-Ub0xtrQ-cNs5E1onuQjBWp0gV9Cj_ujnxu6uU9dcRRFK0YVfre-RgzPixSK99bqiJ9bPr5-PSQSRG9SDTR_1uPvRprJxKPF2sb3PLYJFrkh596tTTJisAaVgtDjSryVq3mWZqGdLS9XGYKHknN8HQxu9u_HBWBRiWsXlwnCzAntsM1Uvtxb_hClM1MEGib6LzuaWyd2uCKm3UonlNUAbdy5uBplJ_buLZMwEacdRcGJ3sBzwarE2qtbk7uB6T-dw36wNQgmGAhhXnVS0wQxA5R_XpkPV_rvAJgu_j3n-tvVhA7s7pGPGjItX6kfYKg37SBq4-kg
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
yum -y update
yum --enablerepo=elrepo-kernel -y install kernel-ml


# https://computingforgeeks.com/install-linux-kernel-5-on-centos-7/
# cat /etc/default/grub
# GRUB_TIMEOUT=1
# GRUB_DEFAULT=0 
# GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
# GRUB_DEFAULT=saved
# GRUB_DISABLE_SUBMENU=true
# GRUB_TERMINAL_OUTPUT="console"
# GRUB_CMDLINE_LINUX="no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop crashkernel=auto"
# GRUB_DISABLE_RECOVERY="true"

echo "List kernels..."
awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
sudo grub2-set-default 0
grub2-mkconfig -o /boot/grub2/grub.cfg
# uname -srv
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

%{ if is_last_kernel }
# (sleep 2; reboot)&
## shutdown -r +0
%{ endif }
