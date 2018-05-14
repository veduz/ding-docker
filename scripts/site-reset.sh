#!/usr/bin/env bash
# Prepares a site for development.
# The assumption is that we're bootstrapping with a database-dump from
# another environment, and need to import configuration and run updb.

cd /var/www/web

echo "Copying sample-assets in place"
mkdir -p sites/default/files
cp -R /root/docker/sample-assets/* sites/default/files/

# Clear out modules introduced as a part of BBS and thus may be absent depending
# on which branch we're on.
(test -d profiles/ding2/modules/aleph || (echo '*** The aleph module is not present in this revision - clearing it from the system table' && drush sql-query \"DELETE from system where name = 'aleph';\"))
(test -d profiles/ding2/modules/opensearch || (echo '*** The opensearch module is not present in this revision - clearing it from the system table' && drush sql-query \"DELETE from system where name = 'opensearch';\"))
(test -d profiles/ding2/modules/ding_test || (echo '*** The ding_test module is not present in this revision - clearing it from the system table' && drush sql-query \"DELETE from system where name = 'ding_test';\"))
(test -d profiles/ding2/modules/primo || (echo '*** The primo module is not present in this revision - clearing it from the system table' && drush sql-query \"DELETE from system where name = 'primo';\"))

# General reset of the site.
# - Basic fixes of permission
# - Run composer install for a list of modules we know to need it (if they're
#   present on the current branch.
# - Disable alma and fbs (known default providers) if present
# - If the primo module exists then enable it
# - If the aleph module exists enable it, if not enable the connie module.
# - Disable ding modules not used by bbs (eg ting_fulltext and ting_infomedia)
# - Switch to syslog to be able to monitor logs via standard out.
# - Run updb and set a number of default variable values.
echo '*** Resetting files ownership and permissions'
chmod -R u+rw sites/default/files
chown -R www-data sites/default
echo '*** Drush making'
drush make -y --no-core --concurrency=4 --contrib-destination=./profiles/ding2 profiles/ding2/ding2.make
echo '*** Running composer install'
(test ! -f profiles/ding2/composer.json || composer --working-dir=profiles/ding2 install)
(test ! -f profiles/ding2/modules/ding_test/composer.json || composer --working-dir=profiles/ding2/modules/ding_test install)
(test ! -f profiles/ding2/modules/fbs/composer.json || composer --working-dir=profiles/ding2/modules/fbs install)
(test ! -f profiles/ding2/modules/aleph/composer.json || composer --working-dir=profiles/ding2/modules/aleph install)
cd /var/www/web
echo '*** Run css-generate'
drush css-generate
echo '*** Running updb'
drush updb -y
drush cc all
echo '*** Enabling and disabling modules'
drush dis alma fbs ting_covers_addi ting_fulltext ting_infomedia -y
drush en syslog -y
(test ! -f profiles/ding2/modules/ding_test/ding_test.module || drush en ding_test)
(test ! -f profiles/ding2/modules/aleph/aleph.module || (echo \'*** Aleph detected, enabling and disabling Connie\' && drush en aleph -y && drush dis connie -y))
(test -f profiles/ding2/modules/aleph/aleph.module || (echo \'*** Using connie\' && drush en connie -y))
(test ! -f profiles/ding2/modules/primo/primo.module || (echo \'*** Using primo provider\' && drush en primo -y))
(test -f profiles/ding2/modules/opensearch/opensearch.module || (echo \'*** Using opensearch search provider\' && drush en opensearch -y))
echo '*** Running updb'
drush updb -y
echo '*** Reverting features'
drush features-revert-all -y
echo '*** Setting variables'
drush variable-set opensearch_url https://opensearch.addi.dk/b3.5_4.5/
drush variable-set opensearch_search_autocomplete_suggestion_url http://opensuggestion.addi.dk/b3.0_2.0/
echo '
{
  \"index\": \"scanterm.default\",
  \"facetIndex\": \"scanphrase.default\",
  \"filterQuery\": \"\",
  \"sort\": \"count\",
  \"agency\": \"100200\",
  \"profile\": \"test\",
  \"maxSuggestions\": \"10\",
  \"maxTime\": \"2000\",
  \"highlight\": 0,
  \"highlight.pre\": \"\",
  \"highlight.post\": \"\",
  \"minimumString\": \"3\"
}' | drush variable-set --format=json opensearch_search_autocomplete_settings -
drush variable-set opensearch_enable_logging 1
drush variable-set opensearch_recommendation_url 'http://openadhl.addi.dk/1.1/'
drush variable-set opensearch_search_profile test
drush variable-set ding_serendipity_isslow_timeout 20
drush variable-set opensearch_agency 100200
drush variable-set autologout_timeout 36000
drush variable-set autologout_role_logout 0
drush variable-set aleph_base_url http://snorri.lb.is/X
drush variable-set aleph_base_url_rest http://snorri.lb.is:1892/rest-dlf
drush variable-set aleph_main_library ICE01
drush variable-set aleph_enable_logging TRUE
drush variable-set aleph_enable_reservation_deletion TRUE
drush variable-set primo_base_url http://lkbrekdev01.lb.is:1701
drush variable-set primo_institution_code ICE
drush variable-set primo_sourceid ICE01_PRIMO_TEST
drush variable-set primo_enable_logging TRUE
drush variable-set primo_location_scopes BBAAA,BBRAA,BBFAA,BBGAA,BBKAA,BBSAA,BBLAA,OVERDRIVE,BBNAA
echo '*** Clearing cache'
drush cc all
