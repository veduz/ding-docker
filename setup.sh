#!/usr/bin/env bash
if [[ $# -lt 2 ]] ; then
    echo "Syntax: $0 <repo> <branch>"
    exit 1
fi

REPO=$1
BRANCH=$2

CORE_DESTINATION="`pwd`/web"
RAW_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/"

RAW_DRUPAL_MAKE_URL="${RAW_URL}/drupal.make"
RAW_DING_MAKE_URL="${RAW_URL}/ding2.make"

if [[ -d "${CORE_DESTINATION}" ]]; then
    rm -fr "${CORE_DESTINATION}"
fi

# Check if drupal.make and ding.make are present
if ! curl --fail -sL -o /dev/null "${RAW_DRUPAL_MAKE_URL}"; then
    echo "Could not find ${RAW_DRUPAL_MAKE_URL}"
    exit
fi

if ! curl --fail -sL -o /dev/null "${RAW_DING_MAKE_URL}"; then
    echo "Could not find ${RAW_DING_MAKE_URL}"
    exit
fi

echo "Building core"
docker run --rm -v "`pwd`":/var/www/ --workdir=/var/www/ reload/drupal-php7-fpm:php5-experimental drush make -y --projects="drupal" ${RAW_DRUPAL_MAKE_URL} web
echo "Cloning ding2"
git clone "git@github.com:${REPO}.git" --branch="${BRANCH}" "${CORE_DESTINATION}/profiles/ding2"
pushd "${CORE_DESTINATION}/profiles/ding2"
echo "Adding remote"
git remote add ding2-origin https://github.com/ding2/ding2.git
git fetch
popd
echo "Building ding2"
docker run --rm -v `pwd`:/var/www/ --workdir=/var/www/web/profiles/ding2 reload/drupal-php7-fpm:php5-experimental drush make --contrib-destination=profiles/ding2 --no-core -y ding2.make
echo "Building ding_test"
docker run --rm -v `pwd`:/var/www/ --workdir=/var/www/web/profiles/ding2/modules/ding_test reload/drupal-php7-fpm:php5-experimental composer install
echo "Building fbs"
docker run --rm -v `pwd`:/var/www/ --workdir=/var/www/web/profiles/ding2/modules/fbs reload/drupal-php7-fpm:php5-experimental composer install
echo "Running composer install"
docker run -v `pwd`:/var/www --workdir=/var/www reload/drupal-php7-fpm:php5-experimental composer install
