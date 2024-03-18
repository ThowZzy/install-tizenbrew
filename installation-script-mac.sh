#!/bin/bash
# To run this script on your Mac, run in a terminal "chmod +x installation-script-mac.sh" and then "./installation-script-mac.sh"
# Make sure that the root directory is right, it's the default one here.
tizen_dir="${HOME}/tizen-studio"

# URL to download wgt files
url="https://github.com/reisxd/TizenBrew/releases/latest/download"

echo ""
echo "Type here the IP of your TV (make sure you set TV's dev IP to yours) : "
read userInput
echo ""

echo "=================== WGT Download ====================="
echo "Downloading wgt file from releases..."
echo ""
curl -L "${url}/TizenBrewStandalone.wgt" -o "${tizen_dir}/TizenBrewStandalone.wgt"
echo "======================================================="

echo ""
echo "================= Connecting to the TV ================"
cd "${tizen_dir}/tools"
./sdb connect $userInput
./sdb devices
echo "======================================================="

echo ""
echo "=========== Installing TizenBrew to the TV =========="
cd "ide/bin"
./tizen install -n "${tizen_dir}/TizenBrewStandalone.wgt"
echo "========================================================"

cd ../..
./sdb disconnect $userInput

echo ""
echo "The installation process is over. If all went well, you should have TizenBrew installed on your TV."
echo ""
