#!/bin/sh
set -eu

# A bind-mounted ./data directory may be created as root by Docker Compose.
# Prepare only the paths GEV owns, then drop privileges before starting Node.
mkdir -p /data/cache /data/logs
touch /data/.env
chown node:node /data /data/cache /data/logs /data/.env

exec su-exec node "$@"
