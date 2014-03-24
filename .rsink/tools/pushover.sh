#!/bin/bash
# Send pushover notification

appl="" # use your own
user="" # use your own

date=`date +"%m-%d-%Y@%H-%M-%S"`

curl -s \
    -F "token=$appl" \
    -F "user=$user" \
    -F "title=rsink transfer complete" \
    -F "message=$date" \
    https://api.pushover.net/1/messages.json > /dev/null
