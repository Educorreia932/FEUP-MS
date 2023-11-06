{
  description = "Python shell flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };



  outputs = { self, nixpkgs, mach-nix, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          venvDir = "./.venv";
          buildInputs = with pkgs; with python3Packages; [
            python
            venvShellHook
          ];

          # Run this command, only after creating the virtual environment
          postVenvCreation = ''
            unset SOURCE_DATE_EPOCH
            pip install -r requirements.txt
          '';

          # Now we can execute any commands within the virtual environment.
          # This is optional and can be left out to run pip manually.
          postShellHook = ''
            # allow pip to install wheels
            unset SOURCE_DATE_EPOCH
          '';
        };
      }
    );
}
