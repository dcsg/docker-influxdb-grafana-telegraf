FROM arm32v7/debian:stretch-slim
LABEL maintainer="Dick Pluim <dockerhub@dickpluim.com>"

# Default versions
ENV INFLUXDB_VERSION=1.8.10
ENV TELEGRAF_VERSION=1.21.2
ENV GRAFANA_VERSION=8.3.4

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
        dialog \
        git \
        htop \
        libfontconfig \
        lsof \
        nano \
        procps \
        vim \
        net-tools \
        wget \
        gnupg \
        supervisor 
    
# Install InfluxDB
RUN wget https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_armhf.deb \
    && dpkg -i influxdb_${INFLUXDB_VERSION}_armhf.deb && rm influxdb_${INFLUXDB_VERSION}_armhf.deb 

# Install Telegraf
RUN wget  https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}_linux_armhf.tar.gz \
     && tar -xf telegraf-${TELEGRAF_VERSION}_linux_armhf.tar.gz -C / && rm telegraf-${TELEGRAF_VERSION}_linux_armhf.tar.gz \
     && cd /telegraf-${TELEGRAF_VERSION} && cp -R * / && cd / && rm -rf telegraf-${TELEGRAF_VERSION} \
     && groupadd -g 998 telegraf && useradd -ms /bin/bash -u 998 -g 998 telegraf 
# Install Grafana
RUN apt-get install -y adduser libfontconfig1 \
     && wget https://dl.grafana.com/oss/release/grafana-rpi_${GRAFANA_VERSION}_armhf.deb \
     && dpkg -i grafana-rpi_${GRAFANA_VERSION}_armhf.deb && rm grafana-rpi_${GRAFANA_VERSION}_armhf.deb \
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
