#!/usr/bin/env bash
git reset --hard HEAD
git clean -fd
git pull
swift build --configuration release
