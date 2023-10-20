#!/bin/bash

output(){
    echo -e '\e[36m'$1'\e[0m';
}

scriptinfo(){
    clear
    output  "********************************************"
    output  "*             ProVision Security           *" 
    output  "*       Spectrum VMS First Boot Script     *" 
    output  "*  --------------------------------------  *" 
    output  "*             Updated October 2023         *" 
    output  "*  --------------------------------------  *"
    output  "*     Retail Technology Engineering Team   *"
    output  "********************************************" 
    output ""
}

checksudo(){
if [ "$(id -nu)" != "root" ]; then
    sudo -k
    pass=$(whiptail --backtitle "$brand Installer" --title "Authentication required" --passwordbox "Installing $brand requires administrative privilege. Please authenticate to begin the installation.\n\n[sudo] Password for user $USER:" 12 50 3>&2 2>&1 1>&3-)
    exec sudo -S -p '' "$0" "$@" <<< "$pass"
    exit 1
fi
}

brand_options() {
    output "Which brand will this NVR be deployed to?\n[1] Anytime Fitness\n[2] Waxing the City\n[3] Basecamp Fitness\n[4] The Bar Method"
    read brandchoice
    case $brandchoice in 
        1 ) installoption=1
            output "You selected: [1] - Anytime Fitness.\n"
            ;;
        2 ) installoption=2
            output "You selected: [2] - Waxing the City.\n"
            ;;
        3 ) installoption=3
            output "You selected: [3] - Basecamp Fitness.\n"
            ;;
        4 ) installoption=4
            output "You selected: [4] - The Bar Method.\n"
            ;;
        * ) output "You did not enter a a valid selection, please try again.\n"
            brand_options
    esac
}

set_hostname() {
    if [ "$installoption" = "1" ]; then
        output "Enter desired hostname: nvr1-af"
        read hostname
        hostnamectl set-hostname nvr1-af${hostname}
        echo nvr1-af${hostname} > /proc/sys/kernel/hostname
        sed -i 's/127.0.1.1.*/127.0.1.1\t'"nvr1-af${compname}"'/g' /etc/hosts
        output "Hostname set."
    elif [ "$installoption" = "2" ]; then
        output "Enter desired hostname: nvr1-wtc"
        read hostname
        hostnamectl set-hostname nvr1-wtc${hostname}
        echo nvr1-wtc${hostname} > /proc/sys/kernel/hostname
        sed -i 's/127.0.1.1.*/127.0.1.1\t'"nvr1-af${compname}"'/g' /etc/hosts
        output "Hostname set."
    elif [ "$installoption" = "3" ]; then
        output "Enter desired hostname: nvr1-bcf"
        read hostname
        hostnamectl set-hostname nvr1-bcf${hostname}
        echo nvr1-bcf${hostname} > /proc/sys/kernel/hostname
        sed -i 's/127.0.1.1.*/127.0.1.1\t'"nvr1-af${compname}"'/g' /etc/hosts
        output "Hostname set."
    elif [ "$installoption" = "4" ]; then
        output "Enter desired hostname: nvr1-tbm"
        read hostname
        hostnamectl set-hostname nvr1-tbm${hostname}
        echo nvr1-tbm${hostname} > /proc/sys/kernel/hostname
        sed -i 's/127.0.1.1.*/127.0.1.1\t'"nvr1-af${compname}"'/g' /etc/hosts
        output "Hostname set."
    fi
}

brand_convert() {
    if [ "$installoption" = "2" ]; then
        output "Running the Waxing the City conversion process. Please wait..."
        pkill -u club pid
        pkill -9 -u club
        sleep 10
        usermod -l studio club
        usermod -d /home/studio -m studio
        groupmod -n club studio
        chfn -f "studio" studio
        echo "studio:Smooth\$123" | chpasswd
    elif [ "$installoption" = "3" ]; then
        output "Running the Basecamp Fitness conversion process. Please wait..."
        pkill -u club pid
        pkill -9 -u club
        sleep 10
        usermod -l studio club
        usermod -d /home/studio -m studio
        groupmod -n club studio
        chfn -f "studio" studio
        echo "studio:HeartStrong\$123" | chpasswd
    elif [ "$installoption" = "4" ]; then
        output "Running the The Bar Method conversion process. Please wait..."
        pkill -u club pid
        pkill -9 -u club
        sleep 10
        usermod -l studio club
        usermod -d /home/studio -m studio
        groupmod -n club studio
        chfn -f "studio" studio
        echo "studio:Balance\$123" | chpasswd
    fi
}

enable_autologin() {
    output "Enabling auto-login. Please wait..."
    if [ "$installoption" = "1" ]; then
        groupadd -r autologin
        gpasswd -a club autologin
        sed -i 's/pvss/club/g' /etc/lightdm/lightdm.conf
    elif [ "$installoption" = "2" ] || [ "$installoption" = "3" ] || [ "$installoption" = "4" ]; then
        groupadd -r autologin
        gpasswd -a studio autologin
        sed -i 's/pvss/studio/g' /etc/lightdm/lightdm.conf
    fi
}

software_install() {
    output "Installing version 5 of DW Spectrum Server and Client. Please wait..."
    wget https://updates.digital-watchdog.com/digitalwatchdog/37133/linux/dwspectrum-server-5.1.0.37133-linux_x64.deb -O /tmp/dwspectrum-server.deb
    wget https://updates.digital-watchdog.com/digitalwatchdog/37133/linux/dwspectrum-client-5.1.0.37133-linux_x64.deb -O /tmp/dwspectrum-client.deb
    dpkg -i /tmp/dwspectrum-server.deb
    apt-get install -f 
    dpkg -i /tmp/dwspectrum-server.deb
    apt-get install -f 
    rm -rf /tmp/dwspectrum*

    output "Installing TeamViewer Host v15. Please wait..."
    wget https://download.teamviewer.com/download/linux/teamviewer-host_amd64.deb -O /tmp/tv-host.deb
    dpkg -i /tmp/tv-host.deb
    apt-get install -f
    rm -rf /tmp/tv-host.deb
}

#Execution Steps
scriptinfo
brand_options
set_hostname
#brand_convert
#enable_autologin
#software_install
esac