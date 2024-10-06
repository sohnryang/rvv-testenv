FROM ubuntu:24.04 AS base
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  autoconf \
  automake \
  autotools-dev \
  curl \
  python3 \
  python3-pip \
  libmpc-dev \
  libmpfr-dev \
  libgmp-dev \
  gawk \
  build-essential \
  bison \
  flex \
  texinfo \
  gperf \
  libtool \
  patchutils \
  bc \
  zlib1g-dev \
  libexpat-dev \
  libglib2.0-dev \
  libslirp-dev \
  ca-certificates \
  build-essential \
  git \
  device-tree-compiler \
  libboost-regex-dev \
  libboost-system-dev \
  cmake \
  ninja-build \
  lld \
  wget && \
  rm -rf /var/lib/apt/lists/*

FROM base AS build

WORKDIR /tools
RUN git clone https://github.com/riscv-software-src/riscv-isa-sim
WORKDIR ./riscv-isa-sim/build
RUN ../configure --prefix=/opt/riscv
RUN make -j `nproc` && make install && make clean

WORKDIR /tools
RUN wget https://ftp.kaist.ac.kr/gnu/glibc/glibc-2.40.tar.bz2
RUN tar xf glibc-2.40.tar.bz2
RUN wget https://ftp.kaist.ac.kr/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz
RUN tar xf gcc-14.2.0.tar.xz
RUN wget https://ftp.kaist.ac.kr/gnu/binutils/binutils-2.43.tar.xz
RUN tar xf binutils-2.43.tar.xz
RUN git clone https://github.com/riscv-collab/riscv-gnu-toolchain
WORKDIR ./riscv-gnu-toolchain
RUN ./configure --prefix=/opt/riscv --disable-gdb --with-glibc-src=/tools/glibc-2.40 --with-gcc-src=/tools/gcc-14.2.0 --with-binutils-src=/tools/binutils-2.43 --with-arch=rv64gcv
RUN make -j `nproc` linux && make -j `nproc` build-sim && make install && make clean

WORKDIR /tools
RUN git clone https://github.com/llvm/llvm-project
WORKDIR ./llvm-project
RUN git checkout llvmorg-19.1.1
RUN cmake -S llvm -B build -G Ninja -DCMAKE_BUILD_TYPE=MinSizeRel -DLLVM_USE_LINKER=lld -DLLVM_ENABLE_PROJECTS=clang -DLLVM_TARGETS_TO_BUILD=RISCV -DCMAKE_INSTALL_PREFIX=/opt/riscv -DLLVM_DEFAULT_TARGET_TRIPLE=riscv64-unknown-linux-gnu
WORKDIR ./build
RUN ninja && ninja install && ninja clean

FROM base
COPY --from=build /opt/riscv /opt/riscv
