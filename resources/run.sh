#!/bin/sh

set -x

xargs phoronix-test-suite make-download-cache < $PHOROMATIC_HOME/phoromatic_tests.txt |& tee /dev/fd/1

./phoronix-test-suite start-phoromatic-server
