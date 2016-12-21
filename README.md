# Docker for Ding

Still unpolished and in the works.

## Preparation

Get a ding make file
```sh
% curl -LOSs https://raw.github.com/ding2/ding2/master/drupal.make
```

Build the site with drush make:
```sh
% drush make --contrib-destination=profiles/ding2/ drupal.make web
```

Then you can start the Docker containers:
```sh
% docker-compose up
```

## Install ding

From inside the docker web containers document root (`/var/www/html`) do:
```sh
% drush site-install ding2
```

## Stuff not polished yet

* memcache setup
* varnish only one way
