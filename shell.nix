let
  pkgs = (import <nixpkgs> {
    overlays = [
      (import ./overlay.nix)
    ];
  });
in pkgs.mkShell {
  packages = [
    pkgs.python3
    pkgs.python313Packages.jinja2
    pkgs.python313Packages.pip

    pkgs.python313Packages.numpy
    pkgs.python313Packages.jinja2
    pkgs.python313Packages.regex
    pkgs.python313Packages.pyyaml
    pkgs.python313Packages.tqdm
    pkgs.python313Packages.requests
    pkgs.python313Packages.cmake
    pkgs.python313Packages.ninja
    pkgs.python313Packages.pillow
    pkgs.python313Packages.psutil
  ];

  env = {
    # DB_HOST = "localhost";
  };

  # Скрипт, выполняемый при запуске оболочки
  shellHook = ''
    python3 --version
  '';
}

