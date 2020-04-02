#!/usr/bin/env bash
set -e

export GDK_VERSION=$1
export PYTHON_DESTDIR="${DESTDIR}/${MESON_INSTALL_PREFIX}"

mkdir -p $PYTHON_DESTDIR

VENV_DIR=${MESON_BUILD_ROOT}/venv

source $VENV_DIR/bin/activate

cd $PYTHON_DESTDIR

cp -r ${MESON_BUILD_ROOT}/src/swig_python/greenaddress .

cd ${MESON_SOURCE_ROOT}

pip install wheel

pip wheel --wheel-dir=$PYTHON_DESTDIR .
virtualenv -p python ${MESON_BUILD_ROOT}/smoketestvenv
deactivate

source ${MESON_BUILD_ROOT}/smoketestvenv/bin/activate

pip install --find-links=$PYTHON_DESTDIR greenaddress
python -c "import greenaddress; assert len(greenaddress.get_networks()) > 0"

deactivate

rm -fr ${MESON_BUILD_ROOT}/smoketestvenv
