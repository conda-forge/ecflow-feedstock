#!/usr/bin/env bash

set -e # Abort on error.

# find the boost libs/includes we need
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

mkdir build && cd build

echo "which python"
which python
echo "python version"
python --version

cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D ENABLE_PYTHON=1 \
      -D ENABLE_SSL=0 \
      -D BOOST_ROOT=$PREFIX \
      -D Boost_DEBUG=ON \
      -D ECBUILD_LOG_LEVEL=DEBUG \
      -D Python3_FIND_STRATEGY=LOCATION \
      -D Python3_EXECUTABLE=$PYTHON \
      ..

make -j $CPU_COUNT


# only run certain tests
if [[ $(uname) == Linux ]]; then
    echo "1,2,3,4,5,6,7,8" > ./test_list.txt
elif [[ $(uname) == Darwin ]]; then
    echo "1,2,3,4,5,6,8" > ./test_list.txt
fi

ctest -VV -I ./test_list.txt

make install
