# Use latest debian as base image
FROM debian:latest

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl libc6 net-tools ssh

# Download the n2n package
WORKDIR /opt
RUN curl -L https://github.com/AlmirKadric/n2n-fpm-packager/releases/download/v2.8.0/n2n_2.8.0-0_amd64.deb -o n2n_2.8.0-0_amd64.deb

# Install n2n package and dependencies
RUN apt-get update && \
    apt-get install -y ./n2n_2.8.0-0_amd64.deb

ENV SUPERNODE "0.0.0.0"
ENV N2N_COMMUNITY "n2n-community"
ENV N2N_KEY "123456789"
ENV ADDRESS "0.0.0.0:1200"
ENV N2N_IFACE "edge0"

CMD tunctl -t "${N2N_IFACE}" && \
    /sbin/edge -f -r -E \
        -l "${SUPERNODE}" \
        -c "${N2N_COMMUNITY}" \
        -k "${N2N_KEY}" \
        -a "${ADDRESS}" \
        -d "${N2N_IFACE}"