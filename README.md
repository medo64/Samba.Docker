# Samba Docker

Docker container for Samba service.


## Create Docker Image

To create docker image run make:
~~~bash
make all
~~~


## Environment variables

The following environment variables are for troubleshooting purposes and
usually require no configuration:

|                     |                                                 |
|---------------------|-------------------------------------------------|
| `DEBUGLEVEL`        | Value from `0` to `10`; if not set, `0` is used |


## Run Docker Image

To run the docker image, you can use the following command (change values in
brackets):
~~~bash
docker run --init \
    -v $PWD/test/smb.conf:/etc/samba/smb.conf \
    -v /tmp:/share/test \
    --network=host \
    -p 445:445 \
    medo64/samba:latest
~~~
