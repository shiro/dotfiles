#!/bin/zsh

yay -S dnscrypt-proxy-git


echo "edit: /etc/dnscrypt-proxy/dnscrypt-proxy.toml"

echo "to set cloudflare as NS use:"

cat << EOF

server_names = ['cloudflare', 'cloudflare-ipv6']

EOF

read
sudo -E vim /etc/dnscrypt-proxy/dnscrypt-proxy.toml


echo "disable network manager"

echo "add:"
cat << EOF

[main]
dns=none

EOF

echo "to: /etc/NetworkManager/NetworkManager.conf"
read

sudo -E vim /etc/NetworkManager/NetworkManager.conf


echo "sudo killall dnsmasq"
sudo killall dnsmasq


echo "add:"
cat << EOF

nameserver ::1
nameserver 127.0.0.1
options edns0 single-request-reopen

EOF

echo "to: /etc/resolv.conf"
echo "comment out other lines"

read
sudo -E vim /etc/resolv.conf


echo "starting dnscrypt-proxy.service"
sudo systemctl enable dnscrypt-proxy.service
sudo systemctl start dnscrypt-proxy.service
