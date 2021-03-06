[ -z $BASH ] && { exec bash "$0" "$@" || exit; }
#!/bin/bash
# file: update.sh
#
# This script will install required software for HoneyPi.
# It is recommended to run it in your home directory.
#

# check if sudo is used
if [ "$(id -u)" != 0 ]; then
    echo 'Sorry, you need to run this script with sudo'
    exit 1
fi

# target directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# install HoneyPi rpi-scripts
echo '>>> Install HoneyPi runtime measurement scripts'
ScriptsTag=$(curl --silent "https://api.github.com/repos/Honey-Pi/rpi-scripts/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
if [ $ScriptsTag ]; then
    rm -rf rpi-scripts # remove folder to download latest
    echo ">>> Downloading rpi-scripts $ScriptsTag"
    wget "https://codeload.github.com/Honey-Pi/rpi-scripts/zip/$ScriptsTag" -O HoneyPiScripts.zip
    unzip HoneyPiScripts.zip
    mv $DIR/rpi-scripts-${ScriptsTag//v} $DIR/rpi-scripts
    sleep 1
    rm HoneyPiScripts.zip
    # set file rights
    echo '>>> Set file rights to python scripts'
    chown -R pi:pi $DIR/rpi-scripts
    chmod -R 775 $DIR/rpi-scripts
else
    echo '>>> Something went wrong. Updating rpi-scripts skiped.'
fi


# install HoneyPi rpi-webinterface
echo '>>> Install HoneyPi webinterface'
WebinterfaceTag=$(curl --silent "https://api.github.com/repos/Honey-Pi/rpi-webinterface/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
if [ $WebinterfaceTag ]; then
    rm -rf /var/www/html # remove folder to download latest
    echo ">>> Downloading rpi-webinterface $WebinterfaceTag"
    wget "https://codeload.github.com/Honey-Pi/rpi-webinterface/zip/$WebinterfaceTag" -O HoneyPiWebinterface.zip
    unzip HoneyPiWebinterface.zip
    mv $DIR/rpi-webinterface-${WebinterfaceTag//v}/dist /var/www/html
    mv $DIR/rpi-webinterface-${WebinterfaceTag//v}/backend /var/www/html/backend
    sleep 1
    rm -rf $DIR/rpi-webinterface-${WebinterfaceTag//v}
    rm HoneyPiWebinterface.zip
    # set file rights
    echo '>>> Set file rights to webinterface'
    chown -R www-data:www-data /var/www/html
    chmod -R 775 /var/www/html
else
    echo '>>> Something went wrong. Updating rpi-webinterface skiped.'
fi

# Create File with version information
echo 'HoneyPi' > /var/www/html/version.txt
echo "rpi-scripts $ScriptsTag" >> /var/www/html/version.txt
echo "rpi-webinterface $WebinterfaceTag" >> /var/www/html/version.txt
