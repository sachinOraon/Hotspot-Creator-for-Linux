#!/bin/sh
# A simple script to create hotspot in debian based systems
# by Sachin Oraon

# resize window
if [ `which resize` ]; then
	resize -s 42 66 >/dev/null
fi

# check for root permissions
tput clear
id=`id`;
id=`echo ${id#*=}`;
id=`echo ${id%%\(*}`;
id=`echo ${id%% *}`
if [ "$id" != "0" ] && [ "$id" != "root" ]; then
	sleep 1
	echo "Ohh Shit !!"
	echo "Script needs \033[1mroot\033[0m permissions..."
	echo "Re-Run with adding \033[1msudo\033[0m at begining..."
	exit 1
else
	if ! `ls /etc/hs/ 2>/dev/null` ; then
		mkdir /etc/hs 2>/dev/null
	fi
fi

# check for required packages
packages(){
	tput clear
	echo "Checking for dependencies..."
	echo ""
	sleep 1
	if [ "`which hostapd`" ]
	then
		echo "Hostapd [\033[1minstalled\033[0m]"
		varH=0
		sleep 1
	else
		echo "Hostapd [\033[1mnot installed\033[0m]"
		sleep 1
		varH=1
	fi

	if [ "`which udhcpd`" ]
	then
		echo "udhcpd  [\033[1minstalled\033[0m]"
		varU=0
	else
		echo "udhcpd  [\033[1mnot installed\033[0m]"
		varU=1
	fi

if [ "$varH" = "1" ] || [ "$varU" = "1" ]; then
	echo ""
	echo "Okay..let's install 'em..."
	echo ""
	echo "Press enter to run \033[1mapt-get\033[0m"
	read enterkey
	apt-get update
	sleep 1
	tput clear
	if [ "$varH" = "1" ]; then
		tput clear
		echo "\033[1m---------------------------------------------\033[0m"
		echo "\033[1mInstalling hostapd\033[0m"
		echo "\033[1m---------------------------------------------\033[0m"
		sleep 1
		apt-get install hostapd -y
	fi
	if [ "$varU" = "1" ]; then
		tput clear
		echo "\033[1m---------------------------------------------\033[0m"
		echo "\033[1mInstalling udhcpd\033[0m"
		echo "\033[1m---------------------------------------------\033[0m"
		sleep 1
		apt-get install udhcpd -y
	fi
	sleep 1
	packages
else
	echo ""	
	echo "Okay...we're good to go..."
	echo '0' > /etc/hs/packagesInstalled.dat
	sleep 1
fi
} #packages() end

# flags
case "$1" in
-r)
	tput clear
	echo "Okay....restoring your \033[1mDefault\033[0m configs.."
	sleep 1
	echo ""
	echo "* Logs cleared"
	rm -r -f /etc/hs 2>/dev/null
	echo "* Config cleared"
	echo ""

	if [ -f /etc/udhcpd.conf.bak ]; then
		rm /etc/udhcpd.conf 2>/dev/null
		mv /etc/udhcpd.conf.bak /etc/udhcpd.conf 2>/dev/null
		echo "* /etc/udhcpd.conf          \033[1m[restored]\033[0m";sleep 1
	fi

	if [ -f /etc/default/udhcpd.bak ]; then
		rm /etc/default/udhcpd 2>/dev/null
		mv /etc/default/udhcpd.bak /etc/default/udhcpd 2>/dev/null
		echo "* /etc/default/udhcpd       \033[1m[restored]\033[0m"
	fi

	if [ -f /etc/hostapd/hostapd.conf.bak ]; then
		rm /etc/hostapd/hostapd.conf 2>/dev/null
		mv /etc/hostapd/hostapd.conf.bak /etc/hostapd/hostapd.conf 2>/dev/null
		echo "* /etc/hostapd/hostapd.conf \033[1m[restored]\033[0m";sleep 1
	fi

	if [ -f /etc/network/interfaces.bak ]; then
		rm /etc/network/interfaces 2>/dev/null
		mv /etc/network/interfaces.bak /etc/network/interfaces 2>/dev/null
		echo "* /etc/network/interfaces   \033[1m[restored]\033[0m"
	fi

	if [ -f /etc/default/hostapd.bak ]; then
		rm /etc/default/hostapd 2>/dev/null
		mv /etc/default/hostapd.bak /etc/default/hostapd 2>/dev/null
		echo "* /etc/default/hostapd      \033[1m[restored]\033[0m";sleep 1
	fi

	if [ -f /etc/iptables.ipv4.nat ]; then
		rm /etc/iptables.ipv4.nat 2>/dev/null
		iptables-restore < /etc/iptables-backup 2>/dev/null
		echo "* /etc/iptables-backup      \033[1m[restored]\033[0m"
		echo ""
		echo "* Please \033[1mreboot\033[0m now to make things right..."
		echo ""
	fi
