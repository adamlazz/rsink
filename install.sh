# add executability permission to rsink.sh
chmod +x .rsink/rsink.sh

# move .rsink to home directory
mv .rsink/ ~

# move shell script to somewhere in path
mv rsink.sh /usr/bin/local

# change .samples to real config files??
mv ~/.rsink/config.sample ~/.rsink/config
mv ~/.rsink/prefs.sample ~/.rsink/prefs