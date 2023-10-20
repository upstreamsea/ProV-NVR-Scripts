## Download IPMIcfg and copy to ~/IPMI/
## this will install the SuperMicro IPMICFG App
#sudo chmod +x ./IPMICFG-Linux.x86_64
#sudo ln -s $(pwd)/IPMICFG-Linux.x86_64 /usr/local/sbin/ipmicfg

## Configure Local IPMI
# Show Current Config
sudo ipmicfg -m
sudo ipmicfg -user list
sudo ipmicfg -hostname

# Set Hostname
sudo ipmicfg -hostname NVR-IPMI

# Change Default Admin Password
sudo ipmicfg -user setpwd 2 Pr0v@dmin#1!

# Add PVSS Admin and Installer User
sudo ipmicfg -user add 3 pvss M@sterM1nd123 4
sudo ipmicfg -user add 4 installer techs1988 2
sudo ipmicfg -user list

# Set Static IP Address for IPMI
# Uncomment the lines below to make this change
# sudo ipmicfg -m 192.168.5.245
# sudo ipmicfg -k 255.255.255.0
# sudo ipmicfg -g 192.168.5.1

echo "IPMI Configuration Completed..."
exit
