#!/bin/bash

VANDAAG=$(date +"%Y%m%d")
docker buildx build --build-arg DOCKER_INFLUX_TELEGRAF_GRAFANA=$VANDAAG --platform linux/arm64/v8,linux/arm/v7  -f Dockerfile -t pluim003/influxdb-grafana-telegraf:${VANDAAG} --push .

docker buildx build --build-arg DOCKER_INFLUX_TELEGRAF_GRAFANA=$VANDAAG --platform linux/arm64/v8,linux/arm/v7  -f Dockerfile -t pluim003/influxdb-grafana-telegraf:dev --push .

docker buildx build --build-arg DOCKER_INFLUX_TELEGRAF_GRAFANA=$VANDAAG --platform linux/arm64/v8,linux/arm/v7  -f Dockerfile -t pluim003/influxdb-grafana-telegraf:latest --push .


