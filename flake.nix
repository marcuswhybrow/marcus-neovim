{
  description = "Marcus Whybrow's personal NeoVim config";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};
    neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
      # https://github.com/NixOS/nixpkgs/blob/db24d86dd8a4769c50d6b7295e81aa280cd93f35/pkgs/applications/editors/neovim/utils.nix#L24

      withPython3 = true;
      extraPython3Packages = _: [ ];
      withNodeJs = false;
      withRuby = true;
      extraLuaPackages = _: [ ];
      plugins = [];
      customRC = "";
    };
  in rec {
    packages.marcus-neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped neovimConfig;
    packages.default = packages.marcus-neovim;
  });
}
