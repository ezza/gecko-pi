#!/usr/bin/env bash

set -e

dashUrl="$DASHBOARD_URL"

if [[ -z "$dashUrl" ]] ; then
echo "Please set dashboard url like so:"
echo "  export DASHBOARD_URL='https://example.geckoboard.com/dashboards/someid'"
echo "and re-run this script with:"
echo "  curl https://github.com/ezza/gecko-pi/blob/master/install.sh | bash"
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

echo "Symlinking gnueabihf for chromium command line"
sudo ln -s /usr/lib/arm-linux-gnueabihf/nss/ /usr/lib/nss

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

source $rcBack

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

xAutostart=/etc/xdg/lxsession/LXDE-pi/autostart
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

echo "Setting resolution to 1080p"
bootConfig=/boot/config.txt
bootConfigBackup=$bakDir/config.txt
bootConfigTmp=$tmpDir/config.txt

if [[ ! -e $bootConfigBackup ]] ; then
  cp $bootConfig $bootConfigBackup
fi

echo "hdmi_group=1" >> bootConfigTmp
echo "hdmi_mode=16" >> bootConfigTmp
echo "hdmi_force_hotplug=1" >> bootConfigTmp
echo "config_hdmi_boost=4" >> bootConfigTmp
echo "disable_overscan=1" >> bootConfigTmp

sudo mv $bootConfigTmp $bootConfig

echo "Configuring lxsession"

autoStartConfigPath="$HOME/.config/lxsession/LXDE"
autoStartFile=$autoStartConfigPath/autostart

mkdir -p $autoStartConfigPath

echo "xset s noblank " > $autoStartFile
echo "xset s off " >> $autoStartFile
echo "xset -dpms" >> $autoStartFile

echo "Enabling brower autostart"

kioskFile="$HOME/ensure-kiosk.sh"

echo "#!/bin/bash" >> $kioskFile
echo "ps --no-headers -C chromium || DISPLAY=:0 chromium --kiosk --incognito --disable-infobars --disable-translate --enable-offline-auto-reload-visible-only $dashUrl" >> $kioskFile

cronCmd = "* * * * * $kioskFile"
(crontab -u $USER -l; echo $cronCmd ) | crontab -u $USER -

echo "All good!"
echo "Restarting your Pi!"

sudo shutdown -r now
