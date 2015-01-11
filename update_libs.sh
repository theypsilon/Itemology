#!/bin/sh

set -e

readonly LIB_FOLDER="src/lib/"

cd "$(dirname $0)"

mkdir -p $LIB_FOLDER

cd "$LIB_FOLDER"

install() {
    local repo=$1
    git clone $repo || true
}

install https://github.com/theypsilon/lua-dump.git
install https://github.com/theypsilon/lua-class.git
install https://github.com/theypsilon/lua-arg-file.git
install https://github.com/theypsilon/lua-import.git
install https://github.com/theypsilon/lua-strict.git
install https://github.com/theypsilon/lua-type.git
install https://github.com/theypsilon/lua-table.git
install https://github.com/theypsilon/lua-lazy.git
install https://github.com/theypsilon/luafun.git