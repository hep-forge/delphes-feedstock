#! /usr/bin/bash
set -e

# Make the examples location-independent by dropping the 'external/' prefix
# so they use the installed headers instead
grep -r -l "external/" examples/ | xargs sed -i 's|external/||g'

# pythia8-config comes from upstream PYTHIA8's own `make install`, which
# hep-forge's pythia-feedstock runs -- TODO: confirm it lands on PATH there
# GCC 13+'s stricter -Wtemplate-body errors on the vendored D0RunIICone
# fastjet plugin (references a template member that's never actually
# instantiated with a type lacking it) -- downgrade to non-fatal rather
# than hand-patch vendored third-party plugin code
export CXXFLAGS="${CXXFLAGS} -Wno-error=template-body"

# upstream 3.5.0 declares cmake_minimum_required < 3.5, which CMake 4 rejects
cmake ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DPYTHIA8_DATA=$(pythia8-config --datadir) -S . -B build

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
cmake --build build --parallel="${NPROC}"
cmake --install build
