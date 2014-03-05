#!/usr/bin/env bash
sudo mv ~/.bashrc.bak ~/.bashrc

autoStartConfigPath="/home/$USER/.config/lxsession/LXDE"
rm  $autoStartConfigPath/autostart
rm -r $autoStartConfigPath


xAutostart=/etc/xdg/lxsession/LXDE/autostart
xAutostartBackup=~/.autostart.bak
sudo mv $xAutostartBackup $xAutostart

sudo apt-get remove chromium -y
sudo apt-get autoremove -y
