{
  description = "A simple script to bootstrap nix systems";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    defaultPackage.x86_64-linux = pkgs.writeShellScriptBin "nixstrap" ''

      showUsage() {
        docs="Usage
        * -f, --flake
          fetch the nixos configuration flake from this uri
        * -h, --help 
          Show this help"
        echo "$docs"
      }

      while [[ $# -gt 0 ]]; do
        case "$1" in
          -f | --flake)
            flake=$2
            shift
            ;;
          -h | --help)
            showUsage
            exit 0
            ;;
          *)
            showUsage
            exit 1
            ;;
        esac
        shift
      done

      if [[ -z $flake ]]; then
          echo "Missing flake uri"
          exit 1
      fi

      nix --experimental-features 'nix-command flakes' run github:nix-community/disko -- --flake $flake -m disko
      nixos-install --flake $flake --no-root-passwd
      reboot
    '';
  };
}
