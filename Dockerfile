FROM ubuntu:24.04

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  ca-certificates \
  build-essential \
  git \
  device-tree-compiler \
  libboost-regex-dev \
  libboost-system-dev \
  cmake \
  python-is-python3 \
  ninja-build \
  lld \
  wget && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /tools
RUN git clone https://github.com/riscv-software-src/riscv-isa-sim
WORKDIR ./riscv-isa-sim/build
RUN ../configure
RUN make -j `nproc` && make install && make clean

WORKDIR /tools
RUN wget https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.0/llvm-project-19.1.0.src.tar.xz
RUN tar xvf llvm-project-19.1.0.src.tar.xz
WORKDIR ./llvm-project-19.1.0.src
RUN cmake -S llvm -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DLLVM_USE_LINKER=lld -DLLVM_ENABLE_PROJECTS=clang -DLLVM_TARGETS_TO_BUILD=RISCV -DCMAKE_INSTALL_PREFIX=/llvm
WORKDIR ./build
RUN ninja && ninja install && ninja clean
WORKDIR /
