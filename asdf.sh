#!/bin/bash

scriptinfo(){
    whiptail --title "Script Information" --ok-button "Let's Go!" --msgbox "This script prepares the VisionPro for deployment. \n\n\nThis script was last updated on October 19, 2023." 16 60 3>&2 2>&1 1>&3
}

checksudo(){
if [ "$(id -nu)" != "root" ]; then
    sudo -k
    pass=$(whiptail --backtitle "$brand Installer" --title "Authentication required" --passwordbox "Installing $brand requires administrative privilege. Please authenticate to begin the installation.\n\n[sudo] Password for user $USER:" 12 50 3>&2 2>&1 1>&3-)
    exit
    exec sudo -S -p /home/log/asdf.sh
fi
}

install_option_brand() {
    brand_config=$(
        whiptail --backtitle "VisionPro NVR First Boot Script - October 2023" --title "Brand Selection" --menu "Which brand will this NVR be deployed to?" 16 60 4 \
        "AF" "Anytime Fitness" \
        "WTC" "Waxing the City" \
        "BCF" "Basecamp Fitness" \
        "TBM" "The Bar Method" 3>&2 2>&1 1>&3
    )
}

install_option_staticip() {
    netpackage_config=$(
        whiptail --title "Network Package" --yesno "Does this location have a ProVision Network Package?" 16 60 3>&2 2>&1 1>&3
    )
    netpackage_config=$?
}

install_option_ipmi() {

    if [ "$netpackage_config" = "0" ]; then
        ipmi_config=$(
            whiptail --title "IPMI Configuration" --yesno "Do you wish to configure the IPMI? This configures the Static IP, IPMI hostname, and users." 16 60 3>&2 2>&1 1>&3
        )
    else
        ipmi_config=$(
            whiptail --title "IPMI Configuration" --yesno "Do you wish to configure the IPMI? This configures the IPMI hostname and users." 16 60 3>&2 2>&1 1>&3
        )
    fi
    ipmi_config=$?
}

set_hostname() {
    if [ "$brand_config" = "AF" ]; then
        brandhost="nvr1-af"
    elif [ "$brand_config" = "WTC" ]; then
        brandhost="nvr1-wtc"
    elif [ "$brand_config" = "BCF" ]; then
        brandhost="nvr1-bcf"
    elif [ "$brand_config" = "TBM" ]; then
        brandhost="nvr1-tbm"
    fi
        
    hostname=$(whiptail --title "Configure Hostname" --inputbox "Enter desired hostname for this NVR:" 16 100 "$brandhost" 10 30 3>&1 1>&2 2>&3)
    exitstatus=$?

    if [ "$exitstatus" = "1" ]; then
        exit
    else
        hostnamectl set-hostname ${hostname}
        echo ${hostname} > /proc/sys/kernel/hostname
        sed -i 's/127.0.1.1.*/127.0.1.1\t'"${hostname}"'/g' /etc/hosts
        new_hostname=$(hostname -s)
        whiptail --ok-button Next --title "Configure Hostname" --msgbox "Hostname set to $new_hostname" 16 60
    fi
}

brand_convert() {
    whiptail --title "Brand Conversion" --msgbox "Running brand conversion. Please wait..." 16 60

    if [ "$brand_config" = "AF" ]; then
        busername="club"
        bpassword="Anytime\$123"
    elif [ "$brand_config" = "WTC" ]; then
        busername="studio"
        bpassword="Smooth\$123"
    elif [ "$brand_config" = "BCF" ]; then
        busername="studio"
        bpassword="HeartStrong\$123"
    elif [ "$brand_config" = "TBM" ]; then
        busername="studio"
        bpassword="Balance\$123"
    fi
 
    if [ "$brand_config" = "WTC" ] || [ "$brand_config" = "BCF" ] || [ "$brand_config" = "TBM" ]; then
        pkill -u club pid
        # pkill -9 -u club
        # sleep 10
        # usermod -l studio club
        # usermod -d /home/studio -m studio
        # groupmod -n club studio
        # chfn -f "studio" studio
    fi

    # echo "$busername:$bpassword" | chpasswd

    whiptail --ok-button "Next" --title "Brand Conversion" --msgbox "Brand conversion complete." 16 60
}

enable_autologin() {
    output "Enabling auto-login. Please wait..."

    groupadd -r autologin
    gpasswd -a $busername autologin
    sed -i "s/pvss/$busername/g" /etc/lightdm/lightdm.conf
}

software_install() {
    # Install Required Packages
    apt install -y libminizip1 cifs-utils net-tools
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

do_ipmi_config() {
    # -user add: when adding a user, follow -user add <id of user> username password <permissions level>. 4 = Admin, 3 = Operator

    ipmicfg -hostname "NVR-IPMI"
    ipmicfg -user setpwd 2 Pr0v@dmin#1!

    ipmicfg -user add 3 pvss M@sterM1nd123 4
    ipmicfg -user add 4 installer techs1988 2

    # ipmicfg -m 192.168.5.245
    # ipmicfg -k 255.255.255.0
    # ipmicfg -g 192.168.5.1

}

do_harden_tasks() {
    apt-get update
    apt-get upgrade -y

    apt purge -y telnet cups modemanager whoopsie zeitgeist-core zeitgeist-datahub


}

do_cleanup() {

}

#Execution Steps
scriptinfo
install_option_brand
install_option_staticip
install_option_ipmi
set_hostname
#brand_convert
#enable_autologin
#software_install