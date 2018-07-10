RED=\033[0;31m
GREEN=\033[0;32m
WHITE=\033[1;37m
RESET=\033[0m

die:
	@echo "${WHITE}make reset: ${RED}Destroy and rebuild site. 💥${RESET}"
	@echo "${WHITE}make site-reset: ${GREEN}Reset site and prepare for development. ${RESET}"
	@echo "${WHITE}make logs: ${GREEN}Tails logs for the stack. ${RESET}"

# Reset site. This could do with some cleanup and splitting into subtargets.
site-reset:
	@echo "${WHITE}Copying sample-assets in place${RESET}"
	mkdir -p web/sites/default/files
	cp -R docker/sample-assets/* web/sites/default/files/

	@# Clear out modules introduced as a part of BBS and thus may be absent depending
	@# on which branch we are on.
	docker-compose exec php sh -c "(test -d /var/www/web/profiles/ding2/modules/aleph || (echo '*** The aleph module is not present in this revision - clearing it from the system table' && drush sql-query \"DELETE from system where name = 'aleph';\")) && \
	(test -d /var/www/web/profiles/ding2/modules/opensearch || (echo '*** The opensearch module is not present in this revision - clearing it from the system table' && drush sql-query \"DELETE from system where name = 'opensearch';\")) && \
	(test -d /var/www/web/profiles/ding2/modules/ding_test || (echo '*** The ding_test module is not present in this revision - clearing it from the system table' && drush sql-query \"DELETE from system where name = 'ding_test';\")) && \
	(test -d /var/www/web/profiles/ding2/modules/primo || (echo '*** The primo module is not present in this revision - clearing it from the system table' && drush sql-query \"DELETE from system where name = 'primo';\"))"

	@echo "\n${WHITE}*** Resetting files ownership and permissions${RESET}"
	docker-compose exec php sh -c "chmod -R u+rw /var/www/web/sites/default/files && \
	chown -R 33 /var/www/web/sites/default"

	@echo "\n${WHITE}*** Drush making${RESET}"
	docker-compose exec php sh -c "drush make -y --no-core --concurrency=4 --contrib-destination=./profiles/ding2 /var/www/web/profiles/ding2/ding2.make"

	@echo "\n${WHITE}*** Composer installing${RESET}"
	docker-compose exec php sh -c "(test ! -f /var/www/web/profiles/ding2/composer.json || composer --working-dir=/var/www/web/profiles/ding2 install)"
	docker-compose exec php sh -c "(test ! -f /var/www/web/profiles/ding2/modules/ding_test/composer.json || composer --working-dir=/var/www/web/profiles/ding2/modules/ding_test install)"
	docker-compose exec php sh -c "(test ! -f /var/www/web/profiles/ding2/modules/fbs/composer.json || composer --working-dir=/var/www/web/profiles/ding2/modules/fbs install)"
	docker-compose exec php sh -c "(test ! -f /var/www/web/profiles/ding2/modules/aleph/composer.json || composer --working-dir=/var/www/web/profiles/ding2/modules/aleph install)"

	@echo "\n${WHITE}*** Running updb and cc all${RESET}"
	docker-compose exec php sh -c "drush updb -y"
	docker-compose exec php sh -c "drush cc all"

	@echo "\n${WHITE}*** Disabling and enabling modules${RESET}"
	@docker-compose exec php sh -c "drush dis alma fbs -y && \
		drush dis ting_covers_addi -y && \
		drush dis ting_fulltext -y && \
		drush dis ting_infomedia -y && \
		drush en syslog -y"

	@if [ -f web/profiles/ding2/modules/ding_test/ding_test.module ]; then \
		echo "\n${WHITE}*** Test module detected, enabling${RESET}"; \
		docker-compose exec php sh -c "drush en ding_test"; \
	fi

	@if [ -f web/profiles/ding2/modules/aleph/aleph.module ]; then \
		echo "\n${WHITE}*** Aleph detected, enabling and disabling Connie${RESET}"; \
		docker-compose exec php sh -c "drush en aleph -y && drush dis connie -y"; \
	else \
		echo "\n${WHITE}*** Using connie${RESET}"; \
		docker-compose exec php sh -c "drush en connie -y"; \
	fi

	@if [ -f web/profiles/ding2/modules/primo/primo.module ]; then \
		echo "\n${WHITE}*** Using primo provider${RESET}"; \
		docker-compose exec php sh -c "drush en primo -y"; \
	else \
		echo "\n${WHITE}*** Using opensearch search provider${RESET}"; \
		docker-compose exec php sh -c "drush en opensearch -y"; \
	fi

	echo "\n${WHITE}*** Running updb${RESET}"
	docker-compose exec php sh -c "drush updb -y"

	echo "\n${WHITE}*** Reverting features${RESET}"
	docker-compose exec php sh -c "drush features-revert-all -y"

	echo "\n${WHITE}*** Setting variables${RESET}"
	docker-compose exec php sh -c "drush variable-set opensearch_url https://opensearch.addi.dk/b3.5_4.5/ && \
	drush variable-set opensearch_search_autocomplete_suggestion_url http://opensuggestion.addi.dk/b3.0_2.0/ && \
	echo '{ \
	    \"index\": \"scanterm.default\", \
	    \"facetIndex\": \"scanphrase.default\", \
	    \"filterQuery\": \"\", \
	    \"sort\": \"count\", \
	    \"agency\": \"100200\", \
	    \"profile\": \"test\", \
	    \"maxSuggestions\": \"10\", \
	    \"maxTime\": \"2000\", \
	    \"highlight\": 0, \
	    \"highlight.pre\": \"\", \
	    \"highlight.post\": \"\", \
	    \"minimumString\": \"3\" \
	}' | drush variable-set --format=json opensearch_search_autocomplete_settings - && \
	drush variable-set opensearch_enable_logging 1 && \
	drush variable-set opensearch_recommendation_url 'http://openadhl.addi.dk/1.1/' && \
	drush variable-set opensearch_search_profile test && \
	drush variable-set ding_serendipity_isslow_timeout 20 && \
	drush variable-set opensearch_agency 100200 && \
	drush variable-set autologout_timeout 36000 && \
	drush variable-set autologout_role_logout 0 && \
	drush variable-set aleph_base_url http://snorri.lb.is/X && \
	drush variable-set aleph_base_url_rest http://snorri.lb.is:1892/rest-dlf && \
	drush variable-set aleph_main_library ICE01 && \
	drush variable-set aleph_enable_logging TRUE && \
	drush variable-set aleph_enable_reservation_deletion TRUE && \
	drush variable-set primo_base_url http://lkbrekdev01.lb.is:1701 && \
	drush variable-set primo_institution_code ICE && \
	drush variable-set primo_sourceid ICE01_PRIMO_TEST && \
	drush variable-set primo_enable_logging TRUE && \
	drush variable-set primo_location_scopes BBAAA,BBRAA,BBFAA,BBGAA,BBKAA,BBSAA,BBLAA,OVERDRIVE,BBNAA"

	echo "\n${WHITE}*** Clearing cache${RESET}"
	docker-compose exec php sh -c "drush cc all"

reset:
	@./scripts/docker-reset.sh

logs:
	@./scripts/docker-logs.sh
