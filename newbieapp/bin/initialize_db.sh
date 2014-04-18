#!/bin/sh

mysql -u root -e 'drop database newbie'
mysql -u root -e 'drop database newbie_echo'

mysql -u root -e 'create database newbie'
mysql -u root -e 'create database newbie_echo'

mysql -u root newbie < /var/lib/newbie/db/newbie_db_schema.sql
mysql -u root newbie_echo < /var/lib/newbie/db/newbie_echo_db_schema.sql

mysql -u root newbie < /var/lib/newbie/db/users_data.sql
mysql -u root newbie < /var/lib/newbie/db/user_logins_data.sql
mysql -u root newbie < /var/lib/newbie/db/friends_data.sql
mysql -u root newbie_echo < /var/lib/newbie/db/echos_data.sql
