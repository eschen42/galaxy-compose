# Compose Galaxy using `bgruening/galaxy-stable`

## Part 0 - preliminary consideration

If you want to serve Galaxy on a port different from 8080, you will have to make adjustments maually.
This snippet may help you find the files to change:
```bash
find . -path ./.git -prune -o -type f -print | xargs grep 8080
```

As of this writing, the changes needed are:

- The `GALAXY_PORT` variable in the `.env` file (or default.env on Windows);
- `docker run` command in the `prep.sh` file.

## Part 1 - create and initialize a data-storage container

### Create storage volume galaxy-store
```bash
docker volume create galaxy-store
docker volume inspect galaxy-store
```
### Create storage container named galaxy-store
```bash
docker create --mount source=galaxy-store,target=/export --name galaxy-store bgruening/galaxy-stable /bin/true
```
### Initialize the storage volume (so export files get copied to volume)
Run the fullowing till it starts the web server:
```bash
docker run --rm -ti -p 8080:80 --volumes-from galaxy-store --name galaxy_bootstrap bgruening/galaxy-stable
```
then use ^C to quit after export volume is initialized

## Part 2 - Run the composed Galaxy

Copy default.env.example to default.env (or .env on Windows).
Make sure that `.env` is up to date, then run:

```bash
./start.sh
```

This script allows you to use control-C to stop the PostgreSQL database gracefully before shutting down the containers.

If you prefer, you can start the containers in the background by running:

```bash
./srv_start.sh
```

Then, if you want to follow the logs, you can run:

```bash
docker-compose logs -f
```

(Press control-C to stop following the logs.)

To shut down the containers (and shut down PostgreSQL gracefully), 

```bash
./srv_stop.sh
```


