let
  pkgs = (import <nixpkgs> {
    overlays = [
      (import ./overlay.nix)
    ];
  });
in pkgs.mkShell {
  packages = [
    pkgs.strata-rocm-gfx1201
    pkgs.python3
  ];

  env = {
    # DB_HOST = "localhost";
  };

  # Скрипт, выполняемый при запуске оболочки
  shellHook = ''
    python3 --version
  '';
}

