#!/bin/bash

MY_PAUSE=3
MY_PORT=8180
MY_STORE=galaxy-store-vol

docker ps -a

docker inspect ${MY_STORE} 1> /dev/null || {

  ### Create storage volume ${MY_STORE}
  docker volume create ${MY_STORE}

  ### Initialize data volume /export with database from Galaxy 19.09
  export IMAGE_GALAXY_STABLE=bgruening/galaxy-stable:19.09
  echo press control-C when web server starts
  docker run --rm -d -p ${MY_PORT}:80 --mount source=${MY_STORE},target=/export \
    --name galaxy_bootstrap ${IMAGE_GALAXY_STABLE}

  test -t 1 && echo "Waiting for web server to start for ${IMAGE_GALAXY_STABLE}"
  test -t 1 && echo "Watching /export populate with 'du -sh /export'"
  until curl localhost:${MY_PORT} >/dev/null 2>&1
  do
      sleep ${MY_PAUSE}
      test -t 1 && echo ---
      test -t 1 && docker exec -i galaxy_bootstrap bash -c "du -sh /export/*"
      test -t 1 && echo ...
  done
  test -t 1 && echo "Web server started for ${IMAGE_GALAXY_STABLE}; shutting down container."
  docker exec -i galaxy_bootstrap bash -c "supervisorctl stop all"
  docker kill galaxy_bootstrap

  while (docker ps -a | grep galaxy_bootstrap >/dev/null 2>&1)
  do
    test -t 1 && echo waiting for removal of galaxy_bootstrap ...
    sleep ${MY_PAUSE}
  done
  test -t 1 && echo galaxy_bootstrap is gone now

  # ### Rerun with Galaxy release 20.09 and upgrade the database
  export IMAGE_GALAXY_STABLE=bgruening/galaxy-stable:20.09
  docker run -d --rm -p ${MY_PORT}:80 --mount source=${MY_STORE},target=/export \
     --name galaxy_bootstrap ${IMAGE_GALAXY_STABLE}
  test -t 1 && echo "Waiting for web server to start for ${IMAGE_GALAXY_STABLE}"
  test -t 1 && echo "Watching /export populate with 'du -sh /export'"
  until curl localhost:${MY_PORT} >/dev/null 2>&1
  do
      sleep ${MY_PAUSE}
      test -t 1 && docker exec -i galaxy_bootstrap bash -c "du -sh /export"
  done
  test -t 1 && echo "Web server started for ${IMAGE_GALAXY_STABLE}."
  docker exec -i galaxy_bootstrap bash -c "sh manage_db.sh upgrade; supervisorctl stop all"
  docker kill galaxy_bootstrap

  while (docker ps -a | grep galaxy_bootstrap >/dev/null 2>&1)
  do
    test -t 1 && echo waiting for removal of galaxy_bootstrap ...
    sleep ${MY_PAUSE}
  done
  test -t 1 && echo galaxy_bootstrap is gone now
}

export IMAGE_GALAXY_STABLE=bgruening/galaxy-stable:20.09
docker run --rm -ti -p ${MY_PORT}:80 --mount source=${MY_STORE},target=/export \
   --name galaxy_bootstrap ${IMAGE_GALAXY_STABLE}
