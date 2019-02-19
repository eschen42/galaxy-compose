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

# execute from the directory containing this script
pushd $DIR

# shutdown postgresql gracefully
docker-compose exec galaxy-postgres supervisorctl stop postgresql
# shutdown the supervisor and remaining processes gracefully
docker-compose exec galaxy-postgres supervisorctl shutdown
docker-compose exec galaxy-stable   supervisorctl shutdown
# shut down all services in the composition
docker-compose -f docker-compose.yml down --volumes

popd
