#!/bin/bash

########################################################
#
# file: provision.sh
# This script will provision the VM using configurations
# provided in the settings.yml file.
#
########################################################

# YAML Parser for Bash
# From https://gist.github.com/pkuczynski/8665367
parse_yaml() {
  local prefix=$2
  local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
  sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
  awk -F$fs '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
    if (length($3) > 0) {
        vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
        printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
    }
  }'
}
eval $(parse_yaml /vagrant/conf/settings.yml "settings_")
  

# main routine.
main() {
  update_os_go
  tools_go
  apache_go
  mysql_go
  php_go
  composer_go
  drush_go
  apt_clean_go
  complete_go
}

# Update the VM's OS and packages
update_os_go() {
  echo '===================================='
  echo 'Update OS'
  echo '===================================='

  # apply any available updates
  if [ "$settings_provision_skip_os_update" = "false" ]
  then
    apt-get -y update
    apt-get -y upgrade
  else
    echo '|>| SKIPPING: skip_os_update set to true'
    echo ''
  fi

  echo '--'
}

# clean up after apt updates and installs
apt_clean_go() {
  if [ "$settings_provision_skip_os_clean" = "false" ]
  then
    apt-get -y autoremove
    apt-get -y autoclean
  else
    echo '|>| SKIPPING: skip_os_clean set to true'
    echo ''
  fi

  echo '--'
}

# Install any tools
tools_go() {
  echo '===================================='
  echo 'Provision Tools'
  echo '===================================='

  if [ "$settings_provision_tools_install" = "true" ]
  then
    apt-get -y install $settings_provision_tools_packages
  else 
    echo '|>| SKIPPING: tools.install is set to false'
    echo ''
  fi

  echo '--'
}

# Install apache
apache_go() {
  echo '===================================='
  echo 'Provision Apache'
  echo '===================================='

  if [ "$settings_provision_apache_install" = "true" ]
  then
    apt-get -y install apache2
    service apache2 start
  else 
    echo '|>| SKIPPING: apache.install is set to false'
    echo ''
  fi
 
  echo '--'
  service apache2 status
  echo '--'
}

# Install MySQL
mysql_go() {
  echo '===================================='
  echo 'Provision MySQL'
  echo '===================================='

  if [ "$settings_provision_mysql_install" = "true" ]
  then
    echo mysql-server mysql-server/root_password password root | debconf-set-selections
    echo mysql-server mysql-server/root_password_again password root | debconf-set-selections
    apt-get -y install mysql-server
    cp /vagrant/conf/mysql/mysql-overrides.cnf /etc/mysql/conf.d/mysql-overrides.cnf
    service mysql start
    mysql -u root -p"$settings_provision_mysql_root_pw" -e "CREATE USER '$settings_provision_mysql_db_user'@'localhost' IDENTIFIED BY '$settings_provision_mysql_db_pw';"
    mysql -u root -p"$settings_provision_mysql_root_pw" -e "GRANT ALL PRIVILEGES ON * . * TO '$settings_provision_mysql_db_user'@'localhost';"
    mysql -u root -p"$settings_provision_mysql_root_pw" -e "FLUSH PRIVILEGES;"
  else
    echo '|>| SKIPPING: mysql.install is set to false'
    echo ''
  fi

  echo '--'
  service mysql status
  echo '--'
}

# Install PHP and any php-related packages
php_go() {
  echo '===================================='
  echo 'Provision PHP'
  echo '===================================='

  if [ "$settings_provision_php_install" = "true" ]
  then
    # bring in another repo
    apt-get -y install python-software-properties
    add-apt-repository -y ppa:ondrej/php
    apt-get update

    # install multiple php versions for dev
    for i in ${settings_provision_php_versions_to_install}
    do
      echo '-----'
      echo "Install php version $i"
      apt-get -y install php$i
      apt-get -y install php$i-curl php$i-dev php$i-gd php$i-mbstring php$i-zip php$i-mysql php$i-xml php$i-json
    done

    php -v
    update-alternatives --list php
    update-alternatives --set php /usr/bin/php$settings_provision_php_default_version

    #ln -s /vagrant/conf/php/php.ini /etc/php/$settings_provision_php_default_version/apache2/conf.d/php.ini
    service apache2 restart

  else
    echo "|>| SKIPPING: php.install is set to false"
  fi

  echo '--'
  php -v
  echo '--'
}

# Composer install
composer_go(){
  if [ "$settings_provision_php_install_composer" = "true" ]
  then
    /vagrant/conf/scripts/install_composer.sh
  fi
}

# Drush install
drush_go(){
  if [ "$settings_provision_php_install_drush" = "true" ]
  then
    /vagrant/conf/scripts/install_drush.sh
  fi
}

# print results of provision
complete_go() {
  echo ""
  echo "========================================="
  echo "STACK OVERVIEW"
  echo "========================================="
  echo "OS:"
  cat /etc/*release | grep VERSION=
  echo ''
  echo "-----------------------------------------"
  echo "Web Server:"
  service apache2 status | grep 'Active:'
  apache2 -v | grep "Server version"
  echo ''
  echo "-----------------------------------------"
  echo "Database:"
  service mysql status | grep 'Active:'
  mysql --version
  echo ''
  echo "-----------------------------------------"
  echo "PHP:"
  php -v | grep PHP | awk '{ print $1 $2 }' | head -1
  echo 'Available versions:'
  update-alternatives --list php
  echo ''
  echo "-----------------------------------------"
  echo "Composer:"
  composer --version
  echo ''
  echo "-----------------------------------------"
  echo "Drush:"
  drush --version
  echo ''
  echo "-----------------------------------------"
  echo "Provisioning complete. Please visit"
  echo "http://localhost:[port]/ or access"
  echo "the VM with vagrant ssh"
  echo '+++++++++++++++++++++++++++++++++++++++++'
  echo ''

}

main

exit 0