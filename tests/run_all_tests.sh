#!/bin/bash
# 构建并运行全部测试 (模块依赖顺序固定: 常量 -> 潘宁体系 -> 量子电路)
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$DIR")"
FC="${FC:-gfortran}"
FFLAGS="${FFLAGS:--O2 -fPIC}"
cd "$ROOT"
rm -f src/*.mod src/*.o
$FC $FFLAGS -J src -I src -c src/mod_constants.f90 -o src/mod_constants.o
$FC $FFLAGS -J src -I src -c src/mod_penning_associative_ionization.f90 -o src/mod_penning_associative_ionization.o
$FC $FFLAGS -J src -I src -c src/mod_quantum_hardware.f90 -o src/mod_quantum_hardware.o
ar rcs src/libmdqc.a src/*.o
$FC $FFLAGS -I src "$DIR/test_quantum_hardware.f90" src/libmdqc.a -o "$DIR/test_quantum_hardware"
"$DIR/test_quantum_hardware"
