#!/bin/sh
# install.sh

# add executability permission to rsink.sh
chmod +x .rsink/rsink.sh

# remove current installation (if it exists)
if [ ! -d "~/.rsink" ]; then 
    rm -rf ~/.rsink
fi

# move .rsink to home directory
mv .rsink/ ~

echo "Installed rsink to ~/.rsink"
echo "Press any key to continue."
read -n 1 c
exit 0
