# add executability permission to rsink.sh
chmod +x .rsink/rsink.sh

# remove current installation (if it exists)
rm -fr ~/.rsink

# move .rsink to home directory
mv .rsink/ ~

# clean up
cd ..
rm rsink