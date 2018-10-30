#!/bin/bash

# Drupal 7 install script that will download the latest version of drupal,
# create a database, use drush to install drupal into the database, install
# a few drupal modules, and disable a few core modules
#
# To execute, run /vagrant/conf/scripts/install_drupal.sh
#

echo "************************"
echo "Drupal install script"
echo "************************"

# # Defaults
PROJECTNAME="drupaldev"
DRUPALVERSION="7"
CREATEDATABASE="y"
DBROOT="root"
DBROOTPW="root"
SITEADMIN="admin"
SITEADMINPASS="pass"


echo ''
echo 'Project name? Default = drupaldev'
echo ''
read PROJECTNAME
if [ -z "$PROJECTNAME" ]; then
  PROJECTNAME="drupaldev"
fi

echo ''
echo 'Going to do the following:'
echo ''
echo '1. Create new database:' $PROJECTNAME
echo '2. Download Drupal' $DRUPALVERSION 'into /var/www/html/'$PROJECTNAME
echo '3. Configure Drupal with admin user: u: admin, e: admin@server.com, p: pass'
echo ''
read -p "Proceed (y/n)? " answer
case ${answer:0:1} in
  y|Y )
    echo "yes"
  ;;
  * )
    echo "no, exiting."
    exit
  ;;
esac

# # Create the database for drupal.
mysql -u$DBROOT -p$DBROOTPW -e "create database $PROJECTNAME;"
echo ".....database created"
echo ''

# # Download drupal into correct directory and provide select options when downloading.
drush dl drupal-$DRUPALVERSION --select --destination="/var/www/html" --drupal-project-rename="$PROJECTNAME"
echo ".....downloading drupal"
echo ''

# # Install drupal.
cd /var/www/html/$PROJECTNAME
drush site-install standard --account-name=$SITEADMIN --account-pass=$SITEADMINPASS --db-url=mysql://$DBROOT:$DBROOTPW@localhost/$PROJECTNAME -y
echo ".....installing drupal"
echo ''

# # Download extra contrib modules and disable annoying core modules.
drush dl devel, module_filter, ctools, views
drush en devel, module_filter, ctools, views -y
drush dis overlay -y

drush status

echo ""
echo "****************************************************************"
echo "Drupal install script complete"
echo "****************************************************************"
echo "You will most likely need to make some adjustments to apache"
echo "virtual host configurations."
echo "For a Apache Virtual Host Config template:"
echo "https://gitlab.com/snippets/1768581"
echo "--------------------------------"
echo ""