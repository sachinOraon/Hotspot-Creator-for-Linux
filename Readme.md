# A simple bash script to create hotspot and enabling internet connection sharing.

* It may contain some bugs as I'm a beginner in shell scripting. I created it to learn bash scripting.

// How to run
* Download the file "h.sh"
* Make it executable...
   sudo chmod a+x h.sh
* Execute the script
   sudo sh h.sh

// Switches to speed up things.
* -r   To clear log and configs. Restores the modified files.
* -c   To quickly run the hostapd.conf file saved previously.
* -h   To display help screen.

// Some Notes on Creating WiFi Hotspot

//Requirements
Two network cards(wireless+wireless || wired+wireless) one wireless device will allow other devices to connect through the hotspot and other connection will allow to access internet.

// Dependencies
* hostapd(allows other devices to connect to your WiFi card i.e creates AcessPoint)
* udhcpd(assigns IP addresses users i.e runs DHCP server)

// editing /etc/udhcpd.conf
this config file will be setting up what IP address range you'll be issuing to other devices as well as what DNS servers you'll be issuing to these users.

// replacing the contents of /etc/default/udhcpd with DHCPD_OPTS="-S"

// ifconfig wlan0 IP (to issue an IP address to our 'new' router)

// configuring /etc/hostapd/hostapd.conf for setting up name of hotspot, channel etc.

// editing the file(/etc/network/interfaces) for our interfaces and make sure that the IP address for our wifi connection stays the same throught reboots.

// specify the config file to be used by hostapd by replacing the contents of /etc/default/hostapd with DAEMON_CONF="/etc/hostapd/hostapd.conf"

// enable forwarding on our network card
* echo 1 > /proc/sys/net/ipv4/ip_forward
* echo 'net.ipv4.ip_forward=1' > /etc/sysctl.conf

// apply iptables rules to tell what network card to forward to which network card in what events by running these lines
* iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
* iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED, ESTABLISHED -j ACCEPT
* iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

// Save the settings
iptables-save > /etc/iptables.ipv4.nat

// start services
* service hostapd start
* service udhcpd start

//
* update-rc.d hostapd enable
* update-rc.d udhcpd enable
