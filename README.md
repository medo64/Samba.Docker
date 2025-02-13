# Samba Docker

Docker container for Samba service.


## Environment Variables

The following environment variables can further configure the system:

|                     |                                                                |
|---------------------|----------------------------------------------------------------|
| `USERS`             | Space-separated list of users; either by name or by `uid:name` |

The following environment variables are for troubleshooting purposes and
usually require no configuration:

|                     |                                                 |
|---------------------|-------------------------------------------------|
| `DEBUG_LEVEL`       | Value from `0` to `10`; if not set, `0` is used |


## Network Settings

If you don't want to run container with `--network=host`, please make sure that
your `smb.conf` doesn't contain the following settings:
* `interfaces`
* `bind interfaces only`
* `hosts allow`
* `hosts deny`

If some of these are set, you will run into communication problems (due to
docker IPs potentially being out of allowed range) or you will have issues
starting container unless `--network=host` is set.


## Run Docker Image

To run the docker image, you can use the following command (change values in
brackets):
~~~bash
docker run --init \
    -v $PWD/test/smb.conf:/etc/samba/smb.conf \
    -v /tmp:/share/test \
    -e USERS="1000:test1;test2"
    --network=host \
    -p 445:445 \
    medo64/samba:latest
~~~


## Build Docker Image

If you want to build docker image for yourself, instead using one available on
[DockerHub](https://hub.docker.com/repository/docker/medo64/samba/general), you
can do so using `make`:
~~~bash
make all
~~~
