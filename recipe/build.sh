#!/bin/bash
set -ex

# necessary for cross-compilation to point to the right env
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

# HACK: extend $CONDA_PREFIX/meson_cross_file that's created in
# https://github.com/conda-forge/ctng-compiler-activation-feedstock/blob/main/recipe/activate-gcc.sh
# https://github.com/conda-forge/clang-compiler-activation-feedstock/blob/main/recipe/activate-clang.sh
# to use host python; requires that [binaries] section is last in meson_cross_file
echo "python = '${PREFIX}/bin/python'" >> ${CONDA_PREFIX}/meson_cross_file.txt

# conda-forge itself prepropulates MESON_ARGS for cross-compilation with meson:
# https://conda-forge.org/docs/maintainer/knowledge_base/#how-to-enable-cross-compilation
# meson-python already sets up a -Dbuildtype=release argument to meson, so
# we need to strip --buildtype out of MESON_ARGS or fail due to redundancy
MESON_ARGS_REDUCED="$(echo $MESON_ARGS | sed 's/--buildtype release //g')"

mkdir builddir
# -wnx flags mean: --wheel --no-isolation --skip-dependency-check
# Forward MESON_ARGS_REDUCED to our Python build tool by prepending -Csetup-args=
# in front of every arguments in MESON_ARGS_REDUCED.
$PYTHON -m build -w -n -x \
        -Cbuilddir=builddir \
        -Csetup-args=${MESON_ARGS_REDUCED// / -Csetup-args=} \
        || (cat builddir/meson-logs/meson-log.txt && exit 1)
$PYTHON -m pip install dist/scikit_learn*.whl
