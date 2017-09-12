#!/usr/bin/env bash
# Removes all containers and starts up a clean environment
# Invokes site-reset.sh after container startup.

set -euo pipefail
IFS=$'\n\t'
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echoc () {
    GREEN=$(tput setaf 2)
    RESET=$(tput sgr 0)
	echo -e "${GREEN}$1${RESET}"
}

cd "${SCRIPT_DIR}/../"
# The number of seconds it takes for docker-compose up to get up and running
# often translates to how long it takes the database-container to come up.
SLEEP_BEFORE_RESET=20

echoc "*** Stopping docker sync"
docker-sync stop

echoc "*** Performing Initial docker sync"
docker-sync sync

echoc "*** Starting deamonized docker-sync"
docker-sync --daemon

# Clear all running containers.
echoc "*** Removing existing containers"
docker-compose kill && docker-compose rm -v -f

# Start up containers in the background and continue imidiately
echoc "*** Starting new containers"
docker-compose -f docker-compose.yml -f docker-compose-dev.yml up --remove-orphans -d

# Sleep while containers are starting up then perform a reset
echoc "*** Waiting ${SLEEP_BEFORE_RESET} seconds for containers to come up"
sleep ${SLEEP_BEFORE_RESET}

# Perform the drupal-specific reset
echoc "*** Resetting Drupal"
"${SCRIPT_DIR}/site-reset.sh"

# Done, bring the background docker-compose logs back into foreground
echoc "*** Done, watching logs"
docker-compose logs -f

