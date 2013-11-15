config_file=".rsink/config"
prefs_file=".rsink/prefs"

function prefs {
    first=1

    cat $prefs_file | \
    while read line; do
        if [[ ${#line} == 1 ]]; then # single letter options
            if [[ $first == 1 ]]; then
                echo -n "-$line"
                first=0
            else
                echo -n "$line"
            fi
        else # longer options
            echo -n " --$line"
        fi
    done
}

cmd="rsync"
preferences=$(prefs)

cat $config_file | \
while read line; do
    counter=0 # source, destination, excludes

    echo -n $cmd $preferences 

    # exclude
    for p in $(echo $line | tr " " " ") ; do 
        counter=$(($counter+1))
        if [[ $counter -le 2 ]]; then
            echo -n " $p"
        else
            echo -n " --exclude '$p'"
        fi
    done 
    counter=0
    echo ""
done