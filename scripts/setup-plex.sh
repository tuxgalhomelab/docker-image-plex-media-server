#!/usr/bin/env bash
set -e -o pipefail

setup_plex() {
    local plex_pref="${HOME:?}/Library/Application Support/Plex Media Server/Preferences.xml"
    mkdir -p "$(dirname "${plex_pref:?}")"

    local serial="$(uuidgen)"
    local client_id="$(echo -n "${serial:?}- Plex Media Server" | sha1sum | cut -b 1-40)"

    cat << EOF > "${plex_pref:?}"
<?xml version="1.0" encoding="utf-8"?>
<Preferences MachineIdentifier="${serial:?}" ProcessedMachineIdentifier="${client_id:?}" MetricsEpoch="1" AcceptedEULA="1" PublishServerOnPlexOnlineKey="0" collectUsageData="0" logDebug="0" sendCrashReports="0" ApertureSharingEnabled="0" iPhotoSharingEnabled="0" iTunesSharingEnabled="0" GdmEnabled="0" DlnaEnabled="0" CinemaTrailersFromLibrary="0" LanguageInCloud="1" OldestPreviousVersion="legacy" EnableIPv6="0" allowedNetworks="172.17.0.0/16"/>
EOF
}

setup_plex
