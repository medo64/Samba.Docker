#!/bin/sh
SCRIPT_NAME=`basename $0`

function log() {  # log LEVEL TEXT
    FLOG_TIME="`date +'%F'` `nmeter -d0 '%3t' | head -n1`"
    FLOG_CATEGORY=init
    FLOG_LEVEL="$1"
    FLOG_TEXT="$2"

    LOG_LEVEL_INDEX=2
    case $LOG_LEVEL in
        TRACE) LOG_LEVEL_INDEX=0 ;;
        DEBUG) LOG_LEVEL_INDEX=1 ;;
        INFO*) LOG_LEVEL_INDEX=2 ;;
        WARN*) LOG_LEVEL_INDEX=3 ;;
        ERROR) LOG_LEVEL_INDEX=4 ;;
        FATAL) LOG_LEVEL_INDEX=5 ;;
    esac

    case $FLOG_LEVEL in
        TRACE) [ 0 -ge "$LOG_LEVEL_INDEX" ] && printf "\e[34m$FLOG_TIME TRACE \e[34m$FLOG_CATEGORY: $FLOG_TEXT\e[0m\n" ;;
        DEBUG) [ 1 -ge "$LOG_LEVEL_INDEX" ] && printf "\e[34m$FLOG_TIME DEBUG \e[94m$FLOG_CATEGORY: $FLOG_TEXT\e[0m\n" ;;
        INFO)  [ 2 -ge "$LOG_LEVEL_INDEX" ] && printf "\e[36m$FLOG_TIME INFO  \e[96m$FLOG_CATEGORY: $FLOG_TEXT\e[0m\n" ;;
        WARN)  [ 3 -ge "$LOG_LEVEL_INDEX" ] && printf "\e[33m$FLOG_TIME WARN  \e[93m$FLOG_CATEGORY: $FLOG_TEXT\e[0m\n" >&2 ;;
        ERROR) [ 4 -ge "$LOG_LEVEL_INDEX" ] && printf "\e[31m$FLOG_TIME ERROR \e[91m$FLOG_CATEGORY: $FLOG_TEXT\e[0m\n" >&2 ;;
        FATAL) printf "\e[31m$FLOG_TIME FATAL \e[1;91m$LOG_CATEGORY: $LOG_TEXT\e[0m\n" >&2 ;;
        *)     printf "$FLOG_TIME  ???  $FLOG_CATEGORY: $FLOG_TEXT\n" ;;
    esac
}

PID_FILE="/var/run/.$SCRIPT_NAME.pid"
if [ -e "$PID_FILE" ]; then
    PID_LAST=$(cat "$PID_FILE")
    if ps -axo pid | grep -q "^ *$PID_LAST\$"; then
        echo "${ANSI_RED}$SCRIPT_NAME: script is already running!${ANSI_RESET}" >&2
        exit 255
    fi
fi
echo $$ > $PID_FILE
trap "rm $PID_FILE 2>/dev/null" 0
trap "exit 113" INT TERM

USERS=`echo "$USERS" | tr ';' ' ' | xargs`
if ! [ -z "$USERS" ]; then
    for USERDEF in $USERS; do
        USERNAME=`echo $USERDEF | cut -sd: -f2`
        if [ -z "$USERNAME" ]; then
            log INFO "Adding user $USERDEF"
            adduser -D -H -s /bin/false $USERDEF
        else
            USERID=`echo $USERDEF | cut -sd: -f1`
            log INFO "Adding user $USERNAME ($USERID)"
            adduser -D -H -s /bin/false -u $USERID $USERNAME
        fi
    done
fi


log DEBUG "smbd $(smbd --version | cut -d' ' -f2)"

log INFO "Running samba service"

if [ -z "$DEBUG_LEVEL" ]; then DEBUG_LEVEL=0; fi
log DEBUG "Using samba debug level $DEBUG_LEVEL"

while (true); do
    smbd --foreground --no-process-group --debuglevel=$DEBUG_LEVEL --debug-stdout \
        2>&1 | sed '/^$/d' | sed 's/^/                              /'

    log WARN "Restarting samba service"
done
