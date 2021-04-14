#!/bin/bash
#
# Usage: curl https://gerfficient.com/setup/RPi | bash
#
#
index_main() {
    set -e
    curl -s -S -L https://raw.githubusercontent.com/Muxelmann/system-setup/main/RPi/install.sh | bash
}

index_main