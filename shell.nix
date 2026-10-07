let
  pkgs = (import <nixpkgs> {
    overlays = [
      (import ./overlay.nix)
    ];
  });
in pkgs.mkShell {
  packages = [
    pkgs.python3
    pkgs.python314Packages.jinja2
  ];

  env = {
    # DB_HOST = "localhost";
  };

  # Скрипт, выполняемый при запуске оболочки
  shellHook = ''
    python3 --version
  '';
}

