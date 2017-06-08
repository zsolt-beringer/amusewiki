#!/bin/sh

set -e

cd $(dirname $0);
echo "Working in `pwd`";

if [ "x$1" = "x--force" ]; then
    rm -f ../fontspec.json
    rm -rf ../root/static/images/font-preview
fi

if [ ! -f ../fontspec.json ]; then
    muse-create-font-file.pl ../fontspec.json
fi

mkdir -p ../root/static/images/font-preview
./generate.pl ../fontspec.json ../root/static/images/font-preview

