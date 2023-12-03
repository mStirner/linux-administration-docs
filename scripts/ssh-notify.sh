#!/bin/sh

message="Somethin append via ssh" 
timestamp=$(date +"%d.%m.%Y - %k:%M")

# logout happend
if [ "$PAM_TYPE" == "close_session" ]; then
        message="Logout: $PAM_USER from $PAM_RHOST"
fi

# login happend
if [ "$PAM_TYPE" == "open_session" ]; then
	message="Login: $PAM_USER from $PAM_RHOST"
fi

# do api request to gotfiy server
curl "http://example.com/message?token=xxxx" -F "title=SSH Session" -F "message=$message - $timestamp" -F "priority=5"

# allways exit sucessfully
exit 0;

# Change these two lines:
#sender="sender-address@example.com"
#recepient="notify-address@example.org"
#
#if [ "$PAM_TYPE" != "close_session" ]; then
#    host="`hostname`"
#    subject="SSH Login: $PAM_USER from $PAM_RHOST on $host"
#    # Message to send, e.g. the current environment variables.
#    message="`env`"
#    echo "$message" | mailx -r "$sender" -s "$subject" "$recepient"
#fi