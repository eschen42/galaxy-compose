#!/bin/bash
# Compose Galaxy using `bgruening/galaxy-stable`

## Part 1 - create and initialize a data-storage container

### Create storage volume galaxy-store-vol
docker volume create galaxy-store-vol
### Confirm success (optional)
docker volume inspect galaxy-store-vol

### Create storage container named galaxy-store-data
docker create --mount source=galaxy-store-vol,target=/export --name galaxy-store-data bgruening/galaxy-stable /bin/true

### Initialize the storage volume (so export files get copied to volume)
echo Press control-C once this starts the web server.
docker run --rm -ti -p 8080:80 --volumes-from galaxy-store-data --name galaxy_bootstrap bgruening/galaxy-stable

### Create storage volume pgadmin4-vol
docker volume create pgadmin4-vol

### Create storage volume docker-data-vol
docker volume create docker-data-vol

### Create storage volume docker-docker-vol
docker volume create docker-docker-vol
