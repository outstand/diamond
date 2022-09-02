#!/bin/bash

set -euo pipefail

su-exec ${FIXUID:?Missing FIXUID var}:${FIXGID:?Missing FIXGID var} fixuid

"${WORKSPACE_DIR}/docker/chown-dirs.sh"

if [ -n "$(ls -A /usr/local/share/ca-certificates)" ]; then
  echo "Updating ca-certificates"
  update-ca-certificates
fi

set -- su-exec deploy "$@"
exec "$@"
