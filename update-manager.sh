clear
echo  "********************************************"
echo  "*             ProVision Security           *" 
echo  "*   Ubuntu Software Update Setting Script  *" 
echo  "*           for Ubuntu 16.04 LTS x64       *" 
echo  "*  --------------------------------------  *" 
echo  "*             Updated July 2018            *" 
echo  "*      Last Modified by Travis Jacobson    *"
echo  "*  --------------------------------------  *"
echo  "*     Retail Technology Engineering Team   *"
echo  "********************************************" 
echo ""
echo "Make sure this script is ran with Sudo Permissions..."
echo ""
echo "Press Control+C if you wish to cancel this script!"
echo ""
echo ""

# Set the YN Prompt Variable
promptyn () {
while true; do
read -p "$1 " yn
case $yn in
[Yy]* ) return 0;;
[Nn]* ) return 1;;
* ) echo "Please answer yes or no...";;
esac
done
}

if promptyn "Would you like to Enable the Ubuntu Software Updates? (Y/N)"; then
echo "You Selected YES."
# Enable
sudo chmod 777 /usr/bin/update-manager
sudo chmod 777 /usr/bin/update-notifier
else
echo "You Selected No."
# Disable
sudo chmod 000 /usr/bin/update-manager
sudo chmod 000 /usr/bin/update-notifier
fi
echo "done."
