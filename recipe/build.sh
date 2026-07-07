#! /usr/bin/bash
set -e

# Make the examples location-independent by dropping the 'external/' prefix
# so they use the installed headers instead
grep -r -l "external/" examples/ | xargs sed -i 's|external/||g'

# pythia8-config comes from upstream PYTHIA8's own `make install`, which
# hep-forge's pythia-feedstock runs -- TODO: confirm it lands on PATH there
cmake ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DPYTHIA8_DATA=$(pythia8-config --datadir) -S . -B build

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
cmake --build build --parallel="${NPROC}"
cmake --install build
