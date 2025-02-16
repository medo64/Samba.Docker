#!/bin/sh
#~ Docker Project
SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
SCRIPT_NAME=`basename $0`

if [ -t 1 ]; then
    ANSI_RESET="$(tput sgr0)"
    ANSI_RED="`[ $(tput colors) -ge 16 ] && tput setaf 9 || tput setaf 1 bold`"
    ANSI_YELLOW="`[ $(tput colors) -ge 16 ] && tput setaf 11 || tput setaf 3 bold`"
    ANSI_MAGENTA="`[ $(tput colors) -ge 16 ] && tput setaf 13 || tput setaf 5 bold`"
    ANSI_PURPLE="$(tput setaf 5)"
    ANSI_CYAN="`[ $(tput colors) -ge 16 ] && tput setaf 14 || tput setaf 6 bold`"
fi

if [ "$1" = "" ]; then ACTIONS="release"; else ACTIONS="$@"; fi


if ! [ -e "$SCRIPT_DIR/.meta" ]; then
    echo "${ANSI_RED}Meta file not found${ANSI_RESET}"
    exit 113
fi

if ! command -v git >/dev/null; then
    echo "${ANSI_YELLOW}Missing git command${ANSI_RESET}"
fi


HAS_CHANGES=$( git status -s 2>/dev/null | wc -l )
if [ "$HAS_CHANGES" -gt 0 ]; then
    echo "${ANSI_YELLOW}Uncommitted changes present${ANSI_RESET}"
fi


GIT_VERSION=$( git tag --points-at HEAD | grep --color=always -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sed -n 1p | sed 's/^v//g' | xargs )
GIT_INDEX=$( git rev-list --count HEAD )
GIT_HASH=$( git log -n 1 --format=%h )

if [ "$GIT_VERSION" != "" ]; then
    echo "${ANSI_PURPLE}Tag version .: ${ANSI_MAGENTA}$GIT_VERSION${ANSI_RESET}"
else
    echo "${ANSI_PURPLE}Tag version .: ${ANSI_MAGENTA}-${ANSI_RESET}"
fi
echo "${ANSI_PURPLE}Revision ....: ${ANSI_MAGENTA}$GIT_HASH${ANSI_PURPLE} (${ANSI_MAGENTA}$GIT_INDEX${ANSI_PURPLE})${ANSI_RESET}"


prereq_docker() {
    DOCKER_IMAGE=$( cat "$SCRIPT_DIR/.meta" | grep -E "^DOCKER_IMAGE=" | sed  -n 1p | cut -d= -sf2 | xargs )
    DOCKER_IMAGE_ID=$( echo "$DOCKER_IMAGE" | cut -d/ -sf1 )
    DOCKER_IMAGE_NAME=$( echo "$DOCKER_IMAGE" | cut -d/ -f2 )
    if [ "$DOCKER_IMAGE_ID" != "" ] && [ "$DOCKER_IMAGE_NAME" != "" ]; then
        echo "${ANSI_PURPLE}Docker image : ${ANSI_MAGENTA}$DOCKER_IMAGE_ID/$DOCKER_IMAGE_NAME${ANSI_RESET}"
    else
        echo "${ANSI_PURPLE}Docker image : ${ANSI_RED}not found${ANSI_RESET}"
        exit 113
    fi

    if ! command -v docker >/dev/null; then
        echo "${ANSI_RED}Missing docker command${ANSI_RESET}"
        exit 113
    fi
}


make_docker() {
    echo
    echo "${ANSI_MAGENTA}┏━━━━━━━━┓${ANSI_RESET}"
    echo "${ANSI_MAGENTA}┃ DOCKER ┃${ANSI_RESET}"
    echo "${ANSI_MAGENTA}┗━━━━━━━━┛${ANSI_RESET}"
    echo

    if [ "$GIT_VERSION" != "" ]; then
        docker build \
            -t $DOCKER_IMAGE_NAME:$GIT_VERSION \
            -t $DOCKER_IMAGE_NAME:latest \
            -t $DOCKER_IMAGE_NAME:unstable \
            -f src/Dockerfile . \
            && echo "${ANSI_CYAN}$DOCKER_IMAGE_NAME:$GIT_VERSION $DOCKER_IMAGE_NAME:latest $DOCKER_IMAGE_NAME:unstable${ANSI_RESET}"

        mkdir -p "$SCRIPT_DIR/dist"
        docker save \
            $DOCKER_IMAGE_NAME:$GIT_VERSION \
            | gzip > ./dist/$DOCKER_IMAGE_NAME.$GIT_VERSION.tgz \
            && echo "${ANSI_CYAN}dist/$DOCKER_IMAGE_NAME-$GIT_VERSION.tgz${ANSI_RESET}"
    else
        docker build \
            -t $DOCKER_IMAGE_NAME:unstable \
            -f src/Dockerfile . \
            && echo "${ANSI_CYAN}$DOCKER_IMAGE_NAME:unstable${ANSI_RESET}"
    fi
}

make_publish() {
    echo
    echo "${ANSI_MAGENTA}┏━━━━━━━━━┓${ANSI_RESET}"
    echo "${ANSI_MAGENTA}┃ PUBLISH ┃${ANSI_RESET}"
    echo "${ANSI_MAGENTA}┗━━━━━━━━━┛${ANSI_RESET}"
    echo

    if [ "$GIT_VERSION" != "" ]; then
        docker tag \
            $DOCKER_IMAGE_NAME:$GIT_VERSION \
            $DOCKER_IMAGE_ID/$DOCKER_IMAGE_NAME:$GIT_VERSION
        docker push \
            $DOCKER_IMAGE_ID/$DOCKER_IMAGE_NAME:$GIT_VERSION \
        && echo "${ANSI_CYAN}$DOCKER_IMAGE_ID/$DOCKER_IMAGE_NAME:$GIT_VERSION${ANSI_RESET}"
        echo

        docker tag \
            $DOCKER_IMAGE_NAME:latest \
            $DOCKER_IMAGE_ID/$DOCKER_IMAGE_NAME:latest
        docker push \
            $DOCKER_IMAGE_ID/$DOCKER_IMAGE_NAME:latest \
        && echo "${ANSI_CYAN}$DOCKER_IMAGE_ID/$DOCKER_IMAGE_NAME:latest${ANSI_RESET}"
        echo
    fi

	docker tag \
        $DOCKER_IMAGE_NAME:unstable \
        $DOCKER_IMAGE_ID/$DOCKER_IMAGE_NAME:unstable
	docker push \
        $DOCKER_IMAGE_ID/$DOCKER_IMAGE_NAME:unstable \
        && echo "${ANSI_CYAN}$DOCKER_IMAGE_ID/$DOCKER_IMAGE_NAME:unstable${ANSI_RESET}"

}


for ACTION in $ACTIONS; do
    case $ACTION in
        docker)  prereq_docker && make_docker                 || exit 113 ;;
        publish) prereq_docker && make_docker && make_publish || exit 113 ;;

        *) echo "Unknown action $ACTION" >&2 || exit 113 ;;
    esac
done

exit 0
