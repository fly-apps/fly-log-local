FROM golang:1.17 as builder

USER root

RUN apt-get update -y \
    && apt-get install build-essential curl git -y

WORKDIR /go
RUN git clone https://github.com/grafana/loki.git \
    && cd loki \
    && make loki logcli

WORKDIR /tmp
RUN curl -O -L 'https://packages.timber.io/vector/nightly/latest/vector-nightly-x86_64-unknown-linux-gnu.tar.gz'
RUN tar -xzvf vector-nightly-x86_64-unknown-linux-gnu.tar.gz

FROM ubuntu:22.04

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install supervisor -y \
    && apt-get clean cache \
    && rm -rf /var/lib/apt

COPY --from=builder /tmp/vector-x86_64-unknown-linux-gnu/bin/vector /usr/bin/vector
COPY --from=builder /go/loki/cmd/loki/loki /usr/bin/loki
COPY --from=builder /go/loki/cmd/logcli/logcli /usr/bin/logcli

COPY loki.conf /etc/supervisor/conf.d/loki.conf
COPY vector.conf /etc/supervisor/conf.d/vector.conf
COPY supervisor.conf /etc/supervisor/supervisor.conf

COPY vector.toml /etc/vector/vector.toml
RUN mkdir /etc/loki
COPY loki.yaml /etc/loki/loki.yaml

USER root
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisor.conf"]
