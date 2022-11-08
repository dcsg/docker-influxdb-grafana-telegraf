ARG TARGETOS
FROM arm64v8/debian:bullseye-slim as debian-arm64
FROM arm32v7/debian:bullseye-slim as debian-arm
LABEL maintainer="Dick Pluim <dockerhub@dickpluim.com>"

FROM debian-${TARGETARCH}

# Default versions
ENV INFLUXDB_VERSION=1.8.10
ENV TELEGRAF_VERSION=1.24.3
ENV GRAFANA_VERSION=9.2.4

ENV GF_DATABASE_TYPE=sqlite3

WORKDIR /root

# Clear previous sources

RUN rm /var/lib/apt/lists/* -vf \
    # Base dependencies
    && apt-get -y update \
    && apt-get -y install \
        apt-transport-https \
        apt-utils \
        ca-certificates \
        curl \
        dialog \
        git \
        htop \
        libfontconfig1 \
        lsof \
        nano \
        procps \
        vim \
        net-tools \
        wget \
        gnupg \
        supervisor 

# Install InfluxDB
ARG TARGETARCH 
ARG ARCH=${TARGETARCH}
RUN if [ "${TARGETARCH}" = "arm" ]; then ARCH="armhf"; fi && \
    if [ "$[TARGETARCH]" = "arm64" ]; then ARCH="arm64"; fi && \
  wget https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_${ARCH}.deb \
    && dpkg -i influxdb_${INFLUXDB_VERSION}_${ARCH}.deb && rm influxdb_${INFLUXDB_VERSION}_${ARCH}.deb \
# Install Telegraf
 && wget  https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}_linux_${ARCH}.tar.gz \
     && tar -xf telegraf-${TELEGRAF_VERSION}_linux_${ARCH}.tar.gz -C / && rm telegraf-${TELEGRAF_VERSION}_linux_${ARCH}.tar.gz \
     && cd /telegraf-${TELEGRAF_VERSION} && cp -R * / && cd / && rm -rf telegraf-${TELEGRAF_VERSION} \
     && groupadd -g 998 telegraf && useradd -ms /bin/bash -u 998 -g 998 telegraf \
# Install Grafana
 && apt-get install -y adduser libfontconfig1 \
     && wget https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_${ARCH}.deb \
     && dpkg -i grafana_${GRAFANA_VERSION}_${ARCH}.deb && rm grafana_${GRAFANA_VERSION}_${ARCH}.deb \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    # Configure Supervisord
    && mkdir -p /var/log/supervisor

COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure InfluxDB
COPY influxdb/influxdb.conf /etc/influxdb/influxdb.conf
COPY influxdb/init.sh /etc/init.d/influxdb
RUN chmod 0755 /etc/init.d/influxdb

# Configure Grafana
COPY grafana/grafana.ini /etc/grafana/grafana.ini

# Configure Telegraf
COPY telegraf/init.sh /etc/init.d/telegraf
RUN chmod 0755 /etc/init.d/telegraf

CMD [ "/usr/bin/supervisord" ]
