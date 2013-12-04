config_file="config"
profiles_directory="profiles"

detect_x() {
    case $1 in
        "f"*) # file
            if [[ ! -f $2 ]]; then
               fail $2 "File does not exist."
            fi
        ;;
        "d"*) # directory
            if [[ ! -d $2 ]]; then
               fail $2 "Directory does not exist."
            fi
        ;;
        "x"*) # either file or directory
            if [[ (! -f $2) && (! -d $2) ]]; then
                fail $2 "File or directory does not exist."
            fi
        ;;
        "m"*) # mount
            if [[ ! $(mount | grep $2) ]]; then
                fail $2 "Hard drive not mounted."
            fi
        ;;
    esac
}

fail() {
    echo $1
    echo $2
    exit
}

profile() {
    detect_x "f" $profiles_directory/$1

    first=1 # first single character option (add -)
    cat $profiles_directory/$1 | while read -r line || [[ -n "$line" ]]; do
        option=$(echo $line | cut -d \: -f 1)
        
        if [[ ${#option} == 1 ]]; then # single letter options
            if [[ $first == 1 ]]; then
                first=0
                echo -n " -$option"
            else
                echo -n "$option"
            fi
        else # longer options (add --)
            first=1
            echo -n " --$option"
        fi
    done
}

main() {
    detect_x "f" $config_file
    detect_x "d" $profiles_directory

    cat $config_file | while read line || [[ -n "$line" ]]; do
        token=0
        cmd="rsync"

        for p in $(echo $line | tr " " " "); do
            token=$(($token+1))

            if [[ $token == 1 ]]; then # profile
                profile=$(echo $p | awk '{print $1;}') # get first word of $line
                cmd+=$(profile $profile)
            elif [[ $token -ge 2 && $token -le 3 ]]; then # source and destination
                if [[ $token == 2 ]]; then # source
                    if [[ "$(echo $p | head -c 1)" = "~" ]]; then
                        src=$(echo $p | cut -d '~' -f 2)
                        src="$HOME$src"
                    else
                        src=$p
                        detect_x "x" $src
                    fi
                elif [[ $token == 3 ]]; then # destination volume
                    detect_x "m" $p
                    dest=$p
                fi
                cmd+=" $p"
            elif [[ $token == 4 ]]; then # destination folder
                if [[ "$p" != "." ]]; then
                    detect_x "d" "$dest/$p"
                    cmd+="/$p"
                fi
            elif [[ $token -ge 5 ]]; then # excludes
                detect_x "x" "$src/$p"
                cmd+=" --exclude='$p'"
            fi
        done
        token=0
        echo $cmd
        eval $cmd
    done
}

main
