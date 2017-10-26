#!/bin/bash

set -e -u -x

# Load Configuration
MYNAME="$(readlink -f "$0")"
MYDIR="$(dirname "${MYNAME}")"


flake8 "${MYDIR}/../"

