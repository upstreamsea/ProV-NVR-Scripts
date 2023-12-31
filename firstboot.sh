#!/bin/bash

pv_log="/home/pvss/firstboot_log.txt"
version="1.1.0 - December 2023"
dw_buildnumber="37512"
dw_clientpackage="dwspectrum-client-5.1.1.37512-linux_x64.deb"
dw_serverpackage="dwspectrum-server-5.1.1.37512-linux_x64.deb"

install_option_brand() {
    brand_config=$(
        whiptail --backtitle "VisionPro NVR First Boot Script - $version" --title "Brand Selection" --menu "Which brand will this NVR be deployed to?" 16 60 4 \
        "AF" "Anytime Fitness" \
        "WTC" "Waxing the City" \
        "BCF" "Basecamp Fitness" \
        "TBM" "The Bar Method" 3>&2 2>&1 1>&3
    )
}

install_option_netpackage() {
    netpackage_config=$(
        whiptail --backtitle "VisionPro NVR First Boot Script - $version" --title "Network Package" --yesno "Does this location have a ProVision Network Package?" 16 60 3>&2 2>&1 1>&3
    )
    netpackage_config=$?
}

install_option_staticip() {
    staticip_config=$(
    whiptail --backtitle "VisionPro NVR First Boot Script - $version" --title "Network Package" --yesno "Do you wish to configure static IP addressing for the device?" 16 60 3>&2 2>&1 1>&3
    )
    staticip_config=$?
}

