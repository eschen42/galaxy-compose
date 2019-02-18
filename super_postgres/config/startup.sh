#!/bin/bash

ps ajxf > /etc/supervisor/log.txt

# shutdown postgres process gracefully if container is stopped
# trap "{ echo INT >> /etc/supervisor/log.txt; supervisorctl shutdown; exit 0; }" INT
# trap "{ echo QUIT >> /etc/supervisor/log.txt; supervisorctl shutdown; exit 0; }" QUIT
# trap "{ echo ABRT >> /etc/supervisor/log.txt; supervisorctl shutdown; exit 0; }" ABRT
# trap "{ echo TERM >> /etc/supervisor/log.txt; supervisorctl shutdown; exit 0; }" TERM
# trap "{ echo EXIT >> /etc/supervisor/log.txt; supervisorctl shutdown; exit 0; }" EXIT

# patch authorization file to permit connections to database as user galaxy from another container
grep galaxy /export/postgresql/9.3/main/pg_hba.conf || {
  su -l postgres -c 'patch --force --backup /export/postgresql/9.3/main/pg_hba.conf /etc/supervisor/config/pg_hba.conf.patch'
}

# start supervisor specifying configuration explicitly
supervisord -c /etc/supervisor/supervisord.conf

# wait for supervisor to start
sleep 5

# start postgresql server
supervisorctl start postgresql

# wait for postgresql server to start
sleep 5

# execute dummy action (which logs to docker-compose output) to keep the container running
#   (Otherwise it exits when process 1 exits)
tail -f /var/log/supervisor/postgresql*

supervisorctl shutdown
