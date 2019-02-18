# Compose Docker using `docker-galaxy-stable` image

## Part 1 - creating and initializing a data-storage container
### create storage container named galaxy-store
```bash
docker volume create galaxy-store
docker volume inspect galaxy-store
docker create --mount source=galaxy-store,target=/export --name galaxy-store bgruening/galaxy-stable /bin/true
```
### init "galaxy" using galaxy-store as export (so export files get copied to volume)
```bash
docker run --rm -ti -p 8080:80 --volumes-from galaxy-store --name galaxy_bootstrap bgruening/galaxy-stable
```
Then use ^C to quit after export volume is initialized

## Part 2 - run and enjoy

After making sure that `.env` is up to date ...

```bash
./start.sh
```

