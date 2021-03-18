#!/bin/bash
#
# Usage: curl https://gerfficient.com/setup/test | bash
#
#
index_main() {
    set -e
    curl -s -S -L https://raw.githubusercontent.com/Muxelmann/system-setup/main/test/install.sh | bash
}

index_main