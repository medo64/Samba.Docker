#!/bin/sh

ANSI_MAGENTA="\e[95m"
ANSI_RESET="\e[0m"

echo -e "${ANSI_MAGENTA}Entrypoint reached${ANSI_RESET}"
echo

if [ -z "$DEBUG_LEVEL" ]; then DEBUG_LEVEL=0; fi
echo -e "${ANSI_MAGENTA}Using debug level $DEBUG_LEVEL${ANSI_RESET}"
echo

if [ "$EXPLICIT_NETWORK_CONFIG" == "1" ] || [ "$EXPLICIT_NETWORK_CONFIG" == "true" ] || [ "$EXPLICIT_NETWORK_CONFIG" == "yes" ]; then
    EXPLICIT_NETWORK_CONFIG=1
    echo -e "${ANSI_MAGENTA}Using network configuration from smb.conf${ANSI_RESET}"
    echo
else
    EXPLICIT_NETWORK_CONFIG=0
fi

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

if [ $EXPLICIT_NETWORK_CONFIG -eq 0 ]; then
    smbd --foreground --no-process-group --debuglevel=$DEBUG_LEVEL --debug-stdout \
         --option=interfaces=* --option=bind\ interfaces\ only=no --option=hosts\ allow=0.0.0.0.0/0 --option=hosts\ deny=0.0.0.0.0/32
else
    smbd --foreground --no-process-group --debuglevel=$DEBUG_LEVEL --debug-stdout
fi