exit 1
;;

-c)
	tput clear
	echo "---------------------------------------------"
	echo "|         \033[1mWelcome to Hotspot Creator\033[0m        |"
	echo "---------------------------------------------"
	echo "| This script  is for \033[1mDebian\033[0m  based systems |"
	echo "| You need \033[1mtwo\033[0m interfaces, one for creating |"
	echo "| an access point while other for providing |"
	echo "| internet to the client devices. Your wifi |"
	echo "| card  must support  \033[1mAP(Master)\033[0m mode to be |"
	echo "| able to create hotspot.                   |"
	echo "---------------------------------------------"	
	echo "| Searching for saved configs...            |"
	sleep 2
	if [ -e /etc/hs/config.dat ]; then
		echo "---------------------------------------------"
		echo "| Details of previously configured AP       |"
		echo "---------------------------------------------"
		echo "\t\033[1mssid = "$( cat /etc/hs/ssid.dat)
		if [ -e /etc/hs/pass.dat ]; then
			echo "*\tpass = "$( cat /etc/hs/pass.dat)"\033[0m"
		else
			echo "\t\033[1m[OPEN NETWORK]\033[0m"
		fi
		echo "---------------------------------------------"
		echo "  Press \033[1mEnter\033[0m to run this config"
		read enterkey
		echo "---------------------------------------------"
		sleep 1
		/etc/init.d/udhcpd stop
		sleep 1
		/etc/init.d/udhcpd start
		sleep 1
		/etc/init.d/hostapd start
		echo "---------------------------------------------"
		xterm -bg "#000000" -fg "#FFFFFF" -hold -e hostapd /etc/hostapd/hostapd.conf
		sleep 1
		echo ""
		echo "* Oops....hostapd daemon window \033[1mclosed\033[0m !!!"
		exit 1
	else
		echo ""
		echo "---------------------------------------------"
		echo " \033[1mNO\033[0m config found :("
		echo "---------------------------------------------"
	fi
	exit 1
;;

-h)
	tput clear
	echo "---------------------------------------------"
	echo "|         \033[1mWelcome to Hotspot Creator\033[0m        |"
	echo "---------------------------------------------"
	echo "| This script  is for \033[1mDebian\033[0m  based systems |"
	echo "| You need \033[1mtwo\033[0m interfaces, one for creating |"
	echo "| an access point while other for providing |"
	echo "| internet to the client devices. Your wifi |"
	echo "| card  must support  \033[1mAP(Master)\033[0m mode to be |"
	echo "| able to create hotspot.                   |"
	echo "---------------------------------------------" 
	echo "| Available Options :                       |"
	echo "|                                           |"
	echo "| \033[1m-r\033[0m    To Restore (clears log & configs)   |"
	echo "|                                           |"
	echo "| \033[1m-c\033[0m    To run previously saved config      |"
	echo "|                                           |"
	echo "| \033[1m-s\033[0m    To stop running services            |"
	echo "|                                           |"
	echo "| \033[1m-h\033[0m    To display this help page           |"
	echo "---------------------------------------------"
	exit 1
;;

