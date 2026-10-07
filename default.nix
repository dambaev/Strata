let
  pkgs = (import <nixpkgs> {
    overlays = [
      (import ./overlay.nix)
    ];
  });
in
{
  # AMD HIP backend, one per supported architecture (pick the one matching your card):
  strata-rocm-gfx1100 = pkgs.strata-rocm-gfx1100;   # RX 7900 XT / XTX
  strata-rocm-gfx1101 = pkgs.strata-rocm-gfx1101;   # RX 7800 XT / 7700 XT
  strata-rocm-gfx1200 = pkgs.strata-rocm-gfx1200;   # RX 9060 XT
  strata-rocm-gfx1201 = pkgs.strata-rocm-gfx1201;   # RX 9070 / 9070 XT, R9700
}
