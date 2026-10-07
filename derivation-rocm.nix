{ pkgs, arch ? "gfx1100" }:

let
  rocm = pkgs.rocmPackages;

  # llama.cpp pinned by Strata (setup.py's LLAMA_CPP_COMMIT, third_party/ggml/VERSION.txt).
  # CMake would otherwise FetchContent it from the network; STRATA_GGML_DIR points at this checkout.
  llamaCpp = pkgs.fetchzip {
    url = "https://github.com/ggml-org/llama.cpp/archive/3cf03257f219afbe7334045ff7c6a06ac68c627d.zip";
    sha256 = "SRGoXa+4ACBCB3eaG9XFYhMN1i0FyPEy9Rrer+dFGYI=";
  };
in
pkgs.stdenv.mkDerivation rec {
  pname = "strata-rocm-${arch}";
  version = "0.1.40";   # project(strata VERSION ...) in CMakeLists.txt

  src = ./.;

  # Build tools: CMake drives the build, ROCm's clang compiles the HIP (.cu) sources.
  nativeBuildInputs = [
    pkgs.cmake
    pkgs.ninja
    pkgs.pkg-config
    rocm.clang
  ];

  # ROCm runtime + BLAS libraries: needed at build time (headers, CMake config packages)
  # and propagated to the output so the engine finds them at run time.
  buildInputs = [
    rocm.hipcc
    rocm.clr
    rocm.hipblas
    rocm.rocblas
    rocm.hipblaslt
  ];

  cmakeFlags = [
    "-G Ninja"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DSTRATA_ENABLE_HIP=ON"
    "-DSTRATA_ENABLE_CUDA=OFF"
    "-DSTRATA_BUILD_TESTS=OFF"
    "-DSTRATA_PREFILL_MMQ=ON"
    "-DCMAKE_HIP_ARCHITECTURES=${arch}"
    "-DCMAKE_HIP_COMPILER=${rocm.clang}/bin/clang++"
    # --rocm-path points the HIP compiler at the ROCm toolchain; it derives the
    # amdgcn device-lib path ($ROCM_PATH/lib/llvm/amdgcn/bitcode) from it.
    # Kept as a single space-free value: cmakeFlags entries are word-split by the shell.
    "-DCMAKE_HIP_FLAGS=--rocm-path=${rocm.clang}"
    "-DCMAKE_PREFIX_PATH=${rocm.hipcc}:${rocm.hipblas}:${rocm.rocblas}:${rocm.hipblaslt}:${rocm.clang}"
    "-DSTRATA_GGML_DIR=${llamaCpp}"
  ];

  preConfigure = ''
    export HIP_PLATFORM=amd
  '';

  doCheck = false;   # the test suite needs a real AMD GPU

  installPhase = ''
    mkdir -p $out
    cmake --install ./ --prefix $out
    cp -r * $out
    # install -m755 build-hip/strata $out/bin/strata
    # strata-device: --list-devices / --selftest, used to check the card before serving
    if [ -x build-hip/strata-device ]; then
      install -m755 build-hip/strata-device $out/bin/strata-device
    fi
  '';

  meta = with pkgs.lib; {
    description = "Strata inference engine (Qwen3.8-Flash-Next) with the AMD HIP backend, built for ${arch}";
    homepage = "https://github.com/Niko1221/Strata";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "strata";
  };
}
