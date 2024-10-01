FROM ubuntu:24.04

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  build-essential \
  git \
  device-tree-compiler \
  libboost-regex-dev \
  libboost-system-dev \
  cmake \
  python-is-python3 \
  ninja-build \
  lld && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /tools
RUN git clone --depth=1 https://github.com/riscv-software-src/riscv-isa-sim
WORKDIR ./riscv-isa-sim/build
RUN git checkout v1.1.0
RUN ../configure
RUN make -j `nproc`
RUN make install

WORKDIR /tools
RUN git clone --depth=1 https://github.com/llvm/llvm-project
RUN git checkout llvmorg-19.1.0
WORKDIR ./llvm-project
RUN cmake -S llvm -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DLLVM_USE_LINKER=lld -DLLVM_ENABLE_PROJECTS=clang -DLLVM_TARGETS_TO_BUILD=RISCV -DCMAKE_INSTALL_PREFIX=/llvm
WORKDIR ./build
RUN ninja
RUN ninja install
