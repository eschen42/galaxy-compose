#!/bin/bash

# get directory containinng this script
# ref: https://stackoverflow.com/a/246128
SOURCE="${BASH_SOURCE[0]}"
# resolve $SOURCE until the file is no longer a symlink
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve it 
  #    relative to the path where the symlink file was located
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" 
done
export DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
SCRIPT=$(basename ${SOURCE})

# routione report caught signals
_term() { 
  echo "${SCRIPT}: Caught signal $1 in $2" 
  cd $DIR
}

# trap signals to invoke _term when they are raised
#   rather than aborting the whole script.
trap "{ echo ${SCRIPT}: INT  $DIR; _term INT  $DIR; }" INT
trap "{ echo ${SCRIPT}: QUIT $DIR; _term QUIT $DIR; }" QUIT
trap "{ echo ${SCRIPT}: ABRT $DIR; _term ABRT $DIR; }" ABRT
trap "{ echo ${SCRIPT}: TERM $DIR; _term TERM $DIR; }" TERM

# execute from the directory containing this script
pushd $DIR

# compose Galaxy from services defined in the YAML file
docker-compose -f docker-compose.yml up --remove-orphans &
export CHILD=$! 

# wait 5 seconds, then show status of docker-compose containers
sleep 5
echo "${SCRIPT}: Here are the running containers."
docker-compose -f docker-compose.yml ps

# wait for composition to exit or this script to be interrupted
echo "${SCRIPT}: Child PID is $CHILD."
echo "${SCRIPT}: Now waiting for process to exit or this script to be interrupted."
wait "$CHILD"

echo ${SCRIPT}: Child is gone
# shutdown postgresql gracefully
docker-compose exec galaxy-postgres supervisorctl stop postgresql
# shutdown the supervisor and remaining processes gracefully
docker-compose exec galaxy-postgres supervisorctl shutdown
docker-compose exec galaxy-stable   supervisorctl shutdown
# shut down all services in the composition
docker-compose -f docker-compose.yml down --volumes
echo "${SCRIPT}: Here are the running containers."
docker-compose -f docker-compose.yml ps
echo ${SCRIPT}: Farewell

# restore the working directory (only applicable when script is sourced)
popd
