default :
	docker-compose run --rm --no-deps php curl -LOSs https://raw.github.com/ding2/ding2/master/drupal.make
	docker-compose run --rm --no-deps php drush make --contrib-destination=profiles/ding2/ web/drupal.make web --working-copy
	docker-compose run --rm --no-deps php cd profiles/ding2/tests/behat && composer install
	docker-compose up -d

login :
	docker-compose run --rm --no-deps drush uli --uri=ding2.docker
