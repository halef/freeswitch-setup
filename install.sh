#!/usr/bin/env bash
set -e # Abort on error

# Locate this script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set paramaters
# TODO(langep): Make parameters configurable
download_location=~/src
install_location=/opt/freeswitch
version=1.6.20

# Compute useful variables
src=http://files.freeswitch.org/releases/freeswitch/freeswitch-${version}.tar.gz
archive_name=freeswitch-${version}.tar.gz
unpacked_dir_name=freeswitch-${version}

# Cleanup trap in case of error
cleanup() {
    if [ $? -ne 0 ]; then
        # TODO(langep): Conditional cleanup based on where error happend
        rm -rf "$install_location"
        rm -rf "$download_location"/"$unpacked_dir_name"
        rm /etc/init.d/freeswitch
    fi
}

trap cleanup EXIT

# Load heler.sh functions
source ${SCRIPT_DIR}/helper.sh

# Update packages and install dependencies
apt-get update
apt-get install -y --no-install-recommends \
    wget whois build-essential git pkg-config uuid-dev zlib1g-dev libjpeg-dev \
    libsqlite3-dev libcurl4-openssl-dev libpcre3-dev libspeexdsp-dev \
    libssl-dev libedit-dev yasm liblua5.2-dev libopus-dev libsndfile-dev \
    libavformat-dev libavresample-dev libswscale-dev libldns-dev libpng-dev

# Install certbot
apt-get install -y software-properties-common
add-apt-repository -y ppa:certbot/certbot
apt-get update
apt-get install -y python-certbot-apache 

# Make download and install directories
mkdir -p "$download_location" "$install_location"

# Download and unpack the source archive
pushd "$download_location"
if [ ! -f "$archive_name" ]; then # Download if not exists
    wget -O "$archive_name" "$src"
fi
tar -xvf "$archive_name"

pushd "$unpacked_dir_name"

# Enable non-default modules
sed -i -e "s,#applications/mod_av,applications/mod_av," modules.conf

# Compile and install
CFLAGS=-Wno-unused CXXFLGAS=-Wno-unused ./configure --prefix=${install_location}
make -j 4
make install

# Create group and user for freeswitch if they don't exist
if ! check_group freeswitch; then
    groupadd freeswitch
fi

if ! check_user freeswitch; then
    useradd -r -s /bin/false -d ${install_location} -g freeswitch freeswitch
fi

# Setup service
cp ${SCRIPT_DIR}/init.d/freeswitch.init-debian /etc/init.d/freeswitch
chmod +x /etc/init.d/freeswitch
sed -i -e "s|%%FREESWITCH_HOME%%|${install_location}|g" /etc/init.d/freeswitch
update-rc.d freeswitch defaults

# Replace configuration
rm -rf ${install_location}/etc/freeswitch/*
cp -r ${SCRIPT_DIR}/config/* ${install_location}/etc/freeswitch/.

chown -R freeswitch ${install_location}

# Echo success message
info "Installation complete."
info "Run 'sudo service freeswitch start' to start freeswitch."
info "Then run 'bash ${SCRIPT_DIR}/update-conf.sh [--aws]' next."
