#!/bin/sh
# A simple script to create hotspot in debian based systems
# by Sachin Oraon

# resize window
if [ `which resize` ]; then
	resize -s 42 66
fi

# check for required packages
packages(){
tput clear
echo "Checking for dependencies..."
echo ""
sleep 1
if [ "`which hostapd`" ]
then
	echo "Hostapd [installed]"
	varH=0
	sleep 1
else
	echo "Hostapd [not installed]"
	sleep 1
	varH=1
fi

if [ "`which udhcpd`" ]
then
	echo "udhcpd  [installed]"
	varU=0
else
	echo "udhcpd  [not installed]"
	varU=1
fi

if [ "$varH" = "1" ] || [ "$varU" = "1" ]; then
	echo ""
	echo "Okay..let's install 'em..."
	echo ""
	echo "Press enter to run apt-get"
	read enterkey
	sleep 1
	tput clear
	if [ "$varH" = "1" ]; then
		tput clear
		tput bold
		echo "---------------------------------------------"
		echo "Installing hostapd"
		echo "---------------------------------------------"
		sleep 1
		apt-get install hostapd -y
		echo -e "\033[0m"
	fi
	if [ "$varU" = "1" ]; then
		tput clear
		tput bold
		echo "---------------------------------------------"
		echo "Installing udhcpd"
		echo "---------------------------------------------"
		sleep 1
		apt-get install udhcpd -y
		echo -e "\033[0m"
	fi
	sleep 1
	packages
else
	echo ""	
	echo "Okay...we're good to go..."
	echo '0' > /etc/hs/packagesInstalled.dat
	sleep 2
fi
}


# check for root permissions
tput clear
id=`id`; 
id=`echo ${id#*=}`; 
id=`echo ${id%%\(*}`; 
id=`echo ${id%% *}`
if [ "$id" != "0" ] && [ "$id" != "root" ]; then
	sleep 1
	echo "Ohh Shit !!"
	echo "Script needs root permissions..."
	echo "Re-Run with adding 'sudo' at begining..."
	exit 1
else
	if [ ! `ls /etc/hs/ 2>/dev/null` ]; then 
		mkdir /etc/hs
	fi
fi

# flags
case "$1" in
	-r)
		tput clear
		echo "Okay...restoring your default configs.."
		sleep 1
		echo ""
		echo "* Logs cleared"
		rm -r -f /etc/hs 2>/dev/null
		echo "* Config cleared"
		echo ""

if [ -f /etc/udhcpd.conf.bak ]; then
	rm /etc/udhcpd.conf 2>/dev/null
	mv /etc/udhcpd.conf.bak /etc/udhcpd.conf 2>/dev/null
	echo "* /etc/udhcpd.conf restored";sleep 1
fi

if [ -f /etc/default/udhcpd.bak ]; then
	rm /etc/default/udhcpd 2>/dev/null
	mv /etc/default/udhcpd.bak /etc/default/udhcpd 2>/dev/null
	echo "* /etc/default/udhcpd restored"
fi

if [ -f /etc/hostapd/hostapd.conf.bak ]; then
	rm /etc/hostapd/hostapd.conf 2>/dev/null
	mv /etc/hostapd/hostapd.conf.bak /etc/hostapd/hostapd.conf 2>/dev/null
	echo "* /etc/hostapd/hostapd.conf restored";sleep 1
fi

if [ -f /etc/network/interfaces.bak ]; then
	rm /etc/network/interfaces 2>/dev/null
	mv /etc/network/interfaces.bak /etc/network/interfaces 2>/dev/null
	echo "* /etc/network/interfaces restored"
fi

if [ -f /etc/default/hostapd.bak ]; then
	rm /etc/default/hostapd 2>/dev/null
	mv /etc/default/hostapd.bak /etc/default/hostapd 2>/dev/null
	echo "* /etc/default/hostapd restored";sleep 1
fi

if [ -f /etc/iptables.ipv4.nat ]; then
	rm /etc/iptables.ipv4.nat 2>/dev/null
	iptables-restore < /etc/iptables-backup 2>/dev/null
	echo "* /etc/iptables-backup restored"
	echo ""
	echo "* Please reboot now to make things right..."
	echo ""
fi
exit 1
;;

-c)
	tput clear
