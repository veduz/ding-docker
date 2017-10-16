#!/usr/bin/env bash
# Prepares a site for development.
# The assumption is that we're bootstrapping with a database-dump from
# another environment, and need to import configuration and run updb.

set -euo pipefail
IFS=$'\n\t'
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Copying sample-assets in place"
cp -R ${SCRIPT_DIR}/../docker/sample-assets/* "${SCRIPT_DIR}/../web/sites/default/files/"

# Reset the site.
# - If the aleph module exists, run composer for it and enable it
# - If not enable connie and , "uninstall" aleph it manually by clearing it from
#   the system table not to confuse core to much. This can happen as we have
#   branches that does not have the aleph module.
# - If it does not exist, enable the connie module.
time docker-compose run --entrypoint "sh -c" --rm php " \
  echo '*** Resetting files ownership and permissions' && \
  chmod -R u+rw /var/www/web/sites/default/files && \
  chown -R 33 /var/www/web/sites/default && \
  echo '*** Composer installing' && \
  (test ! -f /var/www/web/profiles/ding2/composer.json || composer --working-dir=/var/www/web/profiles/ding2 install) && \
  composer --working-dir=/var/www/web/profiles/ding2/modules/ding_test install && \
  composer --working-dir=/var/www/web/profiles/ding2/modules/fbs install && \
  (test ! -d /var/www/web/profiles/ding2/modules/aleph || composer --working-dir=/var/www/web/profiles/ding2/modules/aleph install) && \
  (test -d /var/www/web/profiles/ding2/modules/aleph || drush sql-query \"DELETE from system where name = 'aleph';\") && \
  echo '*** Disabling and enabling modules' && \
  drush dis alma -y && \
  drush dis ting_fulltext -y && \
  drush en ding_test -y && \
  drush en syslog -y && \
  (test ! -d /var/www/web/profiles/ding2/modules/aleph || (echo '*** Aleph detected, enabling and disabling Connie' && drush en aleph -y && drush dis connie -y)) && \
  (test -d /var/www/web/profiles/ding2/modules/aleph || (echo '*** Using connie' && drush en connie -y)) && \
  (test -d /var/www/web/profiles/ding2/modules/opensearch || (echo '*** Using opesearch search provider' && drush en opensearch -y)) && \
  echo '*** Running updb' && \
  drush updb -y && \
  echo '*** Setting variables' && \
  drush variable-set ting_search_url https://opensearch.addi.dk/b3.5_4.5/ && \
  drush variable-set ting_enable_logging 1 && \
  drush variable-set ting_search_profile test && \
  drush variable-set ding_serendipity_isslow_timeout 20 && \
  drush variable-set ting_agency 100200 && \
  drush variable-set autologout_timeout 36000 && \
  drush variable-set autologout_role_logout 0 && \
  drush variable-set aleph_base_url http://snorri.lb.is/X && \
  drush variable-set aleph_base_url_rest http://snorri.lb.is:1892/rest-dlf && \
  drush variable-set aleph_main_library ICE01 && \
  drush variable-set aleph_enable_logging TRUE && \
  echo '*** Clearing cache' && \
  drush cc all
  "
