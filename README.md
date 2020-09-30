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

Packaging
---------
Debian Package
```
docker build -t n2n-fpm-packager -f Dockerfile.build-deb .
docker run --rm -v $PWD/package:/opt/mount n2n-fpm-packager bash -c 'cp package/n2n* /opt/mount'
```

Docker Image
```
docker build -t almirkadric/n2n-2.8.0 .
```

TODO
----
 * 

License
-------
MIT