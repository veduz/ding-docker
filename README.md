# Docker for Ding

Still unpolished and in the works.

## Preparation

### Install Drush
```
composer install
```

### Download ding2 makefile
```sh
curl -O https://raw.github.com/ding2/ding2/master/drupal.make
```

### Build the site with drush make
```sh
./vendor/bin/drush make --contrib-destination=profiles/ding2/ drupal.make web
```

### Install dory
__If you're running MacOS update ruby first:__ ```brew install ruby```
```
sudo gem install dory
```

### Start dory
```
dory up 
```

### Start containers
```sh
docker-compose up
```

### Go to https://ding2-bbs.docker

#### Stuff not polished yet

* memcache setup
* varnish only one way
