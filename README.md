# Docker for Ding

Still unpolished and in the works.

## Preparation

### Install Docker
https://www.docker.com/community-edition#/download

### Install dory
__If you're running MacOS update ruby first:__ ```brew install ruby```
```
sudo gem install dory
```

#### Start dory
```
dory up
```

### Start containers
```sh
docker-compose up
```

## Setup
Make Drupal site and ding2 profile
```
./setup.sh rvk-utd/ding2 bbs-master
```

Ensure variables are set
```
make site-reset
```

Start project on Mac
```
docker-sync-stack start
```

Start project on Linux/Windows
```
docker-compose up
```

### Go to https://ding2-bbs.docker

#### Stuff not polished yet

* memcache setup
* varnish only one way
