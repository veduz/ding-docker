# Docker for Ding

Still unpolished and in the works.

## Branching
- `master` used when preparing merge from the upstream (ding2-origin/master). 
- `bbs-aleph-provider` used for the Aleph provider module.
- `bbs-master` used for Primo - `bbs-sal` and `bbs-aleph-provider` is merged into this branch.
- `bbs-sal` used for the search abstraction layer aka. SAL.

When merging code from `ding2-origin/master`:
1. Pull `ding2-origin/master` into `master` and push.
2. Create a "merge branch" from `bbs-master`.
3. Merge `master` into the merge branch.
4. Resolve conflicts and push the code.

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
