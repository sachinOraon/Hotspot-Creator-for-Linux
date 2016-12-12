#!/bin/sh

rm /etc/hs/backedup.dat 2>/dev/null
rm /etc/hs/config.dat 2>/dev/null

if [ -f /etc/udhcpd.conf.bak ]; then
	rm /etc/udhcpd.conf 2>/dev/null
	mv /etc/udhcpd.conf.bak /etc/udhcpd.conf 2>/dev/null
fi

if [ -f /etc/default/udhcpd.bak ]; then
	rm /etc/default/udhcpd 2>/dev/null
	mv /etc/default/udhcpd.bak /etc/default/udhcpd 2>/dev/null
fi

if [ -f /etc/hostapd/hostapd.conf.bak ]; then
	rm /etc/hostapd/hostapd.conf 2>/dev/null
	mv /etc/hostapd/hostapd.conf.bak /etc/hostapd/hostapd.conf 2>/dev/null
fi

if [ -f /etc/network/interfaces.bak ]; then
	rm /etc/network/interfaces 2>/dev/null
	mv /etc/network/interfaces.bak /etc/network/interfaces 2>/dev/null
fi

if [ -f /etc/default/hostapd.bak ]; then
	rm /etc/default/hostapd 2>/dev/null
	mv /etc/default/hostapd.bak /etc/default/hostapd 2>/dev/null
fi

if [ -f /etc/iptables.ipv4.nat ]; then
	rm /etc/iptables.ipv4.nat 2>/dev/null
fi
