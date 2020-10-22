#!/bin/bash

set -o nounset
set -o errexit


SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

BUILD_VERSION="2.8"
PACKAGE_VERSION="${BUILD_VERSION}.0"
PACKAGE_ITERATION="0"


# Get N2N sources
sudo apt-get install -y git
if ! [ -e "${SCRIPT_PATH}/deps/n2n" ]; then
    mkdir -p "${SCRIPT_PATH}/deps"
    git clone https://github.com/ntop/n2n.git "${SCRIPT_PATH}/deps/n2n"
fi

# Checkout version to build
cd "${SCRIPT_PATH}/deps/n2n"
git checkout "${BUILD_VERSION}"


# Install build dependencies
sudo apt-get install -y make autoconf automake pkg-config gcc g++

# Compile the dependency sources
pushd "${SCRIPT_PATH}/deps/n2n"
./autogen.sh
./configure
make -j10
popd


# Install binaries into src folder
mkdir -p "${SCRIPT_PATH}/src"
pushd "${SCRIPT_PATH}/deps/n2n"
make PREFIX="${SCRIPT_PATH}/src" install
popd


# Install packaging dependencies
sudo apt-get install -y ruby ruby-dev libffi6 libffi-dev
sudo gem install fpm

# Create Debian package
mkdir -p "${SCRIPT_PATH}/package"
fpm -s dir -t deb \
    --name "n2n" \
    --description "Peer-to-Peer VPN network" \
    --category "net" \
    --url "https://github.com/AlmirKadric/n2n-fpm-packager" \
\
    --maintainer "Almir Kadric <github@almirkadric.com>" \
    --license "GPL" \
\
    --version "${PACKAGE_VERSION}" \
    --iteration "${PACKAGE_ITERATION}" \
\
    --depends "libc6" \
    --depends "net-tools" \
    --depends "uml-utilities" \
\
    --force \
    --package "${SCRIPT_PATH}/package" \
    -C "${SCRIPT_PATH}/src" .