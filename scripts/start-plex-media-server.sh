#!/usr/bin/env bash
set -E -e -o pipefail

set_umask() {
    # Configure umask to allow write permissions for the group by default
    # in addition to the owner.
    umask 0002
}

start_plex_media_server() {
    echo "Starting Plex Media Server ..."
    echo

    rm -f "/home/plex/Library/Application Support/Plex Media Server/plexmediaserver.pid"

    exec "/usr/lib/plexmediaserver/Plex Media Server"
}

set_umask
start_plex_media_server
