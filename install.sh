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
echo "$C# Welcome $(whoami)@$(hostname)"
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

echo
echo "$C>Prerequisites...$NC"
curl -L "https://gist.githubusercontent.com/lmzdev/21b683d4461f821107bced42a9d801fb/raw/" > ~/update.sh
chmod +x ~/update.sh


FILE="/home/pi/.ssh/id_rsa"
if [[ ! -f "$FILE" ]]; then
    echo "$C>SSH Setup...$NC"
    ssh-keygen #-b 3072
fi

echo
echo "$C>Installing new Packages...$NC"
sudo apt-get -y -q install dnsutils vim build-essential mc apt-transport-https net-tools traceroute nmap toilet linuxlogo highlight htop tty-clock fzf git git-lfs curl wget zsh ca-certificates screen


read -p "$C>Install additional Python/Python3 dependencies? [Y/n] $NC" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt-get -y install python3-pip python-smbus python3-smbus wiringpi pigpio python-pigpio python3-pigpio python-gpiozero python3-gpiozero python3-rpi.gpio i2c-tools python3-venv
    python --version
    python3 --version
    echo
    pip3 install virtualenv paho-mqtt RPi.GPIO
fi

read -p "$C>Install Node.js? [Y/n] $NC" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get -y install nodejs
    sudo apt-get -y install npm
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
    curl -s https://install.speedtest.net/app/cli/install.deb.sh | sudo bash
    sudo apt-get -y install speedtest
fi

read -p "$C>Install minimal Raspbian-Desktop (~1.5 GB)? [Y/n] $NC" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt-get -y install raspberrypi-ui-mods xinit lightdm
    sudo apt-get -y install firefox-esr mousepad gstreamer1.0-x gstreamer1.0-omx gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-alsa gstreamer1.0-libav qpdfview gtk2-engines alsa-utils \
        omxplayer raspberrypi-artwork policykit-1 gvfs rfkill chromium-browser rpi-chromium-mods gldriver-test fonts-droid-fallback fonts-liberation2 obconf arandr gparted lxterminal pi-package
fi

echo
echo "$C>Shell settings...$NC"

echo "" | sudo tee /etc/motd
curl -sL "https://gist.githubusercontent.com/lmzdev/41f545d9eb93c66d1ef72658ed7026c7/raw/" > ~/.bash_aliases
curl -sL "https://gist.githubusercontent.com/lmzdev/c03befd8b90a5851c1d96d78904ed39a/raw/" > ~/.bash_prompt
curl -sL "https://raw.githubusercontent.com/lmzdev/install_raspi/main/.bashrc" > ~/.bashrc

#fet.sh is a minimal fetch script
sudo wget -q "https://raw.githubusercontent.com/6gk/fet.sh/master/fet.sh" -P "/usr/local/bin"
sudo chmod 755 "/usr/local/bin/fet.sh"

echo "$C>Raspi-Config settings in non-interactive mode...$NC"
sudo raspi-config nonint do_i2c 0
sudo raspi-config nonint do_onewire 0
sudo raspi-config nonint do_rgpio 0

sudo dpkg-reconfigure locales

echo "$C>Change password (or leave empty): $NC"
read newpassw
if [[ "$newpassw" ]]; then
    echo "pi:$newpassw" | sudo chpasswd
    unset newpassw
fi

echo "$C>Change hostname (or leave empty): $NC"
read newhost
if [[ "$newhost" ]]; then
    hostn=$(hostname)
    sudo sed -i "s/$hostn/$newhost/g" /etc/hosts
    sudo sed -i "s/$hostn/$newhost/g" /etc/hostname
fi

echo "$C>Finished, please reboot and raspi-config later!$NC"
echo
