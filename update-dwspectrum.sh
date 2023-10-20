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

if promptyn "Would you like to Download and Install the latest DW Spectrum app from the ProVision Security Repository? (Y/N)"; then
echo "You Selected YES."
# YES
### Install DW Spectrum Server from ProV Repository
curl -O https://s3.amazonaws.com/pv-web/deploy/dwspectrum/dwspectrum-server-64.deb
sudo dpkg -i ./dwspectrum-server-64.deb
sudo apt-get install -f

### Install DW Spectrum Client from ProV Repository
curl -O https://s3.amazonaws.com/pv-web/deploy/dwspectrum/dwspectrum-client-64.deb
sudo dpkg -i ./dwspectrum-client-64.deb
sudo apt-get install -f
else
echo "You Selected No."
# NO
fi
echo "done."
