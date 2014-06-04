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

logDir=$HOME/.gecko_pi/log
bakDir=$HOME/.gecko_pi/bak
tmpDir=$HOME/.gecko_pi/tmp

mkdir -p $logDir
mkdir -p $bakDir
mkdir -p $tmpDir

echo "Welcome to Gecko Pi setup!"

if which chromium 2>&1 > /dev/null ; then
  echo "Chromium is already installed"
else
  echo "Installing Chromium browser"
  sudo apt-get update -q 2>&1 > $logDir/apt.log
  sudo apt-get install -y ttf-mscorefonts-installer chromium 2>&1 > $logDir/install.log
fi

# make sure xset is installed
if which xset 2>&1 > /dev/null; then
  echo "xset is installed"
else
  echo "Installing x11 utilities"
  sudo apt-get install -y x11-xserver-utils 2>&1 >> $logDir/install.log
fi

rcDest=$HOME/.bashrc
rcBack=$tmpDir/bashrc
rcTmp=$tmpDir/bashrc

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
xAutostartBackup=$bakDir/autostart
xAutostartTmp=$tmpDir/autostart

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

autoStartConfigPath="$HOME/.config/lxsession/LXDE"
autoStartFile=$autoStartConfigPath/autostart

mkdir -p $autoStartConfigPath

echo "xset s noblank " > $autoStartFile
echo "xset s off " >> $autoStartFile
echo "xset -dpms" >> $autoStartFile
echo "chromium --kiosk --incognito --disable-infobars --disable-translate $dashUrl" >> $autoStartFile

echo "All good!"
echo "Restarting your Pi!"

sudo shutdown -r now
