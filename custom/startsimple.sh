#!/bin/sh

sudo /usr/bin/sessreg -d -l :0.0 -u /var/run/utmp user
xhost + si:localuser:root # Allow local user root only to access the diplay
sudo /usr/bin/sessreg -a -l :0.0 -u /var/run/utmp user

(sleep 8; /opt/xandros/bin/start_netserv) &
(sleep 16; /usr/local/bin/asusosd) &
sudo rm /tmp/nologin
xmodmap -e "add mod3 = Super_L"
xmodmap -e "clear Lock"
xmodmap -e "keycode 66 = Control_L"
xmodmap -e "keycode 37 = Control_L"
xmodmap -e "add Control = Control_L"
[ -f /usr/bin/dispwatch ] && /usr/bin/dispwatch &
display -window root /home/user/work/eee-setup/wallpaper/vivacalaca-asus.png
conky &

mkdir /tmp/emacs.d-saves

exec dwm
