{
  description = "Zen Browser";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    info = builtins.fromJSON (builtins.readFile ./info.json);
    pkgs = nixpkgs.legacyPackages.${system};
    mkZen = pkgs.callPackage ./package.nix {
      sourceInfo = {
        variant = "x86_64";
        src = {
          url = info.url;
          hash = info.hash;
        };
        inherit (info) version;
      };
    };
  in {
    packages."${system}" = {
      default = mkZen;
    };
  };
}
