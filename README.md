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

Running the install profile can sometimes be tricky.

The sure-fire way (especially on Mac) is to run the install script through the browser: 
http://local.docker/install.php (Use the ding2 profile)

Notice: This way can be pretty slow.


A faster, but not-so-sure way is to run the install-script through Drush:

From inside the docker web containers document root (`/var/www/html`) do:
```sh
% drush site-install ding2
```

## Stuff not polished yet

* memcache setup
* varnish only one way
* the drush container does not have access to the SOAP connection that the web container has. This makes it fail on site-install sometimes
