#!/bin/sh

set -e
set -a

OS_PLACEMENT_DATABASE__CONNECTION=null
OS_PLACEMENT_DATABASE__SYNC_ON_STARTUP=${OS_PLACEMENT_DATABASE__SYNC_ON_STARTUP:-False}
OS_API__AUTH_STRATEGY=${OS_API__AUTH_STRATEGY:?OS_API__AUTH_STRATEGY required}

# Wait for the database to be ready
./wait_for_db.sh

echo "starting the webserver............................................"
# run the web server
/app/bin/uwsgi --ini /placement-uwsgi.ini
