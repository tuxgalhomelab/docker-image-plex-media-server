#!/usr/bin/env bash
set -E -e -o pipefail

chrony_config="/data/chrony/chrony.conf"

set_umask() {
    # Configure umask to allow write permissions for the group by default
    # in addition to the owner.
    umask 0002
}

start_chrony() {
    echo "Starting Plex Media Server ..."
    echo

    exec "/usr/lib/plexmediaserver/Plex Media Server"
}

set_umask
start_chrony
