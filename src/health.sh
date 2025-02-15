#!/bin/sh

ANSI_RESET="\e[0m"
ANSI_RED="\e[91m"
ANSI_GREEN="\e[92m"

if nc -z -w 3 localhost 445 2>/dev/null; then  # initial connection is always 5 seconds
    echo -e "${ANSI_GREEN}Healthy${ANSI_RESET}"
    exit 0
else
    echo -e "${ANSI_RED}Not healthy${ANSI_RESET}"
    exit 1
fi
