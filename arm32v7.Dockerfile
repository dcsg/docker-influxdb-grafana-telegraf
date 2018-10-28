FROM arm32v7/debian:stretch-slim
LABEL maintainer="Daniel Gomes <danielcesargomes@gmail.com>"

# Default versions
ENV INFLUXDB_VERSION 1.6.4
ENV TELEGRAF_VERSION 1.8.2-1
ENV GRAFANA_VERSION 5.3.2

# Database Defaults
ENV INFLUXDB_GRAFANA_DB datasource
ENV INFLUXDB_GRAFANA_USER datasource
ENV INFLUXDB_GRAFANA_PW datasource

ENV GF_DATABASE_TYPE=sqlite3

WORKDIR /root

# Clear previous sources
RUN rm /var/lib/apt/lists/* -vf \
    # Base dependencies
    && apt-get -y update \
    && apt-get -y install \
        apt-utils \
        apt-transport-https \
        ca-certificates \
        curl \
        git \
        htop \
        libfontconfig \
        nano \
        vim \
        net-tools \
        wget \
        gnupg \
        supervisor \
    # Install InfluxDB
    && wget https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_armhf.deb \
    && dpkg -i influxdb_${INFLUXDB_VERSION}_armhf.deb && rm influxdb_${INFLUXDB_VERSION}_armhf.deb \
    # Install Telegraf
     && wget https://dl.influxdata.com/telegraf/releases/telegraf_${TELEGRAF_VERSION}_armhf.deb \
     && dpkg -i telegraf_${TELEGRAF_VERSION}_armhf.deb && rm telegraf_${TELEGRAF_VERSION}_armhf.deb \
    # Install Grafana
     && wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_${GRAFANA_VERSION}_armhf.deb \
     && dpkg -i grafana_${GRAFANA_VERSION}_armhf.deb && rm grafana_${GRAFANA_VERSION}_armhf.deb \
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

CMD [ "/usr/bin/supervisord" ]