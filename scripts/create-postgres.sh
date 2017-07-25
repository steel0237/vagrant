#!/usr/bin/env bash

DB=$1;
# su postgres -c "dropdb $DB --if-exists"

echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/postgresql.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get install postgresql-9.6 -y

if ! su postgres -c "psql $DB -c '\q' 2>/dev/null"; then
    su postgres -c "createdb '$DB'"
fi
