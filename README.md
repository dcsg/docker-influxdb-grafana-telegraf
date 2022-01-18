# Docker Image with InfluxDB, Telegraf and Grafana

The purpose of this docker image is to provide an image for arm32v7 (Raspberry Pi).

| Description  | Value             |
|--------------|-------------------|
| OS           | arm32v7           |
| InfluxDB     | 1.6.4             |
| Telegraf     | 1.8.2             |
| Grafana      | 5.4.3             |

## Note

This is a fork of the repository created by Daniel Gomez. As the last image was over 3 years old and uses 'ancient' versions of Grafana, InfluxDB and Telegraf I decided to take a shot and see if I could get this to a higher level.
As to keep it working I might do this in small steps.
As I have only a Raspberry Pi I can only test the image on arm32v7.

## Quick Start

#### Raspberry Pi (arm32v7)

Start the container by running the following command:

```sh
docker run -d \
  --name influxdb-grafana \
  --restart unless-stopped \
  -p 3003:3003 \
  -p 8086:8086 \
  -v /path/for/influxdb:/var/lib/influxdb \
  -v /path/for/grafana:/var/lib/grafana \
  -e "GF_SECURITY_ADMIN_USER=<YOU_USERNAME_HERE>" \
  -e "GF_SECURITY_ADMIN_PASSWORD=<YOU_PASSWORD_HERE>" \
  pluim003/influxdb-grafana-telegraf:latest
```

To stop the container launch:

```sh
docker stop influxdb-grafana
```

To start the container again launch:

```sh
docker start influxdb-grafana
```

## Mapped Ports

| Host  | Container | Service  |
|-------|-----------|----------|
| 3003  | 3003      | grafana  |
| 8086  | 8086      | influxdb |

## SSH

```sh
docker exec -it influxdb-grafana bash
```

## Grafana

Open <http://localhost:3003>

```
Username: <User defined in Environment Variable>
Password: <Password defined in Environment Variable>
```

### Add data source on Grafana

1. Using the wizard click on `Add data source`
2. Choose a `name` for the source and flag it as `Default`
3. Choose `InfluxDB` as `type`
4. Fill `URL` with `http://localhost:8086`
5. Choose `Server (Default)` as `access`
6. Fill the database and the remaining fields and click `Save & Test`.

Basic auth and credentials must be left unflagged. Proxy is not required.

Now you are ready to add your first dashboard and launch some queries on a database.

### InfluxDB Shell (CLI)

```sh
docker exec -it influxdb-grafana influx
```
