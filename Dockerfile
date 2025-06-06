# syntax=docker/dockerfile:1

ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG} AS builder

COPY \
    scripts/install-plex-media-server.sh \
    scripts/start-plex-media-server.sh \
    /scripts/

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

ARG USER_NAME
ARG GROUP_NAME
ARG USER_ID
ARG GROUP_ID
ARG PLEX_MEDIA_SERVER_VERSION

# hadolint ignore=SC3040
RUN --mount=type=bind,target=/scripts,from=builder,source=/scripts \
    set -E -e -o pipefail \
    && export HOMELAB_VERBOSE=y \
    # Install dependencies. \
    && homelab install bsdutils util-linux \
    # Create the user and the group. \
    && homelab add-user \
        ${USER_NAME:?} \
        ${USER_ID:?} \
        ${GROUP_NAME:?} \
        ${GROUP_ID:?} \
        --create-home-dir \
    # Install plex media server. \
    && /scripts/install-plex-media-server.sh ${PLEX_MEDIA_SERVER_VERSION:?} \
    # Copy the start-plex-media-server.sh script. \
    && mkdir -p /opt/plex-media-server \
    && cp /scripts/start-plex-media-server.sh /opt/plex-media-server/ \
    && ln -sf /opt/plex-media-server/start-plex-media-server.sh /opt/bin/start-plex-media-server \
    && chown -R ${USER_NAME:?}:${GROUP_NAME:?} /opt/plex-media-server /opt/bin/start-plex-media-server \
    # Clean up. \
    && homelab remove bsdutils util-linux \
    && homelab cleanup

EXPOSE 32400

USER ${USER_NAME}:${GROUP_NAME}
WORKDIR /home/${USER_NAME}

CMD ["--picoinit-cmd", "start-plex-media-server", "--picoinit-cmd", "tail", "-F", "/home/plex/Library/Logs/Plex Media Server/Plex Media Server.log"]
STOPSIGNAL SIGTERM
