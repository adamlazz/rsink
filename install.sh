# add executability permission to rsink.sh
chmod +x .rsink/rsink.sh

# move .rsink to home directory
mv .rsink/ ~

# move shell script to somewhere in path
mv rsink.sh /usr/bin/local

# clean up
cd ..
rm rsink