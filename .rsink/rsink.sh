#!/bin/sh

version="rsink 0.1+dev"
config_file="config"
profiles_directory="profiles"
log_file="log"

set -e # exit if any program exists with exit status > 0

die() { # stop all rsync commands
    echo "SIGINT - Stopping rsink.sh"
    exit 1
}
trap die SIGINT

fail() { # show error, exit
    echo "\033[31mERROR: $1\n$2\033[0m"
    exit 1
}

warn() { # show error, don't exit
    echo "\033[31m$1\033[0m"
}

usage() {
    echo "$version\n"
    echo "./rsink.sh <options>"
    echo "\t-h <help>"
    echo "\t-p <pushover> (Fill in user key and app key in .rsink/tools/pushover.sh)"
    echo "\t-s <silent>"
    echo "\t-v <version>\n"
    echo "Config file: $config_file"
    echo "Profiles directory: $profiles_directory"
    echo "README: https://github.com/adamlazz/rsink/blob/master/README.md"
}

# $1 type (file, directory, mounted volume)
# $2 name
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
                fail $2 "Volume not mounted."
            fi ;;
    esac
}

profile() { # parse profile file
    detect_x "f" $profiles_directory/$1 # detect profile by name

    first=1 # first single character option (add -)
    cat $profiles_directory/$1 | while read -r line || [ -n "$line" ]; do
        option=$(printf "$line" | awk '{print $1;}') # get first token of $line

        if [ "$(printf "$option" | head -c 1)" != "#" ] && [ "$option" != "" ]; then # header comment or empty line
            if [ ${#option} -eq 1 ]; then # single character options
                if [ $first -eq 1 ]; then # (add -)
                    first=0
                    printf " -$option"
                else
                    printf "$option"
                fi
            else # long options (add --)
                first=1
                printf " --$option"
            fi
        fi
    done
}

# build and execute rsync commands
main() {
    detect_x "f" $config_file
    detect_x "d" $profiles_directory

    cat $config_file | while read line || [ -n "$line" ]; do
        token=0
        cmd="rsync"

        for p in $line; do # parse tokens in config file
            token=$(($token+1))

            if [ $token -eq 1 ]; then # profile
                profile=$(printf "$p" | awk '{print $1;}') # get first word of $line
                cmd="$cmd$(profile $profile)"
            elif [ $token -eq 2 ]; then # source
                if [ "$(printf "$p" | head -c 1)" = "~" ]; then # ~/source/folder
                    p=$(printf "$p" | cut -d "~" -f 2)
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

        cmd="$cmd --log-file='$log_file'"
        if [[ $silent -eq 1 ]]; then
            eval $cmd > /dev/null
        else
            printf "$cmd"
            eval $cmd
        fi

        code=$?
        if [ $code -ne 0 ]; then
            warn "rsync code: $code\nrsync completed with errors."
        fi

        # log file errors
        if [ $(cat $log_file | grep -c "unknown option") ]; then
            warn "Unknown rsync option"
        elif [ $(cat $log_file | grep -c "No space left on device (28)\|Result too large (34)") ]; then
            warn "Not enough space on $dest"
        fi
        rm $log_file
    done
}

pushover=0
silent=0

options='hpsv'
while getopts $options option; do
    case $option in
        h) usage; exit 1 ;;
        p) pushover=1 ;;
        s) silent=1 ;;
        v) echo "$version"; exit 1 ;;
        \?) fail $OPTARG "Illegal option" ;;
    esac
done
shift $(($OPTIND - 1))

if [[ $silent -eq 1 ]]; then
    echo () {
        :
    }
fi

main

if [[ $pushover -eq 1 ]]; then
    ./tools/pushover.sh
fi

exit 0