echo "---------------------------------------------"
echo "|         Welcome to Hotspot Creator        |"
echo "---------------------------------------------"
echo "| This script  is for Debian  based systems |"
echo "| You need two interfaces, one for creating |"
echo "| an access point while other for providing |"
echo "| internet to the client devices. Your wifi |"
echo "| card  must support  AP(Master) mode to be |"
echo "| able to create hotspot.                   |"
echo "---------------------------------------------"	
echo "| Searching for saved configs...            |"
sleep 2
if [ -e /etc/hs/config.dat ]; then
echo "---------------------------------------------"
echo "| Details of previously configured AP       |"
echo "---------------------------------------------"
echo "* ssid = "$( cat /etc/hs/ssid.dat)
echo "* pass = "$( cat /etc/hs/pass.dat)
echo "---------------------------------------------"
echo "| Press Enter to run this config            |"
read enterkey
echo "---------------------------------------------"
service hostapd restart >> /dev/null
service udhcpd restart >> /dev/null

	if [ `which xterm` ]; then
		xterm -bg "#000000" -fg "#FFFFFF" -e hostapd -B /etc/hostapd/hostapd.conf
		sleep 1
		echo ""
		echo "* Failed ! Please try again after rebooting..."
		exit 1
	else
		hostapd -B /etc/hostapd/hostapd.conf
		sleep 20
	fi
else
	echo ""
	echo "---------------------------------------------"
	echo " No config found :("
	echo "---------------------------------------------"
	exit 1
fi
;;

-h)
tput clear
echo "---------------------------------------------"
echo "|         Welcome to Hotspot Creator        |"
echo "---------------------------------------------"
echo "| This script  is for Debian  based systems |"
echo "| You need two interfaces, one for creating |"
echo "| an access point while other for providing |"
echo "| internet to the client devices. Your wifi |"
echo "| card  must support  AP(Master) mode to be |"
echo "| able to create hotspot.                   |"
echo "---------------------------------------------" 
echo "| Available Options :                       |"
echo "|                                           |"
echo "| -r    To Restore (clears log & configs)   |"
echo "|                                           |"
echo "| -c    To run previously saved config      |"
echo "|                                           |"
echo "| -s    To stop running services            |"
echo "|                                           |"
echo "| -h    To display this help page           |"
echo "---------------------------------------------"
exit 1
;;

-s)
echo ""
	echo "* STOPPING SERVICES..."
	sleep 2
	rm /etc/network/interfaces 2>/dev/null
	service hostapd stop >> /dev/null
	service udhcpd stop >> /dev/null
	echo ""
	echo "* hostapd          [STOPPED]"
	echo "* udhcpd           [STOPPED]"
	if cp "/etc/network/interfaces.bak" "/etc/network/interfaces" 2>/dev/null ; then
		echo ""
		echo " * Startup entry removed"
		sleep 1
		echo "  Please reboot to apply changes !"
		exit 1
	else
		echo "* Failed to remove Startup entry....try again later !"
		echo ""
		exit 1
	fi
;;

*)
	;;
esac

# check for packages
if [ ! -e "/etc/hs/packagesInstalled.dat" ]; then
	packages
else
	packages
fi

backup(){
echo "|           BACKUP     [NOT FOUND]          |"
echo "---------------------------------------------"
sleep 1
echo "|           CREATING BACKUPS                |"
echo "---------------------------------------------"
sleep 1
rm /etc/hs/backedup.dat 2>/dev/null #remove old backup data
if cp "/etc/udhcpd.conf" "/etc/udhcpd.conf.bak" 2>/dev/null; then
	echo "| 1. /etc/udhcpd.conf              [DONE]   |">>/etc/hs/backedup.dat
	sleep 1
else
	echo "| 1. /etc/udhcpd.conf              [FAILED] |">>/etc/hs/backedup.dat
fi

if cp "/etc/default/udhcpd" "/etc/default/udhcpd.bak" 2>/dev/null; then
	echo "| 2. /etc/default/udhcpd           [DONE]   |">>/etc/hs/backedup.dat
else
	echo "| 2. /etc/default/udhcpd           [FAILED] |">>/etc/hs/backedup.dat
fi

if [ -e /etc/hostapd/hostapd.conf ]; then
	if cp "/etc/hostapd/hostapd.conf" "/etc/hostapd/hostapd.conf.bak" 2>/dev/null; then
		echo "| 3. /etc/hostapd/hostapd.conf     [DONE]   |">>/etc/hs/backedup.dat
	else
		echo "| 3. /etc/hostapd/hostapd.conf     [FAILED] |">>/etc/hs/backedup.dat
	fi
else
	echo "| 3. /etc/hostapd/hostapd.conf     [DONE]   |">>/etc/hs/backedup.dat;sleep 1
fi

if cp "/etc/network/interfaces" "/etc/network/interfaces.bak" 2>/dev/null; then
	echo "| 4. /etc/network/interfaces       [DONE]   |">>/etc/hs/backedup.dat
else
	echo "| 4. /etc/network/interfaces       [FAILED] |">>/etc/hs/backedup.dat
fi

if cp "/etc/default/hostapd" "/etc/default/hostapd.bak" 2>/dev/null; then
	echo "| 5. /etc/default/hostapd          [DONE]   |">>/etc/hs/backedup.dat
else
	echo "| 5. /etc/default/hostapd          [FAILED] |">>/etc/hs/backedup.dat
fi

if iptables-save > /etc/iptables-backup; then
	echo "| 6. current iptables rules        [DONE]   |">>/etc/hs/backedup.dat
else
	echo "| 6. current iptables rules        [FAILED] |">>/etc/hs/backedup.dat
fi
sleep 1
echo "---------------------------------------------">>/etc/hs/backedup.dat
cat /etc/hs/backedup.dat
}

