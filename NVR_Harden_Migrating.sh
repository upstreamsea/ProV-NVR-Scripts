#!/bin/bash
# Update
sudo apt-get update
sudo apt-get upgrade

# Remove telnet
apt purge telnet -y

# Remove CUPS
apt-get remove cups -y

# Remove Modem Manager
apt-get purge modemmanager -y

# Remove Whoopsie
apt-get purge whoopsie -y

# Remove Zeitgeist
sudo apt-get purge zeitgeist-core zeitgeist-datahub rhythmbox-plugin-zeitgeist -y

# Secure SSH
echo '#Secure SSH
AllowUsers pvss
PermitRootLogin no
PermitUserEnvironment no
RhostsAuthentication no
MaxStartups 2
AllowTcpForwarding no
X11Forwarding no
StrictModes yes
' | sudo tee -a /etc/ssh/sshd_config
service ssh restart

echo "##########sysctl#############
# Do not accept ICMP redirects (prevent MITM attacks)
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
# _or_
# Accept ICMP redirects only for gateways listed in our default
# gateway list (enabled by default)
# net.ipv4.conf.all.secure_redirects = 1
#
# Do not send ICMP redirects (we are not a router)
net.ipv4.conf.all.send_redirects = 0
net.ipv6.conf.all.accept_source_route = 0
#
# Do not accept IP source route packets (we are not a router)
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
#
# Log Martian Packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
#
# Controls IP packet forwarding
net.ipv4.ip_forward = 0
#
# IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
#
# Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1
#
# Ignore send redirects
net.ipv4.conf.default.send_redirects = 0
#
# Block SYN attacks
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5
#
# Ignore ICMP redirects
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
#
# Log packets with impossible addresses to kernel log? yes
net.ipv4.conf.default.secure_redirects = 0
#Enable ExecShield protection
kernel.exec-shield = 1
kernel.randomize_va_space = 1
#
########## IPv6 networking start ##############
# Number of Router Solicitations to send until assuming no routers are present.
# This is host and not router
net.ipv6.conf.default.router_solicitations = 0

# Accept Router Preference in RA?
net.ipv6.conf.default.accept_ra_rtr_pref = 0

# Learn Prefix Information in Router Advertisement
net.ipv6.conf.default.accept_ra_pinfo = 0

# Setting controls whether the system will accept Hop Limit settings from a router advertisement
net.ipv6.conf.default.accept_ra_defrtr = 0

#router advertisements can cause the system to assign a global unicast address to an interface
net.ipv6.conf.default.autoconf = 0

#how many neighbor solicitations to send out per address?
net.ipv6.conf.default.dad_transmits = 0

# How many global unicast IPv6 addresses can be assigned to each interface?
net.ipv6.conf.default.max_addresses = 1

########## IPv6 networking ends ##############
#
# Disables the magic-sysrq key
kernel.sysrq = 0
#
# Turn off the tcp_timestamps
net.ipv4.tcp_timestamps = 0
#
# Turn off the tcp_sack
net.ipv4.tcp_sack = 0
#
# Turn off the tcp_window_scaling
net.ipv4.tcp_window_scaling = 0
#
# Decrease the time default value for tcp_keepalive_time connection
net.ipv4.tcp_keepalive_time = 1800
#
####### End Sysctl ###########" > /etc/sysctl.conf

# no ip spoofing
echo '# The "order" line is only used by old versions of the C library.
order hosts,bind	
nospoof on' | sudo tee /etc/host.conf

# The following should be written to /etc/security/pwquality.conf
echo "# Configuration for systemwide password quality limits
# Defaults:
#
# Number of characters in the new password that must not be present in the
# old password.
difok = 5
#
# Minimum acceptable size for the new password (plus one if
# credits are not disabled which is the default). (See pam_cracklib manual.)
# Cannot be set to lower value than 6.
minlen = 14
#
# The maximum credit for having digits in the new password. If less than 0
# it is the minimum number of digits in the new password.
dcredit = 1
#
# The maximum credit for having uppercase characters in the new password.
# If less than 0 it is the minimum number of uppercase characters in the new
# password.
ucredit = 1
#
# The maximum credit for having lowercase characters in the new password.
# If less than 0 it is the minimum number of lowercase characters in the new
# password.
lcredit = 1
#
# The maximum credit for having other characters in the new password.
# If less than 0 it is the minimum number of other characters in the new
# password.
ocredit = 1
#
# The minimum number of required classes of characters for the new
# password (digits, uppercase, lowercase, others).
minclass = 4
#
# The maximum number of allowed consecutive same characters in the new password.
# The check is disabled if the value is 0.
maxrepeat = 3
#
# The maximum number of allowed consecutive characters of the same class in the
# new password.
# The check is disabled if the value is 0.
# maxclassrepeat = 0
#
# Whether to check for the words from the passwd entry GECOS string of the user.
# The check is enabled if the value is not 0.
gecoscheck = 1
#
# Path to the cracklib dictionaries. Default is to use the cracklib default.
# dictpath =
####end pwquality######" | sudo tee /etc/security/pwquality.conf
