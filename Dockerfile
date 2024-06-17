ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG} AS builder

COPY scripts/install-plex-media-server.sh /scripts/setup-plex-media-server.sh /scripts/

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

SHELL ["/bin/bash", "-c"]

ARG USER_NAME
ARG GROUP_NAME
ARG USER_ID
ARG GROUP_ID
ARG PLEX_MEDIA_SERVER_VERSION

RUN --mount=type=bind,target=/scripts,from=builder,source=/scripts \
    set -E -e -o pipefail \
    # Install dependencies. \
    && homelab install bsdutils util-linux uuid-runtime \
    # Create the user and the group. \
    && homelab add-user \
        ${USER_NAME:?} \
        ${USER_ID:?} \
        ${GROUP_NAME:?} \
        ${GROUP_ID:?} \
        --create-home-dir \
    # Install plex media server. \
    && /scripts/install-plex-media-server.sh ${PLEX_MEDIA_SERVER_VERSION:?} \
    # Perform initial set up of the config files. \
    && su --login --shell /bin/bash --command "/scripts/setup-plex-media-server.sh" ${USER_NAME:?} \
    # Clean up. \
    && homelab remove bsdutils util-linux uuid-runtime \
    && homelab cleanup

EXPOSE 32400

# STOPSIGNAL SIGQUIT

USER ${USER_NAME}:${GROUP_NAME}
WORKDIR /
CMD ["--picoinit-cmd", "/usr/lib/plexmediaserver/Plex Media Server", "--picoinit-cmd", "tail", "-F", "/home/plex/Library/Logs/Plex Media Server/Plex Media Server.log"]
