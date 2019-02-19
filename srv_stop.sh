#!/bin/bash

# shutdown postgresql gracefully
docker-compose exec galaxy-postgres supervisorctl stop postgresql
# shutdown the supervisor and remaining processes gracefully
docker-compose exec galaxy-postgres supervisorctl shutdown
docker-compose exec galaxy-stable   supervisorctl shutdown
