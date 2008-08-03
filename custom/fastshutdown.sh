#!/bin/sh

if [ "$1" = "--ask" ]
then
  zenity --question && sudo $0
  exit $?
fi

[ `id -u` = "0" ] || echo "Must be root."

/etc/init.d/mysql stop
/etc/init.d/apache2 stop

/usr/bin/killall --wait usbstorageapplet

/bin/kill -USR2 1