# this is executed if previous config is found
if [ -e /etc/hs/config.dat ]; then
tput clear
echo "---------------------------------------------"
echo "|         Welcome to Hotspot Creator        |"
echo "---------------------------------------------"
echo "| This script  is for Debian  based systems |"
echo "| You need two interfaces, one for creating |"
echo "| an access point while other for providing |"
echo "| internet to the client devices. Your wifi |"
echo "| card  must support  AP(Master) mode to be |"
echo "| able to create hotspot.                   |"
echo "---------------------------------------------"
if [ -e /etc/hs/backedup.dat ]; then
echo "|           BACKUP     [FOUND]              |"
echo "---------------------------------------------"
	sleep 1
	cat /etc/hs/backedup.dat
else
	backup
fi
echo " Details of previously configured AP"
echo "---------------------------------------------"
echo " ssid = "$( cat /etc/hs/ssid.dat)
echo " pass = "$( cat /etc/hs/pass.dat)
echo "---------------------------------------------"
read -p " Do you want to run this config (Y/N) ? " yn
if [ "$yn" = "y" ] || [ "$yn" = "Y" ] ; then
	echo "---------------------------------------------"
	echo " * Starting services"
	service hostapd restart 2>/dev/null
	service udhcpd restart 2>/dev/null
	echo "---------------------------------------------"
	hostapd -B /etc/hostapd/hostapd.conf
else
	echo ""
	echo "Press Enter to go back...";read enterkey
	packages
fi
fi

# home
tput clear
echo "---------------------------------------------"
echo "|         Welcome to Hotspot Creator        |"
echo "---------------------------------------------"
echo "| This script  is for Debian  based systems |"
echo "| You need two interfaces, one for creating |"
echo "| an access point while other for providing |"
echo "| internet to the client devices. Your wifi |"
echo "| card  must support  AP(Master) mode to be |"
echo "| able to create hotspot.                   |"
echo "---------------------------------------------"
if [ -e /etc/hs/backedup.dat ]; then
echo "|           BACKUP     [FOUND]              |"
echo "---------------------------------------------"
	sleep 1
	cat /etc/hs/backedup.dat
else
	backup
fi

# scan interfaces
echo "      You have following interfaces"
echo "---------------------------------------------"
echo ""
sleep 1
if uname --all | grep -i kali >> /dev/null ; then
	ifconfig|grep -i multicast --color=never
else	
	ifconfig|grep -i ethernet --color=never
fi
echo ""

# menu
echo "---------------------------------------------"
echo ""
echo " 1 -- CREATE HOTSPOT"
echo ""
echo " 2 -- DISPLAY CONFIG"
echo ""
echo " 3 -- STOP HOTSPOT SERVICE"
echo ""
echo " 4 -- SHOW AVAILABLE FLAGS"
echo ""
echo " 5 -- EXIT"
echo ""
echo "---------------------------------------------"
read -p "Enter your option -- " choice

case "$choice" in
1)
# collecting info
echo "---------------------------------------------"
read -p "Interface for Hotspot   ? " ifaceAP
read -p "Interface with Internet ? " ifaceI
read -p "SSID for access point   ? " ssid
read -p "Password(min 8 chars)   ? " pass
echo "---------------------------------------------"
echo "Press Enter to continue ..."; read enterkey
# storing data for future use
echo $ssid>/etc/hs/ssid.dat
echo $pass>/etc/hs/pass.dat

