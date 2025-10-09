#!/bin/sh
set -e

chown -R ${PUID}:${PGID} /usr/app

umask ${UMASK}

exec su-exec "$PUID:$PGID" "$@"