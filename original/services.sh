#!/bin/sh
PATH="/lib/init:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"

swapon LABEL=SWAP

# On this system X takes 1 second to start
sleep 1

rm -fr /dev/disks/Removable/* /dev/cdroms/*

#start networking first
if [ -e /proc/sys/net/ipv4/conf/all/rp_filter ] ; then 
	for f in /proc/sys/net/ipv4/conf/*/rp_filter; do
		echo 1 > $f 
	done
fi

# Clean up hosts file
sed -i '/# lan[0-9][0-9]*$/d' /etc/hosts

# We do not want the connection system dialog at startup
touch /tmp/xandrosncs_no_status_dialog
if [ -x /opt/xandros/bin/xandrosncs-control -a -x /opt/xandros/bin/xandrosncs-servicedb ]; then
	# remove the temporary connections.
	LST_SERVICEID=`sudo /opt/xandros/bin/xandrosncs-servicedb --list | grep -v "^ID[ \t]*TYPE" | awk '{print $1}'`
	for SERVICEID in $LST_SERVICEID; do
		TEMP=`sudo /opt/xandros/bin/xandrosncs-servicedb --id "$SERVICEID" --get TEMPORARY_SERVICE`
		if [ $? -eq 0 ]; then
			VALUE=`echo $TEMP | cut -f 2 -d =`
			if [ "$VALUE" == "1" -o "$VALUE" == "true" -o "$VALUE" == "yes" ]; then
				#echo "Erasing temporary connection $SERVICEID"
				sudo /opt/xandros/bin/xandrosncs-servicedb --remove $SERVICEID
			fi
		fi
	done
fi

echo "">/proc/sys/kernel/hotplug
/sbin/udevd --daemon

# Always enable wireless (in case it was disabled)
#echo 1 > /proc/acpi/asus/wlan
   
# Loop over every line in /etc/modules.
grep '^[^#]' /etc/modules | \
while read module args; do
	[ "$module" ] || continue
	modprobe $module $args > /dev/null 2>&1 || true
done

modprobe usbhid
modprobe uhci-hcd
modprobe ehci-hcd
mount -t usbfs usbfs /proc/bus/usb

/sbin/start-stop-daemon --start --quiet --exec /usr/sbin/acpid -- -c /etc/acpi/events -s /var/run/acpid.socket -l /dev/null

modprobe pciehp pciehp_force=1
sleep 2
/usr/sbin/wlan_on_boot.sh ra0 > /tmp/wlan_on_boot.log 2>&1

alsactl restore
#aplay /usr/share/sounds/silence.wav

sleep 2
modprobe usb-storage

chown root:lpadmin /usr/share/cups/model 2>/dev/null || true
chmod 3775 /usr/share/cups/model 2>/dev/null || true
mkdir -p /var/run/cups
start-stop-daemon --start --quiet --oknodo --pidfile /var/run/cups/cupsd.pid --exec /usr/sbin/cupsd

if [ -f /etc/fastservices ]; then
	for i in `cat /etc/fastservices`; do
		/usr/sbin/invoke-rc.d $i start
	done
fi

# Simulate ACPI event for AC state
if grep -q on-line /proc/acpi/ac_adapter/AC0/state; then
	/etc/acpi/hotkey.sh null null 00000050
else
	/etc/acpi/hotkey.sh null null 00000051
fi

start-stop-daemon --start --quiet --oknodo --exec /sbin/portmap

# Store samba run state in /tmp, as it gets written to frequently
mkdir -p /tmp/.samba
/usr/sbin/invoke-rc.d samba start

# Start the Xandros Software Update Service
/usr/sbin/invoke-rc.d xandros-update-service start

/sbin/memd

# Enhanced Intel SpeedStep Technology driver
modprobe acpi-cpufreq

# Mount root ro and start automounter for the chrooted program installations
! [ -d /ro ] && mkdir /ro
mount /dev/sda1 /ro -o ro
/etc/init.d/autofs start

# Clean up the file that disables connection status window
rm -f /tmp/xandrosncs_no_status_dialog
