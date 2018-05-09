#!/usr/bin/env bash
# Tail logs

set -euo pipefail
IFS=$'\n\t'
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echoc () {
    GREEN=$(tput setaf 2)
    RESET=$(tput sgr0)
	echo -e "${GREEN}$1${RESET}"
}

cd "${SCRIPT_DIR}/../"

if [[ $(type -P "recode") ]]; then
    # Watchdog escapes htmlentities so use recode (if available) to decode.
    docker-compose logs -f | recode html
else
    docker-compose logs -f
fi
