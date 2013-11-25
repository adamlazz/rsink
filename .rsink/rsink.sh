config_file="config"
profiles_directory="profiles"

prefs() {
    first=1

    cat $profiles_directory/$1 | while read line; do
        if [[ ${#line} == 1 ]]; then # single letter options
            if [[ $first == 1 ]]; then
                echo -n " -$line"
                first=0
            else
                echo -n "$line"
            fi
        else # longer options
            first=1
            echo -n " --$line"
        fi
    done
}

detect() {
    if [[ ! mount | grep -q $1 ]]; then
        fail $1 "Hard drive not connected."
    fi
}

fail() {
    echo $1
    echo $2
    exit
}

main() {
    synccommand="rsync"

    cat $config_file | while read line; do
        counter=0
        cmd=$synccommand

        for p in $(echo $line | tr " " " "); do
            counter=$(($counter+1))

            if [[ $counter == 1 ]]; then # profile
                profile=$(echo $p | awk '{print $1;}') # get first word of $line
                cmd+=$(prefs $profile)
            elif [[ $counter -ge 2 && $counter -le 3 ]]; then # source and destination
                if [[ $counter == 3 ]]; then # destination
                    detect $p
                fi
                cmd+=" $p"
            elif [[ $counter -ge 4 ]]; then
                cmd+=" --exclude='$p'"
            fi
        done
        counter=0
        echo $cmd
        eval $cmd
    done
}

main
