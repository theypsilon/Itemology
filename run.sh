#/usr/bin/env bash

set -euo pipefail

echo ''
echo '## STARTING ITEMOLOGY ##'
echo ''

rm log/systems/*.log 2>/dev/null || true

echo "$@" > arguments

./moai src/Bootstrap.lua