install_option_ipmi() {

    if [ "$netpackage_config" = "0" ] && [ "$staticip_config" = "0" ]; then
        ipmi_config=$(
            whiptail --backtitle "VisionPro NVR First Boot Script - $version" --title "IPMI Configuration" --yesno "Do you wish to configure the IPMI? This configures the Static IP, IPMI hostname, and users." 16 60 3>&2 2>&1 1>&3
        )
    else
        ipmi_config=$(
            whiptail --backtitle "VisionPro NVR First Boot Script - $version" --title "IPMI Configuration" --yesno "Do you wish to configure the IPMI? This configures DHCP, the IPMI hostname, and users." 16 60 3>&2 2>&1 1>&3
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
        
    hostname=$(whiptail --backtitle "VisionPro NVR First Boot Script - $version" --title "Configure Hostname" --inputbox "Enter desired hostname for this NVR:" 16 60 "$brandhost" 10 30 3>&1 1>&2 2>&3)
    exitstatus=$?

    if [ "$exitstatus" = "1" ]; then
        exit
    else
        sudo hostnamectl set-hostname ${hostname} >> $pv_log
        sudo echo ${hostname} > /proc/sys/kernel/hostname >> $pv_log
        sudo sed -i 's/127.0.1.1.*/127.0.1.1\t'"${hostname}"'/g' /etc/hosts >> $pv_log
        new_hostname=$(hostname -s) >> $pv_log
        whiptail --ok-button Next --backtitle "VisionPro NVR First Boot Script - $version" --title "Configure Hostname" --msgbox "Hostname set to $new_hostname" 16 60
    fi
}

brand_convert() {
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
        usermod -l studio club >> $pv_log
        usermod -m -d /home/studio studio >> $pv_log
        groupmod -n studio club >> $pv_log
        chfn -f "studio" studio >> $pv_log
    fi

    echo "$busername:$bpassword" | chpasswd >> $pv_log

    whiptail --backtitle "VisionPro NVR First Boot Script - $version" --title "Performing First Boot Script" --msgbox "Configured device for $brand_config." 16 60
}

software_install() {
    wget https://updates.digital-watchdog.com/digitalwatchdog/$dw_buildnumber/linux/$dw_serverpackage -O /tmp/dwspectrum-server.deb >> $pv_log
    wget https://updates.digital-watchdog.com/digitalwatchdog/$dw_buildnumber/linux/$dw_clientpackage -O /tmp/dwspectrum-client.deb >> $pv_log
    dpkg -i /tmp/dwspectrum-server.deb >> $pv_log
    apt-get install -f >> $pv_log
    dpkg -i /tmp/dwspectrum-client.deb >> $pv_log
    apt-get install -f >> $pv_log

    wget https://download.teamviewer.com/download/linux/teamviewer-host_amd64.deb -O /tmp/tv-host.deb >> $pv_log
    dpkg -i /tmp/tv-host.deb >> $pv_log
    apt-get install -f >> $pv_log
    sleep 20
    # Assign to VisionPro NVR rollout setup
    teamviewer assignment --id '0001CoABChAiMLFghKkR7pLoRztgHC2XEigIACAAAgAJAASMSgTbFFZ0_BUaxQOqRsEKTM8wwvIA38rLrjPLcc-pGkDMIqTNMkkS8nauaoo-aeHFUNPC6EIXyBCmuZrvD8wW1I7PXvUFd5l8b27FGQFOCd9x9bkGb3fz0ST_2AAtXYOFIAEQzszp7Ao='
}

do_ipmi_config() {
    # -user add: when adding a user, follow -user add <id of user> username password <permissions level>. 4 = Admin, 3 = Operator    
    ipmicfg -hostname "NVR-IPMI" >> $pv_log
    ipmicfg -user setpwd 2 "Pr0v@dmin#1!" >> $pv_log

    ipmicfg -user add 3 pvss "M@sterM1nd123" 4 >> $pv_log
    ipmicfg -user add 4 installer "Techs1988" 3 >> $pv_log

    ipmicfg -fru BPN "X12STH-F" >> $pv_log
    ipmicfg -fru BP "X12STH-F" >> $pv_log
    ipmicfg -fru PN "VisionPro Network Video Recorder" >> $pv_log
    ipmicfg -fru PV "Generation 4" >> $pv_log
    ipmicfg -fru "ProVision Distribution" >> $pv_log
    ipmicfg -fru CT 05h >> $pv_log

    if [ "$netpackage_config" = "0" ] && [ "$staticip_config" = "0" ]; then
        ipmicfg -dhcp off  >> $pv_log
        ipmicfg -m 172.16.100.220  >> $pv_log
        ipmicfg -k 255.255.255.0  >> $pv_log
        ipmicfg -g 172.16.100.1  >> $pv_log
    fi

    ipmi_ip=$(ipmicfg -m)
}

do_labtech_cw_automate() {
    sudo sh install.sh >> $pv_log
}

do_net_config() {
    # Set variables for port configs.
    eno1="INSIDE"
    eno2="CCTV"

    nmcli con del "Wired connection 1" >> $pv_log
    nmcli con del "Wired connection 2" >> $pv_log

    nmcli con add type ethernet con-name "$eno1" ifname eno1 >> $pv_log
    nmcli con add type ethernet con-name "$eno2" ifname eno2 >> $pv_log

    if [ "$netpackage_config" = "0" ] && [ "$staticip_config" = "0" ]; then
        # Configure device for our networking package.
        # INSIDE Network
        nmcli con mod "$eno1" ipv4.addresses 172.16.100.3/24 >> $pv_log
        nmcli con mod "$eno1" ipv4.gateway 172.16.100.1 >> $pv_log
        nmcli con mod "$eno1" ipv4.never-default false >> $pv_log
        nmcli con mod "$eno1" ipv4.dns "1.1.1.1 8.8.8.8" >> $pv_log
        nmcli con mod "$eno1" ipv4.method manual >> $pv_log
        # CCTV Network
        nmcli con mod "$eno2" ipv4.addresses 172.16.200.3/24 >> $pv_log
        nmcli con mod "$eno2" ipv4.never-default true >> $pv_log
        nmcli con mod "$eno2" ipv4.method manual >> $pv_log
    else
        # Configure devcie for DHCP
        nmcli con mod "$eno1" ipv4.never-default false >> $pv_log
        nmcli con mod "$eno1" ipv4.dns "1.1.1.1 8.8.8.8" >> $pv_log
        nmcli con mod "$eno1" ipv4.method auto >> $pv_log

        nmcli con mod "$eno2" ipv4.addresses 172.16.200.3/24 >> $pv_log
        nmcli con mod "$eno2" ipv4.never-default true >> $pv_log
        nmcli con mod "$eno2" ipv4.method manual >> $pv_log
    fi

    nmcli con mod "$eno1" ipv6.method ignore >> $pv_log
    nmcli con mod "$eno1" connection.autoconnect-priority 3 >> $pv_log
    nmcli con mod "$eno1" ipv4.dns-priority 3 >> $pv_log
    nmcli con mod "$eno1" ipv6.dns-priority 3 >> $pv_log
    nmcli con mod "$eno1" ipv4.route-metric 0 >> $pv_log
    nmcli con mod "$eno1" ipv6.route-metric 0 >> $pv_log
    nmcli con mod "$eno1" connection.autoconnect yes >> $pv_log

    nmcli con mod "$eno2" ipv6.method ignore >> $pv_log
    nmcli con mod "$eno2" connection.autoconnect-priority 2 >> $pv_log
    nmcli con mod "$eno2" ipv4.dns-priority 0 >> $pv_log
    nmcli con mod "$eno2" ipv6.dns-priority 0 >> $pv_log
    nmcli con mod "$eno2" ipv4.route-metric 10 >> $pv_log
    nmcli con mod "$eno2" ipv6.route-metric 10 >> $pv_log
    nmcli con mod "$eno2" connection.autoconnect yes >> $pv_log
}

do_cleanup() {
    rm /tmp/tv-host.deb >> $pv_log
    rm /tmp/dwspectrum* >> $pv_log
    rm /home/pvss/Desktop/firstboot.desktop >> $pv_log
    rm /home/pvss/firstboot.sh >> $pv_log
    rm /home/pvss/install.sh >> $pv_log
    rm -rf /home/pvss/data >> $pv_log

    apt update  >> $pv_log
    apt upgrade -y  >> $pv_log

    chmod 0777 /home/pvss/firstboot_log.txt

    whiptail --backtitle "VisionPro NVR First Boot Script - $version" --ok-button "Next" --title "First Boot Script Complete" --msgbox "The first boot script has been completed." 16 60
}

#Execution Steps
install_option_brand
install_option_netpackage
install_option_staticip
install_option_ipmi
brand_convert
set_hostname
do_ipmi_config
software_install
do_labtech_cw_automate
do_net_config
do_cleanup