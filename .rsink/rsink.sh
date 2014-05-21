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
# Display usage.
#---------------------------------------------------------
usage() {
    echo -e "$VERSION\n"
    echo -e "./rsink.sh <options>"
    echo -e "\t-d or --dry-run     # Dry run (Don't run rsync)"
    echo -e "\t-h or --help        # Display help"
    echo -e "\t-s or --silent      # Silent output"
    echo -e "\t-v or --version     # Displays version\n"
    echo "Config file: $CONFIG_FILE"
    echo "Profiles directory: $PROFILES_DIRECTORY/"
}

# Usage: detect_x $1 $2
#---------------------------------------------------------
# Determine if files, and/or directories exist. Check if
# volumes are mounted.
#
# Inputs
#   $1  Type
#       * "f" File
#       * "d" Directory
#       * "L" Symbolic link
#       * "x" File or directory
#       * "m" Mounted volume
#   $2  File/folder name
#---------------------------------------------------------
detect_x() {
    case $1 in
        "f"*) # File
            if [ ! -f "$2" ]; then
                fail "$2" "File does not exist."
            fi ;;
        "d"*) # Directory
            if [ ! -d "$2" ]; then
                fail "$2" "Directory does not exist."
            fi ;;
        "L"*) # Symbolic link
            if [ ! -L "$2" ]; then
                warn "$2 is not a symbolic link. Proceeding."
            fi ;;
        "x"*) # Either file or directory
            if [ ! -f "$2" ] && [ ! -d "$2" ]; then
                fail "$2" "File or directory does not exist."
            fi ;;
        "m"*) # Mounted volume
            if ! mount | grep "$2" > /dev/null; then
                warn "$2 not mounted. Skipping."
                skip=1
            else
                skip=0
            fi ;;
    esac
}

# Usage: profile $1
#---------------------------------------------------------
# Parse profile to build rsync command's options in
# $args array.
#
# Inputs
#   $1  profile file
#---------------------------------------------------------
profile(){
    while read line; do
        arg=${line%#*} # Disregard comment
        arg="${arg%%*( )}" # Trim trailing whitespace

        # Only consider non-comment and non-empty lines
        if [[ $(printf "%s" "$line" | head -c 1) != "#" && -n "$line" ]]; then
            if [ "${#arg}" -eq 1 ]; then
                args=("${args[@]}" "-$arg")
            else
                args=("${args[@]}" "--$arg")
            fi
        fi
    done < "$1"
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
    local line="$(grep "link-dest" "$1")"
    if [ "$line" != "" ]; then
        backup=1
        current_version=${line#"link-dest="}
        current_version=${current_version#"'"}
        current_version=${current_version%"'"}
        detect_x "L" "$current_version"
    fi
}

# Usage: main
#---------------------------------------------------------
# Build and execute rsync commands.
#---------------------------------------------------------
main() {
    detect_x "f" "$CONFIG_FILE"
    detect_x "d" "$PROFILES_DIRECTORY"

    backup=0
    skip=0
    token=1
    while read -r line; do # Parse config file
    if [[ "$(printf "%s" "$line" | awk '{print $1;}')" != "#" ]]; then
        if [[ "$line" == "" ]]; then
            if [[ "$skip" -ne 1 ]]; then
                echo "> rsync" "${args[@]}" "\"$src\"" "\"$dest\"" "${excludes[@]}" --log-file="'$LOG_FILE'"
                if [ "$dry" -ne 1 ]; then
                    rsync "${args[@]}" "$src" "$dest" "${excludes[@]}" --log-file="$LOG_FILE"
                elif [ "$dry" -eq 1 ]; then
                    rsync "${args[@]}" "$src" "$dest" "${excludes[@]}" --log-file="$LOG_FILE" --dry-run
                fi
            fi
            code=$?
            args=()
            excludes=()
            token=0

            # rsync error checking
            if [ "$code" -ne 0 ]; then
                warn "rsync code: $code\nrsync completed with errors."
            fi

            if [[ "$dry" -ne 1 && "$skip" -ne 1 ]]; then
                if [ "$backup" -eq 1 ]; then
                    # Symlink new backup to link-dest path in profile
                    rm -rf "$current_version"
                    ln -s "$dest" "$current_version"
                fi

                # Log file errors
                if [ -n "$(grep "No space left on device (28)\|Result too large (34)" "$LOG_FILE")" ]; then
                    warn "Not enough space on $volume"
                fi
                rm "$LOG_FILE"
            fi

            skip=0
            backup=0
            current_version=""
        elif [ "$token" -eq 1 ]; then # Profile
            detect_x "f" "$PROFILES_DIRECTORY/$line"
            profile="$PROFILES_DIRECTORY/$line"
            profile "$profile"
        elif [ "$token" -eq 2 ]; then # Source
            detect_x "x" "$line"
            src="$line"
        elif [ "$token" -eq 3 ]; then # Destination volume
            detect_x "m" "$line"
            volume="$line"
            dest="$line"
        elif [[ "$token" -eq 4 && "$skip" -ne 1 ]]; then # Destination folder
            if [ "$line" != "." ]; then
                isBackup "$profile"
                if [ $backup -ge 1 ]; then
                    local ddate=$(date +"-%m-%d-%Y@%H-%M-%S") # Dash and date
                    dest="$dest/$line$ddate"
                else
                    detect_x "d" "$dest/$line"
                    dest="$dest/$line"
                fi
            fi
        elif [[ "$token" -ge 5 && "$skip" -ne 1 ]]; then # Excludes
            detect_x "x" "$src/$line"
            excludes=("${excludes[@]}" "--exclude=$line")
        fi
        (( token++ ))
    fi
    done < "$CONFIG_FILE"
}

set -e # Exit if any program exists with exit status > 0
shopt -s extglob # Extended pattern matching

VERSION="rsink 0.2+dev"
CONFIG_FILE="config"
PROFILES_DIRECTORY="profiles"
LOG_FILE="log"

# Options parsing
dry=0
silent=0

while : ; do
    case $1 in
        -d | --dry-run)
            dry=1
            shift ;;
        -h | --help | -\?)
            usage
            exit 0 ;;
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
            fail "$1" "Illegal option" ;;
        *)
            break ;;
    esac
done

if [ $silent -eq 1 ]; then
    echo () { : ; } # Redefine echo
fi

main

exit 0
