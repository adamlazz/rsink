#!/bin/bash

# Usage: Ctrl+C during execution
#---------------------------------------------------------
# SIGINT interrupt. Stop execution.
#---------------------------------------------------------
die() { # stop all rsync commands
    echo "SIGINT - Stopping rsink.sh"
    exit 1
}
trap die SIGINT

# Usage: fail $1 $2
#---------------------------------------------------------
# Error has occurred. Display error and exit with status
# code 1.
#
# Inputs
#   $1  errant value/variable
#   $2  message
#---------------------------------------------------------
fail() { # show error, exit
    echo -e "[0;31mERROR: $1\n$2[0m"
    exit 1
}

# Usage: warn $1 $2
#---------------------------------------------------------
# Error has occurred. Warn user.
#
# Inputs
#   $1  message
#---------------------------------------------------------
warn() { # show error, don't exit
    echo -e "[0;31m$1[0m"
}

# Usage: usage
#---------------------------------------------------------
# Display usage. Uses constants from constants.sh
#---------------------------------------------------------
usage() {
    echo "$VERSION\n"
    echo "./rsink.sh <options>"
    echo -e "\t-d or --dry-run     # Dry run (don't run rsync command)"
    echo -e "\t-h or --help        # Display help"
    echo -e "\t-p or --pushover    # Send pushover notification (Requires User/App keys in .rsink/$TOOLS_DIRECTORY/pushover.sh)"
    echo -e "\t-s or --silent      # Silent output"
    echo -e "\t-v or --version     # Displays version\n"
    echo "Config file: $CONFIG_FILE"
    echo "Profiles directory: $PROFILES_DIRECTORY/"
}

# Usage: detect_x $1 $2
#---------------------------------------------------------
# Error has occurred. Warn user.
#
# Inputs
#   $1  Type
#       * "f" File
#       * "d" Directory
#       * "x" File or directory
#       * "m" Mounted volume
#   $2  File/folder name
#---------------------------------------------------------
detect_x() {
    case $1 in
        "f"*) # File
            if [ ! -f $2 ]; then
                fail "$2" "File does not exist."
            fi ;;
        "d"*) # Directory
            if [ ! -d $2 ]; then
                fail "$2" "Directory does not exist."
            fi ;;
        "x"*) # Either file or directory
            if [ ! -f $2 ] && [ ! -d $2 ]; then
                fail "$2" "File or directory does not exist."
            fi ;;
        "m"*) # Mounted volume
            if [ $(mount | grep -c $2) -ne 1 ]; then
                warn "$2 not mounted. Skipping."
                skip=1
            else
                skip=0
            fi ;;
    esac
}

# Usage: profile $1
#---------------------------------------------------------
# Parse profile to build rsync command's options.
#
# Inputs
#   $1  profile file
#---------------------------------------------------------
profile() { # Parse profile file
    detect_x "f" "$PROFILES_DIRECTORY/$1" # Detect profile

    local first=1 # First single character option (add -)
    cat $PROFILES_DIRECTORY/$1 | while read -r line || [ -n "$line" ]; do
        local option=$(printf "$line" | awk '{print $1;}') # Get first token of $line

        if [ "$(printf "$option" | head -c 1)" != "#" ] && [ "$option" != "" ]; then # Not comment or empty line
            if [ ${#option} -eq 1 ]; then # Single character options (add -)
                if [ $first -eq 1 ]; then
                    first=0
                    printf " -$option"
                else
                    printf "$option"
                fi
            else # Long options (add --)
                first=1
                printf " --$option"
            fi
        fi
    done
    printf " --log-file=\"$LOG_FILE\""
}

# Usage: isBackup $1
#---------------------------------------------------------
# Detects if a profile is a versioned backup profile.
#
# Inputs
#   $1  profile file
#---------------------------------------------------------
isBackup() {
    backup=0
    current_version=""
    local line=$(cat $PROFILES_DIRECTORY/$1 | grep "link-dest")
    if [ "$line" != "" ]; then
        backup=1
        current_version=$(printf $line | cut -d'=' -f2)
    fi
}

# Usage: main
#---------------------------------------------------------
# Build and execute rsync commands.
#---------------------------------------------------------
main() {
    detect_x "f" "$CONFIG_FILE"
    detect_x "d" "$PROFILES_DIRECTORY"

    cat $CONFIG_FILE | while read line || [ -n "$line" ]; do
        local token=0
        local cmd="rsync"
        backup=0
        skip=0

        for p in $line; do # Parse tokens in config file
            (( token++ ))

            if [ $token -eq 1 ]; then # Profile
                local profile=$(printf "$p" | awk '{print $1;}') # Get first word of $line
                cmd="$cmd$(profile $profile)"
            elif [ $token -eq 2 ]; then # Source
                if [ "$(printf "$p" | head -c 1)" = "~" ]; then # ~/source/folder
                    p=$(printf "$p" | cut -d "~" -f 2)
                    p="$HOME$p" # /Users/user/source/folder or /home/source/folder
                fi
                local src=$p
                detect_x "x" "$p"
                cmd="$cmd $p"
            elif [ $token -eq 3 ]; then # Destination volume
                local dest=$p
                detect_x "m" "$p"
                if [ $skip -eq 1 ]; then
                    break;
                fi
                cmd="$cmd $p"
            elif [ $token -eq 4 ]; then # Destination folder
                if [ "$p" != "." ]; then
                    isBackup $profile
                    if [ $backup -ge 1 ]; then
                        local ddate=$(date +"-%m-%d-%Y@%H-%M-%S") # Dash & date
                        dest="$dest/$p$ddate"
                        cmd="$cmd/$p$ddate"
                    else
                        detect_x "d" "$dest/$p"
                        cmd="$cmd/$p"
                    fi
                fi
            elif [ $token -ge 5 ]; then # Excludes
                detect_x "x" "$src/$p"
                cmd="$cmd --exclude='$p'"
            fi
        done
        token=0

        # Run rsync
        echo -e "$cmd\n"
        if [[ $dry -ne 1 && $skip -ne 1 ]]; then
            eval "$cmd" > /dev/null
        fi
        code=$?

        if [ $dry -ne 1 ]; then
            # Symlink new backup to link-dest path in profile
            if [ $backup -eq 1 ]; then
                rm -rf "$current_version"
                ln -s "$dest $current_version"
            fi

            # rsync error checking
            if [ $code -ne 0 ]; then
                warn "rsync code: $code\nrsync completed with errors."
            fi

            # Log file errors
            if [ $skip -ne 1 ]; then
                if grep -cq "No space left on device (28)\|Result too large (34)" $LOG_FILE; then
                    warn "Not enough space on $dest"
                fi
                rm $LOG_FILE
            fi
        fi

        skip=0
        backup=0
        current_version=""
    done
}

set -e # exit if any program exists with exit status > 0

source constants.sh

# Options parsing
dry=0
pushover=0
silent=0

while : ; do
    case $1 in
        -d | --dry-run)
            dry=1
            shift ;;
        -h | --help | -\?)
            usage
            exit 0 ;;
        -p | --pushover)
            pushover=1
            shift ;;
        -s | --silent)
            silent=1
            shift ;;
        -v | --version)
            echo "$VERSION"
            exit 0 ;;
        --)
            shift
            break ;;
        -*)
            fail $1 "Illegal option" ;;
        *)
            break ;;
    esac
done

if [ $silent -eq 1 ]; then
    echo () { : ; } # Redefine echo
fi

main

# Send pushover notification
if [ $pushover -eq 1 ]; then
    ./$TOOLS_DIRECTORY/pushover.sh
fi

exit 0
