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

sync_is_running() {
    docker-sync logs >& /dev/null
}

DOCKER_SYNC=
if [[ $(type -P "docker-sync") && -f "${SCRIPT_DIR}/../docker-sync.yml" ]]; then
    DOCKER_SYNC=1
fi


cd "${SCRIPT_DIR}/../"
# The number of seconds it takes for docker-compose up to get up and running
# often translates to how long it takes the database-container to come up.
SLEEP_BEFORE_RESET=20

# Hostname to send a request to to warm up the cache-cleared site.
HOST="localhost"
WEB_CONTAINER="web"

sudo echo ""

if [[ $DOCKER_SYNC ]]; then
    echoc "*** Performing Initial docker sync"
    docker-sync start || true
    docker-sync sync
fi


# Clear all running containers.
echoc "*** Removing existing containers"
docker-compose kill && docker-compose rm -v -f

# Start up containers in the background and continue imidiately
echoc "*** Starting new containers"

if [[ $DOCKER_SYNC ]]; then
    # "-f" disables the default docker-compose.override.yml behaviour so we
    # need to include it ourselves.
    COMPOSER_OVERRIDE=
    [ -f "docker-compose.override.yml" ] && COMPOSER_OVERRIDE="-f docker-compose.override.yml"
    cmd="docker-compose -f docker-compose.yml -f docker-compose-dev.yml ${COMPOSER_OVERRIDE} up --remove-orphans -d"
else
    cmd="docker-compose up --remove-orphans -d"
fi
eval $cmd


# Sleep while containers are starting up then perform a reset
echoc "*** Waiting ${SLEEP_BEFORE_RESET} seconds for containers to come up"
sleep ${SLEEP_BEFORE_RESET}

# Perform the drupal-specific reset
echoc "*** Resetting Drupal"
"${SCRIPT_DIR}/site-reset.sh"

echoc "*** Requesting ${HOST} in ${WEB_CONTAINER}"
docker-compose exec ${WEB_CONTAINER} curl --silent --output /dev/null -H "Host: ${HOST}" localhost

# Done, bring the background docker-compose logs back into foreground
echoc "*** Done, watching logs"
docker-compose logs -f

