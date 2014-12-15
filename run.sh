#/bin/sh

set -e

echo ''
echo '## STARTING ITEMOLOGY ##'
echo ''

cd "$(dirname $0)"

echo "$@" > arguments

cd src

moai Bootstrap.lua