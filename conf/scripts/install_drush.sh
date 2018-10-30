#!/bin/bash

# Install drush 8 gloabbly
if [ ! -f "/usr/local/bin/drush" ]; then
  cd /tmp
  wget -q https://github.com/drush-ops/drush/releases/download/8.1.17/drush.phar
  php drush.phar core-status
  chmod +x drush.phar
  sudo mv drush.phar /usr/local/bin/drush
else
  echo "Warning: Drush is already installed at /usr/local/sbin/drush. Skipping..."
fi
