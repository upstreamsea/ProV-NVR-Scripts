wget https://download.teamviewer.com/download/linux/teamviewer-host_amd64.deb -O /tmp/tv-host.deb >> $pv_log
dpkg -i /tmp/tv-host.deb >> $pv_log
apt-get install -f >> $pv_log
sleep 20
# Assign to VisionPro NVR rollout setup
teamviewer assignment --id '0001CoABChAiMLFghKkR7pLoRztgHC2XEigIACAAAgAJAASMSgTbFFZ0_BUaxQOqRsEKTM8wwvIA38rLrjPLcc-pGkDMIqTNMkkS8nauaoo-aeHFUNPC6EIXyBCmuZrvD8wW1I7PXvUFd5l8b27FGQFOCd9x9bkGb3fz0ST_2AAtXYOFIAEQzszp7Ao='