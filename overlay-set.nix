{lib, ...}:
let
  # Unstable nixpkgs: the ROCm stack (rocmPackages) is newer and more complete there.
  pkgs = import (import ./nixpkgs-unstable.nix) {};

  # One derivation per supported AMD architecture; the user picks the one matching their card.
  #   gfx1100  RX 7900 XT / XTX (RDNA3)
  #   gfx1101  RX 7800 XT / 7700 XT (RDNA3)
  #   gfx1200  RX 9060 XT (RDNA4)
  #   gfx1201  RX 9070 / 9070 XT, Radeon AI PRO R9700 (RDNA4)
  archs = [ "gfx1100" "gfx1101" "gfx1200" "gfx1201" ];

  strataFor = arch: pkgs.callPackage ./derivation-rocm.nix { inherit arch; };
in
lib.listToAttrs (map (a: {
  name = "strata-rocm-${a}";
  value = strataFor a;
}) archs)
