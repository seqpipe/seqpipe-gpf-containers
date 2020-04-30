## Prerequisites
### seqpipe-anaconda-base
The `gunicorn` image uses the `seqpipe-anaconda-base` image from [seqpipe-containers](https://github.com/seqpipe/seqpipe-containers)

## Building the containers
### Building gpfjs apache container
```bash
docker build -t gpfjs gpfjs
```
### Building gunicorn container
```bash
docker build -t gunicorn gunicorn
```

## Configuration
### Gunicorn data
The gunicorn container expects a data directory, specified in `docker-compose.yml`
```yaml
  gunicorn:
    build: ./gunicorn
    image: gunicorn
    volumes:
    - ./data-hg19:/code/data-hg19-startup
```
### Adding more environments
Each environment should be built inside the `gpfjs` `Dockerfile` as a separate stage and copied during the `package-build` stage
Every environment needs to be built using the `--deploy-url` and `base-href` flags

### Environment variables
The `.env` file contains all of the environment variables used inside `docker-compose.yml`. The `.env` file is also used to start the `gunicorn` container

## Running the containers
```bash
docker-compose up
```
