#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/user/depot_tools:/home/user/depot_tools

cd src
git checkout tags/57.0.2925.0
git checkout -b v/57.0.2925.0

sudo ./build/install-build-deps.sh --no-prompt
cd ..
gclient sync --with_branch_heads --with_tags -Rv --disable-syntax-validation


