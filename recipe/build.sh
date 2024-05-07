#!/bin/bash
set -ex

# meson-python already sets up a -Dbuildtype=release argument to meson, so
# we need to strip --buildtype out of MESON_ARGS or fail due to redundancy
MESON_ARGS_REDUCED="$(echo $MESON_ARGS | sed 's/--buildtype release //g')"

pip install . -vv --no-build-isolation --config-settings=setup-args=${MESON_ARGS_REDUCED}
