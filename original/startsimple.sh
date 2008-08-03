#!/bin/sh

sudo /usr/bin/sessreg -d -l :0.0 -u /var/run/utmp user
xhost + si:localuser:root # Allow local user root only to access the diplay

if ! [ -f /home/user/.firstrundone ]; then
	sudo /usr/bin/sessreg -a -l :0.0 -u /var/run/utmp user 
	sudo /usr/bin/firstrunwizard
	if [ $? -eq 0 ]; then
		touch /home/user/.firstrundone
	else
		sudo /bin/kill -USR2 1
	fi	 
elif [ -f /tmp/kdesession -a ! -f /home/user/.easysession ]; then
	sudo /usr/bin/sessreg -a -l :0.0 -u /var/run/utmp user 
	if [ ! -d /home/user/Desktop ]; then
	    if [ -d /home/.Desktop ]; then
		mv /home/user/.Desktop /home/user/Desktop
	    fi
	fi
	[ -f /usr/bin/dispwatch ] && /usr/bin/dispwatch &
	for i in /sys/block/s[dr]?/uevent ; do
		 sudo /bin/sh -c "echo add > $i"
	done
	sudo rm -f /tmp/kdesession /tmp/nologin
	exec startkde
else
	sudo /usr/bin/sessreg -a -l :0.0 -u /var/run/utmp user 
	if [ -d /home/user/Desktop ]; then
	    if [ -d /home/user/.Desktop.bak ]; then
		rm -rf /home/user/.Desktop.bak
	    fi
	    if [ -d /home/user/.Desktop ]; then
		mv /home/user/.Desktop /home/user/.Desktop.bak
	    fi
	    mv /home/user/Desktop /home/user/.Desktop
	fi
	if [ -f /home/user/.easysession ]; then
	 # we are switching from full to easy mode
	 for i in /sys/block/s[dr]?/uevent ; do
		 sudo /bin/sh -c "echo add > $i"
	 done
	fi	
	/opt/xandros/bin/AsusLauncher &
	sleep 2
	icewmtray &
	[ -n "$XIM_PROGRAM" ] && $XIM_PROGRAM &
	powermonitor &
	(sleep 5; minimixer) &
	networkmonitor2 ra0 &
	networkmonitor2 -i eth0 &
	networkmonitor2 -i ppp0 &
	(sleep 3; /usr/bin/keyboardstatus) &
	(sleep 8; /opt/xandros/bin/start_netserv) &
	(sleep 16; /usr/local/bin/asusosd) &
	sudo rm /tmp/nologin
	[ -f /usr/bin/dispwatch ] && /usr/bin/dispwatch &
	rm -f /tmp/.fastlaunch
	exec icewm
fi
