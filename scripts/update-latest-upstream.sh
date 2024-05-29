#!/usr/bin/env bash

set -e -o pipefail

script_parent_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
git_repo_dir="$(realpath "${script_parent_dir:?}/..")"

ARGS_FILE="${git_repo_dir:?}/config/ARGS"
PLEX_MEDIA_SERVER_MAINFEST_URL="https://plex.tv/downloads/details/5?build=linux-x86_64&channel=16&distro=debian"

get_latest_plex_media_server_version() {
    image_key_prefix="${1:?}"
    image_name="$(get_config_arg "${image_key_prefix:?}_NAME")"
    image_tag="$(get_config_arg "${image_key_prefix:?}_TAG")"

    docker run --rm \
        "${image_name:?}:${image_tag:?}" \
        sh -c "apt-get -qq update >/dev/null && apt-get -qq -y install libxml2-utils >/dev/null 2>&1 && curl --silent --location '${PLEX_MEDIA_SERVER_MAINFEST_URL:?}' | xmllint --xpath 'string(//MediaContainer/Release/Package/@fileName)' - | sed -E 's#plexmediaserver_([^_]+)_amd64\.deb#\1#g'"
}

get_config_arg() {
    arg="${1:?}"
    sed -n -E "s/^${arg:?}=(.*)\$/\\1/p" ${ARGS_FILE:?}
}

set_config_arg() {
    arg="${1:?}"
    val="${2:?}"
    sed -i -E "s/^${arg:?}=(.*)\$/${arg:?}=${val:?}/" ${ARGS_FILE:?}
}

pkg="Plex Media Server"
config_ver_key="PLEX_MEDIA_SERVER_VERSION"
config_image_key_prefix="BASE_IMAGE"

existing_upstream_ver=$(get_config_arg ${config_ver_key:?})
latest_upstream_ver=$(get_latest_plex_media_server_version ${config_image_key_prefix:?})

if [[ "${existing_upstream_ver:?}" == "${latest_upstream_ver:?}" ]]; then
    echo "Existing config is already up to date and pointing to the latest upstream ${pkg:?} version '${latest_upstream_ver:?}'"
else
    echo "Updating ${pkg:?} ${config_ver_key:?} '${existing_upstream_ver:?}' -> '${latest_upstream_ver:?}'"
    set_config_arg "${config_ver_key:?}" "${latest_upstream_ver:?}"
    git add ${ARGS_FILE:?}
    git commit -m "feat: Bump upstream ${pkg:?} version to ${latest_upstream_ver:?}."
fi
