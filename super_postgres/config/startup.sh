#!/bin/bash

# patch authorization file to permit connections to database as user galaxy from another container
sed -i -e 's/\(host [ ]*all [ ]*\)all\( [ ]*\)127.0.0.1\/32\( [ ]*trust\)/\1galaxy\20.0.0.0\/0\3/' /export/postgresql/9.3/main/pg_hba.conf
sed -i -e 's/\(host [ ]*all [ ]*all [ ]*::1\/128 [ ]*trust\)/#\1/' /export/postgresql/9.3/main/pg_hba.conf

# convert this processs to supervisor, specifying configuration explicitly
exec supervisord --nodaemon --configuration=/etc/supervisor/supervisord.conf
