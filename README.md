`server-stats.sh` reports:
- Total CPU usage
- Total memory usage (free vs used, %)
- Total disk usage for a given mount (free vs used, %)
- Top 5 processes by CPU and by memory
- OS & kernel version
- Uptime, load average, and logged-in users

## Usage

```bash
-- One-off manual testing in Docker --
docker run --rm -it \
 -v "$PWD":/workdir \
 -w /workdir \
 ubuntu:24.04 \
 bash

apt-get update
apt-get install -y bc

chmod +x server-stats.sh          
./server-stats.sh -m /home 

-- Baking it into a Docker image --
> Create a Dcokerfile alongside your script

FROM ubuntu:24.04

RUN apt-get update && apt-get install -y bc coreutils procps util-linux

WORKDIR /app
COPY server-stats.sh .

RUN chmod +x server-stats.sh

ENTRYPOINT ["./server-stats.sh"]
CMD ["-m", "/"]

- Then build and run

docker build -t server-stats .
docker run --rm server-stats -m /home
