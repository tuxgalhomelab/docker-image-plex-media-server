#!/usr/bin/env bash
set -E -e -o pipefail

plex_meta_arch() {
    local platform="$(uname -m)"
    case "${platform:?}" in
        "x86_64")
            echo "x86_64"
            ;;
        "i386"|"i686")
            echo "i386"
            ;;
        "armv7l"|"armhf")
            echo "armv7hf_neon"
            ;;
        "aarch64"|"armv8l")
            echo "aarch64"
            ;;
        *)
            echo "Unsupported platform \"${platform:?}\""
            exit 1
    esac

}

plex_deb_arch() {
    dpkg --print-architecture
}

install_plex() {
    local ver="${1:?}"
    local download_dir="$(mktemp -d)"
    mkdir -p ${download_dir:?}

    # It is possible to use the following metadata URL to download the manifest
    # and then automatically download the latest version. However, we do not
    # use this approach since we want the docker image to be pinned to a
    # specific plex media server version.
    # # 16 is the Public channel.
    # local channel=16
    # local distro="debian"
    # local build="linux-$(plex_arch)"
    # local download_meta_url="https://plex.tv/downloads/details/5?build=${build:?}&channel=${channel:?}&distro=${distro:?}"
    # local deb_url=$(curl --silent --location "${download_meta_url:?}" | tr '\n' ' ' | sed -E 's#.* url="(https://.+)".*#\1#')

    local deb_url="https://downloads.plex.tv/plex-media-server-new/${ver:?}/debian/plexmediaserver_${ver:?}_$(plex_deb_arch).deb"

    curl --silent --location --remote-name --output-dir "${download_dir:?}" "${deb_url:?}"

    dpkg -i ${download_dir:?}/$(basename ${deb_url:?})

    rm -rf ${download_dir:?}
}

install_plex ${@}
