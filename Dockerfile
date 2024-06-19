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
RUN mkdir -p /telegraf/lokicsv
RUN git clone https://github.com/chudump/lokicsv /telegraf/lokicsv
RUN cd /telegraf/lokicsv && go build -o loki_to_csv .
RUN mv /telegraf/lokicsv/loki_to_csv /usr/bin/loki_to_csv

CMD [ "bash","-c","sleep infinity" ]
