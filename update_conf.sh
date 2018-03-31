#!/usr/bin/env bash
set -e # Abort on error

# Locate this script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set paramaters
# TODO(langep): Make parameters configurable or read from environment
FS_HOME=/opt/freeswitch

# Function to get AWS external IP
get_aws_external_ip() {
    local ip=$(curl --connect-timeout 5 http://169.254.169.254/latest/meta-data/public-ipv4 2> /dev/null)
    if [[ "$?" -ne 0 ]]; then
        echo "It appears you are not running on AWS but 'get_aws_internal_ip' only works on AWS."
        return 1
    fi
    echo ${ip}
}

if [ "$1" == "--aws" ]; then
    external_ip=$(get_aws_external_ip)
else
    external_ip=$1
fi



# Replace configuration
rm -rf ${FS_HOME}/etc/freeswitch/*
cp -r ${SCRIPT_DIR}/config/* ${FS_HOME}/etc/freeswitch/.

sed -i -e "s|%%EXTERNAL_IP%%|${external_ip}|g" ${FS_HOME}/etc/freeswitch/vars.xml

chown -R freeswitch ${FS_HOME}