# SEAL Dev Containers

Containerize flutter_seal package, enable testing of Dart + CPP libraries

## Scripts

> install.sh

Install Microsoft SEAL, optionally specify directory to project root

```
Usage: $ install.sh

Usage: $ install.sh /path/to/flutter_seal /path/to/install/SEAL
```

## Limitations

When using dev containers, they can be rebuilt without cache, as a result can exponentially consume storage. This overrides dockers caching system within the `/var/lib` directory, and if not paritioned OUTSIDE of root partition, can have catetrophic consequences.

>If you find yourself running out of space:

Check the size of docker
```bash
$ du -h /var/lib/docker
204K    /var/lib/docker/image/overlay2/layerdb/sha256/59c56aee1fb4dbaeb334aef06088b49902105d1ea0c15a9e5a2a9ce560fa4c5d
12M     /var/lib/docker/image/overlay2/layerdb/sha256
12M     /var/lib/docker/image/overlay2/layerdb
12M     /var/lib/docker/image/overlay2
...
9.5G    /var/lib/docker
```
If it's greater than 10 GB, [prune](https://docs.docker.com/engine/reference/commandline/system_prune/) docker cache:
```bash
docker system prune -af
```