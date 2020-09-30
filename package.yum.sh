#!/bin/bash

set -o nounset
set -o errexit


SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

BUILD_VERSION="2.8"
PACKAGE_VERSION="${BUILD_VERSION}.0"
PACKAGE_ITERATION="0"


# Get N2N sources
sudo yum install -y git
if ! [ -e "${SCRIPT_PATH}/deps/n2n" ]; then
    mkdir -p "${SCRIPT_PATH}/deps"
    git clone https://github.com/ntop/n2n.git "${SCRIPT_PATH}/deps/n2n"
fi

# Checkout version to build
cd "${SCRIPT_PATH}/deps/n2n"
git checkout "${BUILD_VERSION}"


# Install build dependencies
sudo yum install -y autoconf automake gcc g++

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
sudo yum install -y libffi libffi-devel rpm-build
# Install Ruby 2.5 using RVM
set +o nounset
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://get.rvm.io | bash -s stable
source /home/ec2-user/.rvm/scripts/rvm
rvm install 2.5
rvm use 2.5
set -o nounset
# Install FPM ruby gem
gem install fpm

# Create Debian package
mkdir -p "${SCRIPT_PATH}/package"
fpm -s dir -t rpm \
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
    --depends "glibc-devel" \
    --depends "net-tools" \
\
    --force \
    --package "${SCRIPT_PATH}/package" \
    -C "${SCRIPT_PATH}/src" .