# editing files
echo "---------------------------------------------"
echo "* Editing /etc/udhcpd.conf "
rm /etc/udhcpd.conf 2>/dev/null #removing old file
cat << EOF >/etc/udhcpd.conf
start 192.168.42.2 # This is the range of IPs that the hostspot will give to client devices.
end 192.168.42.254
interface $ifaceAP # The device uDHCP listens on.
remaining yes
opt dns 8.8.8.8 8.8.4.4 # The DNS servers client devices will use.
opt subnet 255.255.255.0
opt router 192.168.42.1 # Gateway IP
opt lease 864000 # 10 day DHCP lease time in seconds
EOF
sleep 1

echo "* Editing /etc/default/udhcpd"
rm /etc/default/udhcpd 2>/dev/null
echo '#DHCPD_ENABLED="no"' >> /etc/default/udhcpd
echo 'DHCPD_OPTS="-S"' >> /etc/default/udhcpd
ifconfig $ifaceAP 192.168.42.1 # give IP addr to AP interface
sleep 1
echo "* Editing /etc/hostapd/hostapd.conf "
cat << EOF >/etc/hs/hostapd.conf
interface=$ifaceAP
ssid=$ssid
hw_mode=g
channel=6
wpa=2
wpa_passphrase=$pass
wpa_key_mgmt=WPA-PSK
EOF
cp /etc/hs/hostapd.conf /etc/hostapd/hostapd.conf
sleep 1
# this is used to make the ifaceAP to stay in Master mode
echo "* Adding startup entries for "$ifaceAP" "
rm /etc/network/interfaces 2>/dev/null
cat << EOF >/etc/network/interfaces
auto lo
iface lo inet loopback
auto $ifaceAP

iface $ifaceAP inet static
  hostapd /etc/hostapd/hostapd.conf
  address 192.168.42.1
  netmask 255.255.255.0

up iptables-restore < /etc/iptables.ipv4.nat
EOF
sleep 1
rm /etc/default/hostapd 2>/dev/null
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' > /etc/default/hostapd
echo "* Enabling packet forwading on "$ifaceAP" "
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.conf

# creating iptables rules
echo "* Creating bridge between "$ifaceAP" and "$ifaceI" "
iptables -t nat -A POSTROUTING -o $ifaceI -j MASQUERADE
iptables -A FORWARD -i $ifaceI -o $ifaceAP -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $ifaceAP -o $ifaceI -j ACCEPT
# saving the above rules
sh -c "iptables-save > /etc/iptables.ipv4.nat"
sleep 1

# enable init links
update-rc.d hostapd enable >> /dev/null
update-rc.d udhcpd enable >> /dev/null

# done
echo "---------------------------------------------"
echo "* Configurations saved sucessfully !"
echo '0' > /etc/hs/config.dat
echo "---------------------------------------------"
echo "* Don't detach wireless interface."
echo "* If you can't find AP then run  sudo h.sh -c"
echo "  Please reboot to apply settings "
echo "  After reboot...you'll find your AP"
echo "---------------------------------------------"
;;

2)
	if [ -e /etc/hs/config.dat ]; then
echo " Details of previously configured AP"
echo "---------------------------------------------"
echo " ssid = "$( cat /etc/hs/ssid.dat)
echo " pass = "$( cat /etc/hs/pass.dat)
echo "---------------------------------------------"
echo ""
echo "Press Enter to go back";read enterkey
packages
else
	echo ""
	echo "oops...NO config found :("
	echo ""
	exit 1
fi
;;

3)
	echo ""
	echo "* STOPPING SERVICES..."
	sleep 2
	rm /etc/network/interfaces 2>/dev/null
	if cp "/etc/network/interfaces.bak" "/etc/network/interfaces" 2>/dev/null ; then
		echo ""
		service hostapd stop >> /dev/null
		service udhcpd stop >> /dev/null
		echo "* SERVICE          [STOPPED]"
		echo "  Please reboot to apply changes !"
		exit 1
	else
		echo "* Failed to STOP....try again later !"
		echo ""
		exit 1
	fi
;;
4)
echo "---------------------------------------------" 
echo "| Available Flags :                         |"
echo "|                                           |"
echo "| -r    To Restore (clears log & configs)   |"
echo "|                                           |"
echo "| -c    To run previously saved config      |"
echo "|                                           |"
echo "| -s    To stop running services            |"
echo "|                                           |"
echo "| -h    To display this help page           |"
echo "---------------------------------------------"
exit 1
;;
5)
echo "---------------------------------------------"	
echo "Hey `whoami` ... thanks for executing :) "
sleep 1
echo "See you soon..."
exit 1
;;

*)
echo ""
echo "ohh..seems like typo :("
;;
esac
