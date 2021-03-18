#!/bin/bash
#
# Usage: curl https://gerfficient.com/setup/macOS | bash
#
#
index_main() {
    set -e
    curl -s -S -L https://raw.githubusercontent.com/Muxelmann/system-setup/main/macOS/install.sh | bash
}

index_main