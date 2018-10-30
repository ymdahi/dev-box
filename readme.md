# Quick Start

1.  Clone the repo
2.  Copy `conf/SETTINGS.tpl.yml` to `conf/settings.yml`.
3.  You can edit `settings.yml` file with your favourite editor to modify the VM.
4.  Run `vagrant up` from the same folder as the Vagrantfile to build the VM.
5.  Run `vagrant port` to see which host port is mapped to :80 on guest.
5.  After build complete, visit `http://localhost:hostport` to see apache message.
6.  Run `vagrant ssh` after the build is complete to access the VM.


# Overview

Use this repo to build a VM using Vagrant. The VM specifications are managed using the settings.tpl file. The default settings are:

* Ubuntu 16.04 (Xenial)
* Apache (latest)
* MySQL (latest)
* PHP 7.2 (default) or PHP 5.6
* Composer
* Drush 8


#### Prerequisites

- Vagrant: https://www.vagrantup.com/
- VirtualBox: https://www.virtualbox.org/


#### Defaults
- Webroot from host: http://localhost:*hostport*
- DB root user password: root


#### PHP

* Both PHP 5.6 and PHP 7.2 are installed at /user/bin/php[version].
* PHP 7.2 is the default
* You can view php version with `update-alternatives --list php`
* You switch between versions with: `update-alternatives --set php /usr/bin/phpXX`, where XX is the version you want to switch to.
* The following PHP modules are also installed for each version:
  * `php-curl php-dev php-gd php-mbstring php-zip php-mysql php-xml php-json`