-s)
	echo ""
	echo "* STOPPING SERVICES..."
	sleep 2
	rm /etc/network/interfaces 2>/dev/null
	/etc/init.d/hostapd stop >> /dev/null
	/etc/init.d/udhcpd stop >> /dev/null
	echo ""
	echo "* hostapd          \033[1m[STOPPED]\033[0m"
	echo "* udhcpd           \033[1m[STOPPED]\033[0m"
	if cp "/etc/network/interfaces.bak" "/etc/network/interfaces" 2>/dev/null ; then
		echo ""
		echo " * Startup entry \033[1mremoved\033[0m"
		sleep 1
		echo "  Please \033[1mreboot\033[0m to apply changes !"
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
echo "|           BACKUP     \033[1m[NOT FOUND]\033[0m          |"
echo "---------------------------------------------"
sleep 1
echo "|           CREATING BACKUPS                |"
echo "---------------------------------------------"
sleep 1
rm /etc/hs/backedup.dat 2>/dev/null #remove old backup data
if cp "/etc/udhcpd.conf" "/etc/udhcpd.conf.bak" 2>/dev/null; then
	echo "| 1. /etc/udhcpd.conf              \033[1m[DONE]\033[0m   |">>/etc/hs/backedup.dat
	sleep 1
else
	echo "| 1. /etc/udhcpd.conf              \033[1m[FAILED]\033[0m |">>/etc/hs/backedup.dat
fi

if cp "/etc/default/udhcpd" "/etc/default/udhcpd.bak" 2>/dev/null; then
	echo "| 2. /etc/default/udhcpd           \033[1m[DONE]\033[0m   |">>/etc/hs/backedup.dat
else
	echo "| 2. /etc/default/udhcpd           [FAILED] |">>/etc/hs/backedup.dat
fi

if [ -e /etc/hostapd/hostapd.conf ]; then
	if cp "/etc/hostapd/hostapd.conf" "/etc/hostapd/hostapd.conf.bak" 2>/dev/null; then
		echo "| 3. /etc/hostapd/hostapd.conf     \033[1m[DONE]\033[0m   |">>/etc/hs/backedup.dat
	else
		echo "| 3. /etc/hostapd/hostapd.conf     [FAILED] |">>/etc/hs/backedup.dat
	fi
else
	echo "| 3. /etc/hostapd/hostapd.conf     \033[1m[DONE]\033[0m   |">>/etc/hs/backedup.dat;sleep 1
fi

if cp "/etc/network/interfaces" "/etc/network/interfaces.bak" 2>/dev/null; then
	echo "| 4. /etc/network/interfaces       \033[1m[DONE]\033[0m   |">>/etc/hs/backedup.dat
else
	echo "| 4. /etc/network/interfaces       [FAILED] |">>/etc/hs/backedup.dat
fi

if cp "/etc/default/hostapd" "/etc/default/hostapd.bak" 2>/dev/null; then
	echo "| 5. /etc/default/hostapd          \033[1m[DONE]\033[0m   |">>/etc/hs/backedup.dat
else
	echo "| 5. /etc/default/hostapd          [FAILED] |">>/etc/hs/backedup.dat
fi

if iptables-save > /etc/iptables-backup; then
	echo "| 6. current iptables rules        \033[1m[DONE]\033[0m   |">>/etc/hs/backedup.dat
else
	echo "| 6. current iptables rules        [FAILED] |">>/etc/hs/backedup.dat
fi

sleep 1
echo "---------------------------------------------">>/etc/hs/backedup.dat
cat /etc/hs/backedup.dat
} #backup() end

