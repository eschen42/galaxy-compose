# Compose Galaxy using `bgruening/galaxy-stable`

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

