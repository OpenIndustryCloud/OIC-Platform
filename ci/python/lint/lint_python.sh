#!/bin/bash

set -eux

# Load Configuration
MYNAME="$(readlink -f "$0")"
MYDIR="$(dirname "${MYNAME}")"


flake8 "${MYDIR}/../"

