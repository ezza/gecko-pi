#!/usr/bin/env bash

set -e

dashUrl="$DASHBOARD_URL"

if [[ -z "$dashUrl" ]] ; then
echo "Please set dashboard url like so:"
echo "  export DASHBOARD_URL='https://example.geckoboard.com/dashboards/someid'"
echo "and re-run this script with:"
echo "  curl https://github.com/geckoboard/gecko-pi/blob/master/install.sh | bash"
exit 1
fi
piUser="$USER"

echo "Welcome to Gecko Pi setup!"

if which chromium 2>&1 > /dev/null ; then
  echo "Chromium is already installed"
else
  # TODO silence apt output,unless errors
  echo "Installing chromium browser"
  sudo apt-get update -q 2>&1 > .apt.log
  sudo apt-get install -y ttf-mscorefonts-installer chromium 2>&1 > .install.log
fi

# /etc/rc.local
rcDest=~/.bashrc
rcBack=~/.bashrc.bak
rcTmp=/tmp/bashrc

# make backup
if [[ ! -e $rcBack ]] ; then
  cp $rcDest $rcBack
fi

echo "Disabling screen power saving"

cat <<EOF > $rcTmp
#!/bin/sh -e
if [[ -n "\$DISPLAY" ]] ; then
  startx
  sleep 5
  xset s off
  xset -dpms
  xset s noblank

fi
EOF

mv -f $rcTmp $rcDest

echo "Disabling screensaver"

xAutostart=/etc/xdg/lxsession/LXDE/autostart
xAutostartBackup=~/.autostart.bak
xAutostartTmp=/tmp/autostart

if [[ ! -e $xAutostartBackup ]] ; then
  cp $xAutostart $xAutostartBackup
fi

if grep xscreensaver $xAutostart 2>&1 > /dev/null ; then
  grep -v xscreensaver $xAutostart > $xAutostartTmp
	echo "@xset s noblank " >> $xAutostartTmp
	echo "@xset s off " >> $xAutostartTmp
	echo "@xset -dpms" >> $xAutostartTmp
  sudo mv $xAutostartTmp $xAutostart
fi

echo "Setting up browser autostart"

autoStartConfigPath="/home/$piUser/.config/lxsession/LXDE"
autoStartFile=$autoStartConfigPath/autostart

mkdir -p $autoStartConfigPath

echo "xset s noblank " > $autoStartFile
echo "xset s off " >> $autoStartFile
echo "xset -dpms" >> $autoStartFile
echo "chromium --kiosk --incognito $dashUrl" >> $autoStartFile

echo "All good!"
echo "Restarting your Pi!"

sudo shutdown -r now
