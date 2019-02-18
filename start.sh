#!/bin/bash

# get directory for script
# ref: https://stackoverflow.com/a/246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
export DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

_term() { 
  echo "Caught signal $1 in $2" 
  cd $DIR
  docker-compose exec galaxy-postgres supervisorctl stop postgresql
  # kill -INT $CHILD 
}

pushd $DIR

trap "{ echo INT  $DIR; _term INT  $DIR; }" INT
trap "{ echo QUIT $DIR; _term QUIT $DIR; }" QUIT
trap "{ echo ABRT $DIR; _term ABRT $DIR; }" ABRT
trap "{ echo TERM $DIR; _term TERM $DIR; }" TERM
trap "{ echo EXIT $DIR; exit 0; }" EXIT

docker-compose -f docker-compose.yml up --remove-orphans &
sleep 5
docker-compose ps

export CHILD=$! 
echo child PID is $CHILD now waiting for same
wait "$CHILD"

echo child is gone
docker-compose -f docker-compose.yml down --volumes
echo farewell

popd
