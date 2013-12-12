# add executability permission to rsink.sh
chmod +x .rsink/rsink.sh

# remove current installation (if it exists)
rm -rf ~/.rsink

# move .rsink to home directory
mv .rsink/ ~

# clean up
cd ..
rm rsink

echo "Installed rsink to ~/.rsink"
echo "Press any key to continue."
read -n 1 c
exit 0