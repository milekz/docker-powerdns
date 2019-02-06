#!/bin/sh
set -e

# --help, --version
[ "$1" = "--help" ] || [ "$1" = "--version" ] && exec pdns_server $1
# treat everything except -- as exec cmd
[ "${1:0:2}" != "--" ] && exec "$@"

if $PGSQL_AUTOCONF ; then
  if [ -z "$PGSQL_PORT" ]; then
      PGSQL_PORT=5432
  fi
  # Set POSTGRESQL Credentials in pdns.conf
  sed -r -i "s/^[# ]*launch=gpgsq.*/launch=gpgsql/g" /etc/pdns/pdns.conf
  sed -r -i "s/^[# ]*gpgsql-host=.*/gpgsql-host=${PGSQL_HOST}/g" /etc/pdns/pdns.conf
  sed -r -i "s/^[# ]*gpgsql-port=.*/gpgsql-port=${PGSQL_PORT}/g" /etc/pdns/pdns.conf
  sed -r -i "s/^[# ]*gpgsql-user=.*/gpgsql-user=${PGSQL_USER}/g" /etc/pdns/pdns.conf
  sed -r -i "s/^[# ]*gpgsql-password=.*/gpgsql-password=${PGSQL_PASS}/g" /etc/pdns/pdns.conf
  sed -r -i "s/^[# ]*gpgsql-dbname=.*/gpgsql-dbname=${PGSQL_DB}/g" /etc/pdns/pdns.conf
  
  #MYSQLCMD="mysql --host=${MYSQL_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASS} --port=${MYSQL_PORT} -r -N"

  # wait for Database come ready
  #isDBup () {
  #  echo "SHOW STATUS" | $MYSQLCMD 1>/dev/null
  #  echo $?
  #}

  #RETRY=10
  #until [ `isDBup` -eq 0 ] || [ $RETRY -le 0 ] ; do
  #  echo "Waiting for database to come up"
  #  sleep 5
  #  RETRY=$(expr $RETRY - 1)
  #done
  #if [ $RETRY -le 0 ]; then
  #  >&2 echo Error: Could not connect to Database on $MYSQL_HOST:$MYSQL_PORT
  #  exit 1
  #fi

  # init database if necessary
  #echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DB;" | $MYSQLCMD
  #MYSQLCMD="$MYSQLCMD $MYSQL_DB"

  #if [ "$(echo "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = \"$MYSQL_DB\";" | $MYSQLCMD)" -le 1 ]; then
  #  echo Initializing Database
  #  cat /etc/pdns/schema.sql | $MYSQLCMD
  #fi

  unset -v PGSQL_PASS
fi

# Run pdns server
trap "pdns_control quit" SIGHUP SIGINT SIGTERM

pdns_server "$@" &

wait
