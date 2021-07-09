#!/usr/bin/env bash

# bootstraps the installation of everything

# move to the root folder
cd "$(dirname "$0")/.." || exit

ROOT_PATH=$(pwd -P)

set -e

# shellcheck source=/dev/null
source "./scripts/utils.sh"

