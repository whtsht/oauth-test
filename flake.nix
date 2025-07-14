{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      supportSystems = [

        "aarch64-darwin" # 64-bit ARM macOS
        "aarch64-linux"  # 64-bit ARM Linux
        "x86_64-darwin"  # 64-bit x86 macOS
        "x86_64-linux"   # 64-bit x86 Linux
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportSystems;
    in
    {

      devShells = forAllSystems (

        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              libffi.dev
              openssl.dev
              libyaml.dev
              zlib.dev
              ruby
              pkg-config
              libpq
              ruby_3_4
              gcc
              gcc.cc.lib
              gnumake
              bundler
              gmp.dev
              readline.dev
              ncurses.dev
              sqlite.dev
            ];
            shellHook = ''
              export PATH="$PWD/vendor/bin:$PATH"
              export LD_LIBRARY_PATH="${pkgs.gcc.cc.lib}/lib:$LD_LIBRARY_PATH"
              export LD_LIBRARY_PATH="/usr/local/lib"
            '';
          };
        }
      );
    };
}
