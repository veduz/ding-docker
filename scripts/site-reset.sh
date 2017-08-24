#!/usr/bin/env bash
# Prepares a site for development.
# The assumption is that we're bootstrapping with a database-dump from
# another environment, and need to import configuration and run updb.

set -euo pipefail
IFS=$'\n\t'
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Copying sample-assets in place"
cp -R ${SCRIPT_DIR}/../docker/sample-assets/* "${SCRIPT_DIR}/../web/sites/default/files/"

# Reset the site. If the aleph module exists, run composer for it and enable it
# if it does not exist, enable the connie module.
time docker-compose run --entrypoint "sh -c" --rm php " \
  (test -d /var/www/web/profiles/ding2/modules/aleph ; composer --working-dir=/var/www/web/profiles/ding2/modules/aleph install) && \
  composer --working-dir=/var/www/web/profiles/ding2/modules/ding_test install && \
  composer --working-dir=/var/www/web/profiles/ding2/modules/fbs install && \
  drush dis alma -y && \
  (test -d /var/www/web/profiles/ding2/modules/aleph ; drush en aleph -y) && \
  (test -d /var/www/web/profiles/ding2/modules/aleph || drush en connie -y) && \
  drush en ding_test -y && \
  drush updb -y && \
  drush vset ting_search_url http://oss-services.dbc.dk/opensearch/4.2/ && \
  drush vset ting_search_profile test && \
  drush vset ting_agency 100200 && \
  drush vset autologout_timeout 36000 && \
  drush vset aleph_base_url http://snorri.lb.is/X && \
  drush vset aleph_base_url_rest http://snorri.lb.is:1892/rest-dlf && \
  drush vset aleph_main_library ICE01 && \
  drush vset aleph_enable_logging TRUE && \
  drush cc all
  "
