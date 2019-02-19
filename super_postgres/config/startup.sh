#!/bin/bash

# patch authorization file to permit connections to database as user galaxy from another container
grep galaxy /export/postgresql/9.3/main/pg_hba.conf || {
  su -l postgres -c 'patch --force --backup /export/postgresql/9.3/main/pg_hba.conf /etc/supervisor/config/pg_hba.conf.patch'
}

# convert this processs to supervisor, specifying configuration explicitly
exec supervisord --nodaemon --configuration=/etc/supervisor/supervisord.conf