# this is executed if previous config is found
if [ -e /etc/hs/config.dat ]; then
	tput clear
	echo "---------------------------------------------"
	echo "|         \033[1mWelcome to Hotspot Creator\033[0m        |"
	echo "---------------------------------------------"
	echo "| This script  is for Debian  based systems |"
	echo "| You need two interfaces, one for creating |"
	echo "| an access point while other for providing |"
	echo "| internet to the client devices. Your wifi |"
	echo "| card  must support  \033[1mAP(Master)\033[0m mode to be |"
	echo "| able to create hotspot.                   |"
	echo "---------------------------------------------"
	if [ -e /etc/hs/backedup.dat ]; then
		echo "|           BACKUP     \033[1m[FOUND]\033[0m              |"
		echo "---------------------------------------------"
		sleep 1
		cat /etc/hs/backedup.dat
	else
		backup
	fi
	echo " Details of previously configured AP"
	echo "---------------------------------------------"
	if [ -e /etc/hs/ssid.dat ]; then
		echo "\t\033[1mssid\033[0m = "$( cat /etc/hs/ssid.dat)
	fi	
	if [ -e /etc/hs/pass.dat ]; then
		echo "\t\033[1mpass = \033[0m"$( cat /etc/hs/pass.dat)
	else
		echo "\t\033[1m[OPEN NETWORK]\033[0m"
	fi
	echo "---------------------------------------------"
	read -p " Do you want to run this config (Y/N) ? " yn
	if [ "$yn" = "y" ] || [ "$yn" = "Y" ] ; then
		echo "---------------------------------------------"
		sleep 1
		/etc/init.d/udhcpd stop
		sleep 1
		/etc/init.d/udhcpd start
		sleep 1
		/etc/init.d/hostapd start
		echo "---------------------------------------------"
		xterm -bg "#000000" -fg "#FFFFFF" -hold -e hostapd /etc/hostapd/hostapd.conf
		echo "* Oops....hostapd daemon window \033[1mclosed\033[0m !!!"
		exit 1
	else
		echo ""
		echo "Okay...then press \033[1mEnter\033[0m to go back...";read enterkey
		packages
	fi
fi

# initial setup
tput clear
echo "---------------------------------------------"
echo "|         \033[1mWelcome to Hotspot Creator\033[0m        |"
echo "---------------------------------------------"
echo "| This script  is for \033[1mDebian\033[0m  based systems |"
echo "| You need \033[1mtwo\033[0m interfaces, one for creating |"
echo "| an access point while other for providing |"
echo "| internet to the client devices. Your wifi |"
echo "| card  must support  \033[1mAP(Master)\033[0m mode to be |"
echo "| able to create hotspot.                   |"
echo "---------------------------------------------"
if [ -e /etc/hs/backedup.dat ]; then
	echo "|           BACKUP     \033[1m[FOUND]\033[0m              |"
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
if uname --all | grep -i kali > /dev/null ; then
	ifconfig|grep -i multicast --color=never
else	
	ifconfig|grep -i ethernet --color=never
fi
echo ""

# menu
echo "---------------------------------------------"
echo ""
echo " \033[1m1\033[0m -- CREATE HOTSPOT"
echo ""
echo " \033[1m2\033[0m -- DISPLAY CONFIG"
echo ""
echo " \033[1m3\033[0m -- STOP HOTSPOT SERVICE"
echo ""
echo " \033[1m4\033[0m -- SHOW AVAILABLE FLAGS"
echo ""
echo " \033[1m5\033[0m -- EXIT"
echo ""
echo "---------------------------------------------"
read -p "Enter your option -- " choice
case "$choice" in
1)
	# collecting info
	echo "---------------------------------------------"
	read -p "Interface for Hotspot          ? " ifaceAP
	read -p "Interface with Internet        ? " ifaceI
	read -p "SSID for access point          ? " ssid
	echo $ssid>/etc/hs/ssid.dat
	read -p "Do you want OPEN network (Y/N) ? " sec

	if [ $sec = "Y" ] || [ $sec = "y" ]; then
		echo "---------------------------------------------"
		echo "Press \033[1mEnter\033[0m to continue ..."; read enterkey
		echo "---------------------------------------------"
		echo "* Editing /etc/hostapd/hostapd.conf "
cat << EOF >/etc/hs/hostapd.conf
interface=$ifaceAP
ssid=$ssid
hw_mode=g
channel=6
EOF
		cp /etc/hs/hostapd.conf /etc/hostapd/hostapd.conf
		sleep 1
	else
		read -p "Password(min 8 chars)         ? " pass
		echo $pass>/etc/hs/pass.dat
		echo "---------------------------------------------"
		echo "Press \033[1mEnter\033[0m to continue ..."; read enterkey
		echo "---------------------------------------------"
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
	fi

