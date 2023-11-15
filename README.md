# 🧉 Calamoni

_Scale-to-0 optimized tModLoader deployment with [fly.io](http://fly.io)_

All credits (and rights) go to [JACOBSMILE](https://github.com/JACOBSMILE) for creating the underlying docker image. Please see the [original readme](https://github.com/JACOBSMILE/tmodloader1.4/blob/master/README.md) for configuration options.

Outside of said configuration, a `fly.toml` configuration has been added. Running it with `fly deploy` launches a _machine_ on fly which can scale-to-0, meaning it starts with network traffic and shuts down given its absence.

Since Terraria does not do retries on server connection and since cold boot times are 30-60sec, one needs to connect once (which will fail) and then connect again after the instance has booted. Alternatively, any kind of tcp traffic on the correct port will wake it up as well, i.e., `curl`.

It is recommended to use at least the 2GB ram configuration for this setup. A medium map with <5 players uses about 1-1.5GB. A single shared vCPU, on the other hand, seems to be enough for low player counts.

Since fly.io only supports HTTP/HTTPS connections on shared IPv4 addresses, you'll need to [allocate a non-shared IPv4 address to the application](https://fly.io/docs/flyctl/ips-allocate-v4/) or use IPv6 exclusively (which need to be [allocated](https://fly.io/docs/flyctl/ips-allocate-v6/) as well but is, in contrast to IPv4, free). Terraria does not support IPv6 hostname resolution, so when choosing the latter, connections can only be established with the IP address. [But support should be landing soon, apparently.](https://forums.terraria.org/index.php?threads/ipv6-support.104448/post-2805121)

## Backup (Todo)
Volumes (Fly's native storage method) are not very persistent and non-redundant. While snapshots are automatically taken, this should not be the only method perserving maps. Since the approach of scaling-to-0 is all about not waisting resources, having 2 volumes running (which have a minimum size of 1GB) seems unelegant. Uploading maps to object storage is the obvious approach, which can easily be integrated into `autosave.sh`. This will be done soon™.