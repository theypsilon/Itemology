#/bin/sh

set -e

echo ''
echo '## STARTING ITEMOLOGY ##'
echo ''

cd "$(dirname $0)"

rm log/systems/*.log || true

echo "$@" > arguments

cd src

moai Bootstrap.lua