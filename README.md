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
> If you want a completely self-contained image so you never have to
  re-install bc, create a simple Dockerfile alongside your script:
-----------------------------------------------------------------------
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y bc coreutils procps util-linux

WORKDIR /app
COPY server-stats.sh .

RUN chmod +x server-stats.sh

ENTRYPOINT ["./server-stats.sh"]
CMD ["-m", "/"]
-----------------------------------------------------------------------

> Build on your host
docker build -t server-stats .

> Now execute it while still in the host
docker run --rm server-stats -m /home

> Too see all top 5 processes:

You’ll need to run the script on a host or in a container with a richer PID namespace (for example, with Docker’s --pid=host) so that system daemons, background services, and any other containers’ processes show up in your ps output.

docker run --rm -it \
  --pid=host \
  -v "$PWD":/workdir \
  -w /workdir \
  ubuntu:24.04 bash

> Inside the container now:
apt-get update && apt-get install -y procps bc coreutils util-linux
./server-stats.sh -m /home
