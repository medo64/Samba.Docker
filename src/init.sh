#!/bin/sh

ANSI_MAGENTA="\e[95m"
ANSI_RESET="\e[0m"

echo -e "${ANSI_MAGENTA}Entrypoint reached${ANSI_RESET}"
echo

if [ -z "$DEBUGLEVEL" ]; then
    DEBUGLEVEL=0
fi

smbd --foreground --no-process-group --debuglevel=$DEBUGLEVEL --debug-stdout
