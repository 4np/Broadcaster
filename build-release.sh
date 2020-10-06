#!/usr/bin/env bash
git reset --hard origin/vapor4-rewrite
git clean -fd
git pull
swift build --configuration release
