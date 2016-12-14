# Hotspot-Creator-for-Linux
A simple bash script to create hotspot.
* It may contain some bugs or code cleaning may require as it's in alpha stage.
* I've just created this script to learn shell scripting.

-->How to run
1. Download the file "hs.sh"
2. Make it executable
   sudo chmod a+x hs.sh
3. Execute the script
   sudo sh hs.sh

-->To restore your configs and settings
1. Download restore.sh
2. Make it executable by entering
   sudo chmod a+x restore.sh
3. Execute the script
   sudo sh restore.sh
   
-->How it works

//Requirements
	two network cards(wireless+wireless || wired+wireless)
	one wireless device will allow other devices to connect through
	the hotspot and other connection will allow to access internet.
	Packages required :- 
	1) hostapd(allows other devices to connect to your WiFi card)
	2) udhcpd(assigns IP addresses users)

// editing /etc/udhcpd.conf
	this config file will be setting up what IP address range you'll
	be issuing to other devices as well as what DNS servers you'll
	be issuing to these users

// replacing the contents of /etc/default/udhcpd with DHCPD_OPTS="-S"

// ifconfig wlan0 192.168.42.1 (to issue an IP address to our 'new' router)

// configuring /etc/hostapd/hostapd.conf
	setting up name of hotspot, channel etc.

// editing the file(/etc/network/interfaces) for our interfaces and make sure that the IP address for our wifi connection stays the same as well as making sure that any other network configuraions we want to start it started up configured correctly

// specify the config file to be used by hostapd by replacing the contents of /etc/default/hostapd with 
DAEMON_CONF="/etc/hostapd/hostapd.conf"

// enable forwarding on our network card
	echo 1 > /proc/sys/net/ipv4/ip_forward
	echo 'net.ipv4.ip_forward=1' > /etc/sysctl.conf

// apply iptables rules to tell what network card to forward to which network card in what events by running these lines
	iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
	iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,
	ESTABLISHED -j ACCEPT
	iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

// Save the settings
	iptables-save > /etc/iptables.ipv4.nat

// Reboot your system and after reboot your AP will be up and running.

// start services
	service hostapd start
	service udhcpd start

