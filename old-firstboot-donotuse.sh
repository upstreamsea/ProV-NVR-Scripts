clear
echo  "********************************************"
echo  "*             ProVision Security           *" 
echo  "*   Ubuntu Software Update Setting Script  *" 
echo  "*           for Ubuntu 16.04 LTS x64       *" 
echo  "*  --------------------------------------  *" 
echo  "*             Updated October 2018         *" 
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

if promptyn "Would you like to check for and download the latest updates for this script from the ProVision Security Repository? Internet Access Is Required. (Y/N)"; then
echo "You Selected YES."
# YES
### Download
curl -O https://s3.amazonaws.com/pv-web/deploy/dwspectrum/FirstBoot.zip
sudo unzip -o ./Firstboot.zip
sudo rm ./FirstBoot.zip
sudo chmod +x *.sh
sudo ./firstbootrun.sh

else
echo "You Selected No."
# NO
sudo ./firstbootrun.sh
fi
echo "done."
