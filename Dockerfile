FROM docker.io/debian

ARG LOKI_HOST
ARG LOKI_PORT
ARG LOKI_QUERY
ARG LOKI_LIMIT
ARG PROJECT="default"
ARG INFLUX_TOKEN

ENV LOKI_HOST=${LOKI_HOST}
ENV LOKI_PORT=${LOKI_PORT}
ENV LOKI_QUERY=${LOKI_QUERY}
ENV LOKI_LIMIT=${LOKI_LIMIT}
ENV PROJECT=${PROJECT}
ENV INFLUX_TOKEN=${INFLUX_TOKEN}

WORKDIR /telegraf

RUN apt update && apt install -y curl wget jq golang git

# install telegraf
RUN wget https://dl.influxdata.com/telegraf/releases/telegraf-1.31.0_linux_amd64.tar.gz && tar xf telegraf-1.31.0_linux_amd64.tar.gz -C /
RUN cp -r /telegraf-1.31.0/* /

# install lokicsv
RUN wget https://github.com/chudump/lokicsv/releases/download/v1/lokicsv
RUN chmod +x lokicsv
RUN cp -r lokicsv /usr/bin/lokicsv

# telegraf config
COPY ./Telegraf/* .
RUN sed -i "s/REPLACE_THIS/$PROJECT-logs/g; s/INFLUX_TOKEN/$INFLUX_TOKEN/g;" ./telegraf.conf
RUN cp telegraf.conf /etc/telegraf/telegraf.conf

CMD [ "bash","-c","sleep infinity" ]
