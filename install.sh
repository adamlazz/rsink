#!/bin/bash

set -e

# Get constants
source .rsink/constants.sh

# Add executability permission to rsink.sh
chmod +x .rsink/rsink.sh

# Add executability permission to tools
chmod +x .rsink/"$tools_directory"/*.sh

# Remove current installation (if it exists)
if [ ! -d "~/.rsink" ]; then
    rm -rf ~/.rsink
fi

# Move .rsink to home directory
mv .rsink/ ~

echo "Installed rsink to ~/.rsink"
echo "Press any key to continue."
read -n 1 c
exit 0
