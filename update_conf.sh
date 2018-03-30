#!/usr/bin/env bash
set -e # Abort on error

# Locate this script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set paramaters
# TODO(langep): Make parameters configurable or read from environment
FS_HOME=/opt/freeswitch

external_ip=$1

# Replace configuration
rm -rf ${FS_HOME}/etc/freeswitch/*
cp -r ${SCRIPT_DIR}/config/* ${FS_HOME}/etc/freeswitch/.

sed -i -e "s|%%EXTERNAL_IP%%|${external_ip}|g" ${FS_HOME}/etc/freeswitch/vars.xml

chown -R freeswitch ${FS_HOME}