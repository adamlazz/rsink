config_file="config.sample"
profiles_directory="profiles"

prefs() {
    detect_file $profiles_directory/$1

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

detect_x() {
    if [[ (! -f $1) && (! -d $1) ]]; then
        fail $1 "File or directory does not exist."
    fi
}

detect_file() {
    if [[ ! -f $1 ]]; then
       fail $1 "File does not exist."
    fi
}

detect_dir() {
    if [[ ! -d $1 ]]; then
       fail $1 "Directory does not exist."
    fi
}

detect_hd() {
    if [[ ! $(mount | grep $1) ]]; then
        fail $1 "Hard drive not mounted."
    fi
}

fail() {
    echo $1
    echo $2
    exit
}

main() {
    detect_file $config_file
    detect_dir $profiles_directory

    cat $config_file | while read line; do
        token=0
        cmd="rsync"

        for p in $(echo $line | tr " " " "); do
            token=$(($token+1))

            if [[ $token == 1 ]]; then # profile
                profile=$(echo $p | awk '{print $1;}') # get first word of $line
                cmd+=$(prefs $profile)
            elif [[ $token -ge 2 && $token -le 3 ]]; then # source and destination
                if [[ $token == 2 ]]; then # source
                    detect_x $p
                elif [[ $token == 3 ]]; then # destination volume
                    detect_hd $p
                fi
                cmd+=" $p"
            elif [[ $token -ge 4 ]]; then
                cmd+=" --exclude='$p'"
            fi
        done
        token=0
        echo $cmd
        eval $cmd
    done
}

main
