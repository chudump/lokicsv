FROM docker.io/debian

ARG LOKI_HOST
ARG LOKI_PORT
ARG LOKI_QUERY
ARG LOKI_LIMIT

ENV LOKI_HOST=${LOKI_HOST}
ENV LOKI_PORT=${LOKI_PORT}
ENV LOKI_QUERY=${LOKI_QUERY}
ENV LOKI_LIMIT=${LOKI_LIMIT}

WORKDIR /telegraf

RUN apt update && apt install -y curl wget jq golang git

# install telegraf
RUN wget https://dl.influxdata.com/telegraf/releases/telegraf-1.31.0_linux_amd64.tar.gz && tar xf telegraf-1.31.0_linux_amd64.tar.gz -C /
RUN cp -r /telegraf-1.31.0/* /

# install lokicsv
RUN wget https://github.com/chudump/lokicsv/releases/download/v1/lokicsv
RUN cp -r lokicsv /usr/bin/lokicsv

CMD [ "bash","-c","sleep infinity" ]
