#!/usr/bin/env bash
logDir=$HOME/.gecko_pi/log
bakDir=$HOME/.gecko_pi/bak
tmpDir=$HOME/.gecko_pi/tmp

autoStartConfigPath="/home/$USER/.config/lxsession/LXDE"
rm  $autoStartConfigPath/autostart
rm -r $autoStartConfigPath


xAutostart=/etc/xdg/lxsession/LXDE/autostart
xAutostartBackup=$bakDir/autostart
sudo mv $xAutostartBackup $xAutostart

mv $bakDir/bashrc $HOME/.bashrc

sudo apt-get remove chromium -y
sudo apt-get autoremove -y
