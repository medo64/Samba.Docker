# Samba Docker

Docker container for Samba service.


## Create Docker Image

To create docker image run make:
~~~bash
make all
~~~


## Environment variables

The following environment variables can further configure the system:

|                           |                                                                |
|---------------------------|----------------------------------------------------------------|
| `USERS`                   | Space-separated list of users; either by name or by `uid:name` |
| `EXPLICIT_NETWORK_CONFIG` | If set to `1`, system will allow for more interface control in `smb.conf` but at a cost of having to use `--network=host` |

The following environment variables are for troubleshooting purposes and
usually require no configuration:

|                     |                                                 |
|---------------------|-------------------------------------------------|
| `DEBUG_LEVEL`       | Value from `0` to `10`; if not set, `0` is used |


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
