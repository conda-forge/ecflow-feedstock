#!/usr/bin/env bash

set -e # Abort on error.

# find the boost libs/includes we need
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

if [[ $(uname) == Darwin ]]; then
    export CXXFLAGS="-DBOOST_ASIO_DISABLE_STD_ALIGNED_ALLOC=1"
fi

export UNDEF_LOOKUP=0
if [[ $(uname) == Darwin ]]; then
    export UNDEF_LOOKUP=1
fi

mkdir build && cd build

echo "which python"
which python
echo "python version"
python --version

cmake ${CMAKE_ARGS} -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D ENABLE_PYTHON=1 \
      -D ENABLE_SSL=1 \
      -D BOOST_ROOT=$PREFIX \
      -D ECBUILD_LOG_LEVEL=DEBUG \
      -D ENABLE_STATIC_BOOST_LIBS=OFF \
      -D Python3_FIND_STRATEGY=LOCATION \
      -D Python3_EXECUTABLE=$PYTHON \
      -D ENABLE_PYTHON_UNDEF_LOOKUP=$UNDEF_LOOKUP \
      ..

make -j $CPU_COUNT VERBOSE=1


# only run certain tests
if [[ $(uname) == Linux ]]; then
    echo "1,2,3,4,5,6,7,8" > ./test_list.txt
elif [[ $(uname) == Darwin ]]; then
    echo "1,2,3,4,5,6,8" > ./test_list.txt
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
ctest -VV -I ./test_list.txt
fi

make install