# editing files
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
sleep 1

# this is used to make the ifaceAP to stay in Master mode
echo "* Adding startup entries for $ifaceAP"
rm /etc/network/interfaces 2>/dev/null
cat << EOF >/etc/network/interfaces
auto lo
iface lo inet loopback

auto $ifaceAP
iface $ifaceAP inet static
address 192.168.42.1
netmask 255.255.255.0

up iptables-restore < /etc/iptables.ipv4.nat
EOF
sleep 1

echo "* Enabling packet forwading on $ifaceAP"
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.conf
# ap details
echo "*  HOTSPOT DETAILS"
echo "-- Gateway addr   = 192.168.42.1"
echo "-- Broadcast addr = 192.168.42.255"
echo "-- Netmask        = 255.255.255.0"
# creating iptables rules
echo "* Creating bridge between $ifaceAP and $ifaceI"
iptables -t nat -A POSTROUTING -o $ifaceI -j MASQUERADE
iptables -A FORWARD -i $ifaceI -o $ifaceAP -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $ifaceAP -o $ifaceI -j ACCEPT
# saving the above rules
sh -c "iptables-save > /etc/iptables.ipv4.nat"
sleep 1
# done
echo "---------------------------------------------"
echo "* Configurations \033[1msaved\033[0m successfully !"
echo '0' > /etc/hs/config.dat
echo "---------------------------------------------"
echo "* Don't detach wireless interface."
echo "* Please \033[1mreboot\033[0m to apply settings "
echo "* After reboot run  \033[1msudo h.sh -c\033[0m"
echo "---------------------------------------------"
exit 1
;;

2)
if [ -e /etc/hs/config.dat ]; then
	echo "---------------------------------------------"
	echo " Details of previously configured AP"
	echo "---------------------------------------------"
	if [ -e /etc/hs/ssid.dat ]; then
		echo "\t\033[1mssid\033[0m = "$( cat /etc/hs/ssid.dat)
	fi
	if [ -e /etc/hs/pass.dat ]; then
		echo "\t\033[1mpass\033[0m = "$( cat /etc/hs/pass.dat)
	else
		echo "\t\033[1m[OPEN NETWORK]\033[0m"
	fi
	echo " \033[1mGateway\033[0m addr   = 192.168.42.1"
	echo " \033[1mBroadcast\033[0m addr = 192.168.42.255"
	echo " \033[1mNetmask\033[0m        = 255.255.255.0"
	echo "---------------------------------------------"
	echo ""
	echo "Press \033[1mEnter\033[0m to go Back...";read enterkey
	packages
else
	echo ""
	echo "oops...\033[1mNO\033[0m config found :("
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
		/etc/init.d/hostapd stop >> /dev/null
		/etc/init.d/udhcpd stop >> /dev/null
		echo "* SERVICE          \033[1m[STOPPED]\033[0m"
		echo "  Please \033[1mreboot\033[0m to apply changes !"
		exit 1
	else
		echo "* Failed to \033[1mSTOP\033[0m....try again later !"
		echo ""
		exit 1
	fi
;;
4)
echo "---------------------------------------------" 
echo "| Available Flags :                         |"
echo "|                                           |"
echo "| \033[1m-r\033[0m    To Restore (clears log & configs)   |"
echo "|                                           |"
echo "| \033[1m-c\033[0m    To run previously saved config      |"
echo "|                                           |"
echo "| \033[1m-s\033[0m    To stop running services            |"
echo "|                                           |"
echo "| \033[1m-h\033[0m    To display this help page           |"
echo "---------------------------------------------"
exit 1
;;

5)
echo "---------------------------------------------"
echo "Hey `whoami` ... thanks for executing :) "
echo "See you soon..."
exit 1
;;

*)
echo "---------------------------------------------"
echo ""
echo "ohh..seems like \033[1mtypo\033[0m :("
exit 1
;;
esac
