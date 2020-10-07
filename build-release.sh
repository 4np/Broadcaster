#!/usr/bin/env bash
git reset --hard origin/vapor4-rewrite
git clean -fd
git pull

if [[ $(uname -s) == "Linux" && $(free -t|grep "^Swap"|awk '{print $2}') -eq 0 ]]; then
        echo "You have no available swap space. To prevent swift getting killed by Linux's OOM killer"
        echo "(see syslog / dmesg), make sure to enable swap space. Follow the steps as described in:"
        echo "https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-16-04"
        echo ""
        exit 1
fi

swift build --configuration release
