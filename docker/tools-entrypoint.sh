#!/bin/bash

set -euo pipefail

su-exec ${FIXUID:?Missing FIXUID var}:${FIXGID:?Missing FIXGID var} fixuid >/dev/null 2>&1

"${WORKSPACE_DIR}/docker/chown-dirs.sh" >/dev/null

if [ "${1:-}" = "bash" ]; then
  exec "$@"
elif [ "${1:-}" = "exit" ]; then
  exit 0
fi

set -- su-exec deploy "$@"
exec "$@"
