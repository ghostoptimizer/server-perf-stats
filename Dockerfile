FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y bc procps coreutils util-linux && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY server-stats.sh .

RUN chmod +x server-stats.sh

ENTRYPOINT ["./server-stats.sh"]
CMD ["-m", "/"]
