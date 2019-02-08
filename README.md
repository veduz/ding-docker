# Docker for Ding

Still unpolished and in the works.

## Prerequisites

This project assumes that the following software is installed and working on your machine:

- [Docker and docker-compose](https://www.docker.com/community-edition#/download)
- [Drush 8.x](http://docs.drush.org/en/8.x/install/)

## Preparation

Clone this repository
```sh
% git clone https://github.com/reload/ding-docker.git
% cd ding-docker
```

Get a ding make file
```sh
% curl -LOSs https://raw.github.com/ding2/ding2/master/drupal.make
```

Build the site with drush make:
```sh
% drush make --contrib-destination=profiles/ding2/ drupal.make web --working-copy
```

(or maybe `docker run -v $(pwd):/app drush/drush:8` instead of drush if not installed?)

### Then you can start the Docker containers:

If you're using docker-sync for Mac, you can use:

```sh
% docker-sync-stack start
```

otherwise, you can use vanilla docker-compose:

```sh
% docker-compose up
```

You should then be able to access the site.

If the site does not look right then run:

```sh
% docker-compose exec php drush css-generate
% docker-compose exec php drush cc all
```

### Using a custom version of the codebase

To use a custom version of the code base then first complete the steps above. add your fork as a remote to the profile and checkout your branch:

```sh
% cd web/profiles/ding2
% git remote add [remote name] [remote repository url]
% git fetch [remote name]
% git checkout -t [remote name]/[remote branch]
```

In the following example we work with the `master` branch from the Reload fork of Ding2:

```sh
% cd web/profiles/ding2
% git remote add reload git@github.com:reload/ding2.git
% git fetch reload
% git checkout -t reload/master
```


Note that you may have to clear the cache, download new dependencies or even reinstall the site to make the changes take effect.

## Install ding

This setup includes a database containing data from a clean installation of the latest version of Ding. Thus the system is already installed.

If you want to run the install profile yourself you have to drop the contents of the datase first. After that running the install profile can sometimes be tricky.

The sure-fire way (especially on Mac) is to run the install script through the browser:
http://local.docker/install.php (Use the ding2 profile)

Notice: This way can be pretty slow.


A faster, but not-so-sure way is to run the install-script through Drush:

From inside the docker web containers document root (`/var/www/html`) do:
```sh
% drush site-install ding2
```

## Stuff not polished yet

* varnish only one way
* the drush container does not have access to the SOAP connection that the web container has. This makes it fail on site-install sometimes
