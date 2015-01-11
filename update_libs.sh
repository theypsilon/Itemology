#!/bin/sh

set -e

readonly LIB_FOLDER="src/lib/"

cd "$(dirname $0)"

mkdir -p $LIB_FOLDER

cd "$LIB_FOLDER"

install() {
    local repo=$1
    git clone $repo
}

install https://github.com/theypsilon/lua-dump.git