#!/bin/bash

#Remove old firewall
iptables -F
iptables -X

iptables -t nat -F
iptables -t nat -X

iptables -t mangle -F
iptables -t mangle -X

#Config new firewall
IPTABLES=/sbin/iptables
$IPTABLES -N internet -t mangle
$IPTABLES -t mangle -A PREROUTING -j internet
$IPTABLES -t mangle -A internet -j MARK --set-mark 99
$IPTABLES -t nat -A PREROUTING -m mark --mark 99 -p tcp --dport 80 -j DNAT --to-destination 192.168.5.1

echo "1" > /proc/sys/net/ipv4/ip_forward

$IPTABLES -A FORWARD -i eth0 -o wlan0 -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -A FORWARD -m mark --mark 99 -j REJECT
$IPTABLES -A FORWARD -i wlan0 -o eth0 -j ACCEPT
$IPTABLES -t nat -A POSTROUTING -o eth0 -j MASQUERADE

#Start Python script
python server.py
