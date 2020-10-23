n2n-fpm-packager
================
N2N P2P VPN binary compiling and packaging logic using the FPM packaging tool


Installing
----------
Debain
```
DEB_TMP="$(mktemp).deb"
curl -L https://github.com/AlmirKadric/n2n-fpm-packager/releases/download/v2.8.0/n2n_2.8.0-0_amd64.deb -o "${DEB_TMP}"
sudo apt install "${DEB_TMP}"
```

CentOS
```
sudo yum install -y https://github.com/AlmirKadric/n2n-fpm-packager/releases/download/v2.8.0/n2n-2.8.0-0.x86_64.rpm
```

Raspberry Pi
```
DEB_TMP="$(mktemp).deb"
curl -L https://github.com/AlmirKadric/n2n-fpm-packager/releases/download/v2.8.0/n2n_2.8.0-0_armhf.deb -o "${DEB_TMP}"
sudo apt install "${DEB_TMP}"
```


Super Node
----------
Starting the service
```
sudo systemctl enable n2n-supernode.service
sudo systemctl start n2n-supernode.service
```

This will start listening on the UDP port `1200` by default. To change this,
modify the supernode config file `/etc/n2n/supernode.conf`


Edge Node
---------
Update your configuration
`/etc/n2n/edge.conf`
```
# N2N Edge Configuration

# Supernode server address and port.
SUPERNODE="<SUPERNODE IP>:1200"

# Community name
N2N_COMMUNITY="<COMMUNITY NAME>"
# Community key
N2N_KEY="<COMMUNITY KEY>"

# Address to assign to this edge node
ADDRESS="<UNIQUE IP WITHIN COMMUNITY>"
```

Starting the service
```
sudo systemctl enable n2n-edge.service
sudo systemctl start n2n-dege.service
```


Docker
------
You can also start an edge node from within docker
```
docker run -d --privileged --name n2n-bridge -e SUPERNODE="<Super Node IP>:1200" -e N2N_COMMUNITY="<Community Name>" -e N2N_KEY="<Community Key>" -e ADDRESS="<Unique IP In Community>" almirkadric/n2n-2.8.0
docker exec -it n2n-bridge bash
```

You can also use the n2n-bridge container to provide other containers access to
the VPN. This can be done by specifying the `--net` argument or `network_mode`
property:
```
docker run -d --net container:n2n-bridge grafana/grafana
```

```
version: '3.1'

services:
  n2n-bridge:
    image: almirkadric/n2n-2.8.0:latest

    environment:
      - SUPERNODE=<Super Node IP>:1200
      - N2N_COMMUNITY=<Community Name>
      - N2N_KEY=<Community Key>
      - ADDRESS=<Unique IP In Community>

    restart: always

    privileged: true

    # All services will use the n2n service network for access to the VPN
    # Therefore we need to expose all ports for all services here
    ports:
      - 3000:3000

  grafana:
    image: grafana/grafana:7.2.0

    restart: always

    network_mode: service:n2n-bridge
```

Packaging
---------
Debian Package
```
docker build --rm -t n2n-fpm-packager:deb -f Dockerfile.build-deb .
docker run --rm -v $PWD/package:/opt/mount n2n-fpm-packager:deb bash -c 'cp package/n2n* /opt/mount'
```

Amazon Package
```
docker build --rm -t n2n-fpm-packager:amzn1 -f Dockerfile.build-amzn1 .
docker run --rm -v $PWD/package:/opt/mount n2n-fpm-packager:amzn1 bash -c 'cp package/n2n* /opt/mount'
```

Docker Image
```
docker build --rm --no-cache -t almirkadric/n2n-2.8.0 .
docker push almirkadric/n2n-2.8.0
```

TODO
----
 * wrap /sbin/edge in additional script which can inject options which have been
   set in config allowing for more complex configuration
 * once above is done, add all other options to config file, e.g. netmask

License
-------
MIT