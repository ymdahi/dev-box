#!/bin/bash

##############################################################
#
# file: importdb.sh
# This script will import .sql files from the specified path.
#
# The script expects one argument when being called, this is
# the import_path. 
#
# Example: /vagrant/conf/scripts/importdb.sh /vagrant/conf/mysql
#
##############################################################

# make sure exactly 1 argument is provided
if (( $# != 1 ))
then
  echo "ERROR: Need to supply 1 argument, the path to the folder where the .sql files are:"
  echo "Usage: /vagrant/conf/scripts/importdb.sh /path/to/folder/withsqlfiles"
  exit 1
fi

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

# let the first argument be the path we import .sql files from.
import_path=$1

# if the import path actually exists, continue
if [ -d "$import_path" ]
then

  # move into the import path and count the number of .sql files avilable.
  cd $import_path
  count_sql_files="$(ls -1q *.sql | wc -l)"

  echo ""
  echo "Found $count_sql_files .sql files in $import_path"
  echo ""

  # if found 1 or more .sql files in import path, continue
  if [ $count_sql_files -gt 0 ]; then
    echo "Importing ${count_sql_files} sql files from $import_path."
    echo "This might take a minute..."
    echo ""
    # loop through each .sql file and create a database then import the data.
    for sql_file in *.sql
    do
      echo "Creating database: ${sql_file%%.*}"
      echo "CREATE DATABASE ${sql_file%%.*}" | mysql -u root --password=$settings_provision_mysql_root_pw
      echo "Importing $sql_file into database ${sql_file%%.*}"
      time mysql -u root --password=$settings_provision_mysql_root_pw ${sql_file%%.*} < $sql_file
      echo "FINISHED importing $sql_file"
      echo ""
    done

  # no .sql files in import path  
  else
     echo "NOTICE: Could not find any .sql files in $import_path. No databases were created/imported."
  fi
# could not find import path
else
  "WARNING: could not find the folder $import_path. No DBs were imported."
fi
