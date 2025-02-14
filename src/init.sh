#!/bin/sh

ANSI_MAGENTA="\e[95m"
ANSI_RESET="\e[0m"

echo -e "${ANSI_MAGENTA}Entrypoint reached${ANSI_RESET}"
echo

if [ -z "$DEBUG_LEVEL" ]; then DEBUG_LEVEL=0; fi
echo -e "${ANSI_MAGENTA}Using debug level $DEBUG_LEVEL${ANSI_RESET}"
echo

USERS=`echo "$USERS" | tr ';' ' ' | xargs`
if ! [ -z "$USERS" ]; then
    for USERDEF in $USERS; do
        USERNAME=`echo $USERDEF | cut -sd: -f2`
        if [ -z "$USERNAME" ]; then
            echo -e "${ANSI_MAGENTA}Adding user $USERDEF${ANSI_RESET}"
            adduser -D -H -s /bin/false $USERDEF
        else
            USERID=`echo $USERDEF | cut -sd: -f1`
            echo -e "${ANSI_MAGENTA}Adding user $USERNAME ($USERID)${ANSI_RESET}"
            adduser -D -H -s /bin/false -u $USERID $USERNAME
        fi
    done
    echo
fi

echo -e "${ANSI_MAGENTA}$(smbd --version)${ANSI_RESET}"
echo

smbd --foreground --no-process-group --debuglevel=$DEBUG_LEVEL --debug-stdout
