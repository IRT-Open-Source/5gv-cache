| [![5G-VICTORI logo](doc/images/5g-victori-logo.png)](https://www.5g-victori-project.eu/) | This project has received funding from the European Union’s Horizon 2020 research and innovation programme under grant agreement No 857201. The European Commission assumes no responsibility for any content of this repository. | [![Acknowledgement: This project has received funding from the European Union’s Horizon 2020 research and innovation programme under grant agreement No 857201.](doc/images/eu-flag.jpg)](https://ec.europa.eu/programmes/horizon2020/en) |
| ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |


# Cache

Reverse proxy cache for video streams.

## What is this?

The Cache is part of the [platform](https://gitlab.irt.de/5g-victori/platform) for media caching on trains. As Online Cache it is used as a buffer between a VoD service's CDN and the cache one the train. As Offline Cache on trains it is used to serve media streams to client applications on the train even if the train is has no connection to the Intenet and thus ensure service availability and continuity.

## How does it work?

Der Cache kann Inhalte verschiedener Upstream-Hostnamen cachen. Dafür erwartet er, dass der Hostname der Upstream-Location vor den Hostnamen des Caches gesetzt wird. Der Pfad zur Resource wird als Pfad an die Cache-Anfrage-URL gehängt.

**Example:**
Assume your cache is running on `localhost` and you like to cache the document located at `https://www.irt.de/home/index.html`. Use the following URL to cache the respective document:

```
http://www.irt.de.cache.cache:8080/home/index.html
```

Future requests to the same URL will be served from the cache.

### Adaptations for ARD-Mediathek

HLS manifests of the ARD-Mediathek only list absolute URLs (or protocol-relative URLs). Since the media streams of ARD-Mediathek are obtained via a large number of domains, a complex configuration of the local DNS on the train would be necessary, if they were to automatically point to the Offline Cache. Therefore, the cache is configured to forward requests to manifest files of HLS streams that are not contained in the cache to the Manifest Transformer. The [Manifest Transformer](https://gitlab.irt.de/5g-victori/manifest-transformer) exchanges all hostnames n the manifests with the hostname of the offline cache. The Manifest Transformer and the corresponding cache configuration can also be used in the same way for other VoD services, where this type of transformation of the stream manifests has advantages.

## Install, build, run

**Note:** _Typically you would use the `up.sh` script from the [Platform](https://gitlab.irt.de/5g-victori/platform) project to install, build and run this service as part of a composite of docker services. Read on if you intend to run the service directly on your host system._

The Cache is based on NGINX. You can install NGINX directly on your host system as shown in the [NGINX docs](https://www.nginx.com/resources/wiki/start/topics/tutorials/install/).

Also, you can run NGINX in a docker container.

**Prerequisits**:

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

Build docker image and run container via `docker-compose`:

```bash
$ docker-compose up
```

Append CLI option `-d` if you want to run the container in background.

## Technologie used

- [NGINX](https://www.nginx.com/)

## Limitations and TODOs

### Security

_See TODO comments in [nginx.conf](conf/nginx.conf)_

- No SSL support
- Uses Google DNS (`8.8.8.8`) to resolve host names of proxied services. This makes the service vulnarible to DNS spoofing attacks.

### Network throughput

The [Prefetcher](https://gitlab.irt.de/5g-victori/prefetcher) sends a large number of requests to the cache in a short time, whcih can rapidly block the network interface. There are different parameters on different service levels which can optimise the throughput.

- Configuration of the host sytsem, see for example [link](https://stackoverflow.com/questions/2332741/what-is-the-theoretical-maximum-number-of-open-tcp-connections-that-a-modern-lin)
- Configuration of the docker environment, see for example [link](https://www.linkedin.com/pulse/ec2-tuning-1m-tcp-connections-using-linux-stephen-blum)
- Configuration of NGINX, see for example [link](https://www.nginx.com/blog/tuning-nginx/)
- Configuration of the [Prefetcher](https://gitlab.irt.de/5g-victori/prefetcher) (number of concurrent request sent to the cache)

### Adaptive Bitrate Streaming

At the moment stream segments of all quality levels are cached. If cached in this manner, the memory requirements of a 90-minute feature film can quickly exceed 10 GB. One approach to reduce memory requirements could be to cache the highest quality of the progressive download representation of and have the segmentation for adaptive bitrate streaming done by the cache. A candidate for the corresponding implementation is the [Kaltura Plugin](https://github.com/kaltura/nginx-vod-module) for NGINX.
