#!/bin/sh

config_file="config"
profiles_directory="profiles"

die() { # stop all rsync commands
    echo "SIGINT - Stopping rsink.sh"
    exit 1
}
trap die INT

detect_x() {
    case $1 in
        "f"*) # file
            if [ ! -f $2 ]; then 
                fail $2 "File does not exist."
            fi ;;
        "d"*) # directory
            if [ ! -d $2 ]; then 
                fail $2 "Directory does not exist."
            fi ;;
        "x"*) # either file or directory
            if [ ! -f $2 ] && [ ! -d $2 ]; then 
                fail $2 "File or directory does not exist."
            fi ;;
        "m"*) # mount
            if [ $(mount | grep -c $2) != 1 ]; then
                fail $2 "Hard drive not mounted."
            fi ;;
    esac
}

fail() {
    echo $1
    echo "\033[31m$2\033[0m"
    exit 1
}

profile() {
    detect_x "f" $profiles_directory/$1

    first=1 # first single character option (add -)
    cat $profiles_directory/$1 | while read -r line || [ -n "$line" ]
    do
        option=$(printf $line | cut -d \: -f 1)
        
        if [ ${#option} -eq 1 ]; then # single character options
            if [ $first -eq 1 ]; then
                first=0
                printf " -$option"
            else
                printf "$option"
            fi
        else # longer options (add --)
            first=1
            printf " --$option"
        fi
    done
}

main() {
    detect_x "f" $config_file
    detect_x "d" $profiles_directory

    cat $config_file | while read line || [ -n "$line" ]; do
        token=0
        cmd="rsync"

        for p in $line; do
            token=$(($token+1))

            if [ $token -eq 1 ]; then # profile
                profile=$(echo $p | awk '{print $1;}') # get first word of $line
                cmd=$cmd$(profile $profile)
            elif [ $token -eq 2 ]; then # source
                if [ "$(echo $p | head -c 1)" = "~" ]; then # ~/source/folder
                    p=$(echo $p | cut -d '~' -f 2)
                    p="$HOME$p" # /Users/user/source/folder
                fi
                src=$p
                detect_x "x" $p
                cmd="$cmd $p"
            elif [ $token -eq 3 ]; then # destination volume
                dest=$p
                detect_x "m" $p
                cmd="$cmd $p"
            elif [ $token -eq 4 ]; then # destination folder
                if [ "$p" != "." ]; then
                    detect_x "d" "$dest/$p"
                    cmd="$cmd/$p"
                fi
            elif [ $token -ge 5 ]; then # excludes
                detect_x "x" "$src/$p"
                cmd="$cmd --exclude='$p'"
            fi
        done
        token=0
        echo $cmd
        eval $cmd
    done
}

main
exit 0
