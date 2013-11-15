config_file=".rsink/config"
prefs_file=".rsink/prefs"

function prefs {
    first=1
    cat $prefs_file | \
    while read line; do
        if [[ ${#line} == 1 ]]; then # single letter options
            if [[ $first == 1 ]]; then
                echo -n " -$line"
                first=0
            else
                echo -n "$line"
            fi
        else # longer options
            echo -n " --$line"
        fi
    done
}

function main {
    synccommand="rsync"
    cat $config_file | \
    while read line; do
        counter=0
        cmd=$synccommand
        cmd+=$(prefs)

        for p in $(echo $line | tr " " " ") ; do 
            counter=$(($counter+1))
            if [[ $counter -le 2 ]]; then # source and destination
                cmd+=" $p"
            else # exclude
                cmd+=" --exclude='$p'"
            fi
        done
        counter=0
        echo $cmd
    done
}