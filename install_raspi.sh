#!/bin/bash
#
# Usage:
# scp install.sh pi@<raspberrypi>: && ssh pi@<raspberrypi>
# chmod +x install.sh
#
# and run install.sh

C=`tput setaf 6`
NC=`tput sgr0`

clear -x
echo "$C#################################"
echo "# Welcome $(whoami)@$(hostname)"
echo "#################################$NC"

read -p "$C>Do rpi-update now? [Y/n] $NC" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]];then
    sudo rpi-update
    echo "$C>Done, please run install.sh again after reboot! $NC"
    sudo shutdown -r now
    sleep 5
    exit
fi

echo "$C>Set apt-cacher-ng Proxy IP (or leave empty): $NC"
read PROX
if [[ "$PROX" ]]; then
    echo "Acquire::http::Proxy \"http://$PROX:3142/\";"  | sudo tee /etc/apt/apt.conf.d/02proxy
    echo ">  /etc/apt/apt.conf.d/02proxy"
fi

echo "$C>Updating package lists...$NC"
sudo apt-get -q update

echo "$C>Upgrading...$NC"
sudo apt-get -qq -y upgrade

#####
echo "$C>Prerequisites...$NC"
#####
curl -L "https://gist.githubusercontent.com/lmzdev/21b683d4461f821107bced42a9d801fb/raw/" > ~/update.sh
chmod +x ~/update.sh


FILE=".ssh/id_rsa"
if [[ ! -f "$FILE" ]]; then
    echo "$C>SSH Setup...$NC"
    ssh-keygen #-b 3072
fi


#####
echo "$C>Installing new Packages...$NC"
#####
sudo apt-get -y -qq install dnsutils vim build-essential mc apt-transport-https net-tools toilet linuxlogo highlight htop tty-clock git git-lfs curl wget zsh


read -p "$C>Install python3, pip3 and GPIO dependencies? [Y/n] $NC" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt-get -y install python3-pip python-smbus wiringpi pigpio python-pigpio python3-pigpio raspi-gpio python-gpiozero python3-gpiozero python3-rpi.gpio i2c-tools python3-venv
    python --version
    python3 --versiondirmngr
    pip3 install virtualenv paho-mqtt RPi.GPIO
fi

read -p "$C>Install Node.js? [Y/n] $NC" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get -y install nodejs
    #sudo npm i -g npm@latest
fi

read -p "$C>Install Java JDK (OpenJDK 11)? [Y/n] $NC" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt-get -y install openjdk-11-jdk
fi

read -p "$C>Install cockpit (Web-Admin)? [Y/n] $NC" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt-get -y install cockpit
    sudo apt-get -y remove cockpit-packagekit # does not work -> remove
    sudo apt-get -y autoremove
fi

read -p "$C>Install Ookla Speedtest CLI? [Y/n] $NC" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]];then
    # if you run into errors, check if your apt proxy allows/bypasses https:// urls
    sudo apt-get -qq update && sudo apt-get -y install gnupg2 dirmngr
    INSTALL_KEY=379CE192D401AB61
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $INSTALL_KEY
    echo "deb https://ookla.bintray.com/debian generic main" | sudo tee  /etc/apt/sources.list.d/speedtest.list
    sudo apt-get -qq update && sudo apt-get -y install speedtest
fi

echo 
read -p "$C>Install minimal Raspi-Desktop (~1.5 GB)? [Y/n] $NC" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt-get -y install raspberrypi-ui-mods xinit
    sudo apt-get -y install firefox-esr mousepad gstreamer1.0-x gstreamer1.0-omx gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-alsa gstreamer1.0-libav qpdfview gtk2-engines alsa-utils \
        omxplayer raspberrypi-artwork policykit-1 gvfs rfkill chromium-browser rpi-chromium-mods gldriver-test fonts-droid-fallback fonts-liberation2 obconf arandr gparted lxterminal pi-package
fi

echo
#####
echo "$C>Shell and locale settings...$NC"
#####

curl -sL "https://gist.githubusercontent.com/lmzdev/41f545d9eb93c66d1ef72658ed7026c7/raw/" > ~/.bash_aliases
curl -sL "https://raw.githubusercontent.com/lmzdev/rpi_tools/main/.bashrc" > ~/.bashrc

sudo wget "https://raw.githubusercontent.com/6gk/fet.sh/master/fet.sh" -P "/usr/local/bin"
sudo chmod 755 "/usr/local/bin/fet.sh"


echo "$C>Raspi-Config settings in non-interactive mode...$NC"
sudo raspi-config nonint do_i2c 0
sudo raspi-config nonint do_onewire 0
sudo raspi-config nonint do_rgpio 0
sudo raspi-config nonint do_expand_rootfs

sudo dpkg-reconfigure locales

echo "$C>Change password (or leave empty): $NC"
read newpassw
if [[ "$newpassw" ]]; then
    echo "pi:$newpassw" | sudo chpasswd
fi

echo "$C>Change hostname (or leave empty): $NC"
read newhost
if [[ "$newhost" ]]; then
    hostn=$(hostname)
    sudo sed -i "s/$hostn/$newhost/g" /etc/hosts
    sudo sed -i "s/$hostn/$newhost/g" /etc/hostname
fi

echo
echo "$C>Finished, please reboot and raspi-config later!$NC"
echo
