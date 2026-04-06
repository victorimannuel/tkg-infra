#!/usr/bin/env bash
set -euo pipefail

# Local port can be overridden: LOCAL_PORT=25432 ./open_db_tunnel.sh
LOCAL_PORT="${LOCAL_PORT:-15432}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/general/id_ed25519_general}"
SSH_USER="${SSH_USER:-victor}"
SSH_HOST="${SSH_HOST:-103.150.93.39}"
REMOTE_DB_HOST="${REMOTE_DB_HOST:-127.0.0.1}"
REMOTE_DB_PORT="${REMOTE_DB_PORT:-5432}"

echo "Opening tunnel: 127.0.0.1:${LOCAL_PORT} -> ${REMOTE_DB_HOST}:${REMOTE_DB_PORT} via ${SSH_USER}@${SSH_HOST}"
exec ssh -i "${SSH_KEY}" -N \
  -L "${LOCAL_PORT}:${REMOTE_DB_HOST}:${REMOTE_DB_PORT}" \
  "${SSH_USER}@${SSH_HOST}"
