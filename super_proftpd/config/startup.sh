#!/bin/bash

# patch authorization file to permit connections to database in galaxy-postgres as user galaxy from another container
sed -i -e 's/\(SQLConnectInfo [ ]*\)galaxy@galaxy galaxy galaxy/\1galaxy@galaxy-postgres galaxy galaxy/' /etc/proftpd/proftpd.conf
grep SQLConnectInfo /etc/proftpd/proftpd.conf
# convert this processs to supervisor, specifying configuration explicitly
exec supervisord --nodaemon --configuration=/etc/supervisor/supervisord.conf
