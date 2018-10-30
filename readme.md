# Quick Start

1.  Clone the repo `git clone git@gitlab.com:ydahi/dev-box.git`.
2.  Copy `conf/SETTINGS.tpl.yml` to `conf/settings.yml`.
3.  You can edit `settings.yml` file with your favourite editor to modify the VM. Edits are not required for the first time your build with this vagrantfile, but subsequent vm builds will require changes to `server:name` and `server:ports:host`
4.  Run `vagrant up` from the same folder as the Vagrantfile to build the VM.
5.  Run `vagrant port` to see which host port is mapped to :80 on guest.
5.  After build complete, visit `http://localhost:hostport` to see apache message.
6.  Run `vagrant ssh` after the build is complete to access the VM.


# Overview

Use this repo to build a VM using Vagrant. The VM specifications are managed using the settings.tpl file. The default settings are:

* Ubuntu 16.04
* Apache
* Mysql
* PHP 7.2 (default) or PHP 5.6
* Composer
* Drush 8


#### Prerequisites

- Vagrant: https://www.vagrantup.com/
- VirtualBox: https://www.virtualbox.org/


#### Defaults
- Webroot from host: http://localhost:*hostport*
- DB user: root
- DB password: root
