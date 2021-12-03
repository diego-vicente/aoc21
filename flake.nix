{
  description = "Advent of Code 2021 solved in Nim";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
  };

  outputs = { self, nixpkgs }:
    let
      name = "aoc21";
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in {
      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = with pkgs; [ nim nimlsp hyperfine ];
      };

      defaultPackage.x86_64-linux = pkgs.stdenv.mkDerivation {
        inherit name;
        src = self;
        buildInputs = with pkgs; [ nim ];
        buildPhase = ''
          export HOME=$TEMPDIR
          ${pkgs.nim}/bin/nimble build -d:release
        '';
        installPhase = ''
          mkdir -p $out/bin
          mv ${name} $out/bin
        '';
      };
    };
}
