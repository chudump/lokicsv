FROM docker.io/debian

WORKDIR /telegraf

RUN apt update && apt install -y curl wget jq golang

RUN wget https://dl.influxdata.com/telegraf/releases/telegraf-1.31.0_linux_amd64.tar.gz && tar xf telegraf-1.31.0_linux_amd64.tar.gz -C /

RUN cp -r ./telegraf-1.31.0/* /

COPY ./exec /usr/bin

CMD [ "bash","-c","sleep infinity" ]
