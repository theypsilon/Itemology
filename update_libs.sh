#!/bin/sh

set -e

readonly LIB_FOLDER="src/lib/"

cd "$(dirname $0)"

mkdir -p $LIB_FOLDER

cd "$LIB_FOLDER"

install() {
    local repo=$1
    local dir=$2
    if [ -z "$dir" ]; then
        git clone $repo || true
    else
        git clone $repo $dir || true
    fi
}

install https://github.com/theypsilon/lua-dump.git Dump
install https://github.com/theypsilon/lua-class.git Class
install https://github.com/theypsilon/lua-arg-file.git ArgFile
install https://github.com/theypsilon/lua-import.git Import
install https://github.com/theypsilon/lua-strict.git Strict
install https://github.com/theypsilon/lua-type.git Type
install https://github.com/theypsilon/lua-table.git Table
install https://github.com/theypsilon/lua-lazy.git Lazy
install https://github.com/theypsilon/luafun.git Fun
install https://github.com/Kadoba/Advanced-Tiled-Loader.git ATL