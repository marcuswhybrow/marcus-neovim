{
  description = "Marcus Whybrow's personal NeoVim config";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};

    neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (pkgs.neovimUtils.makeNeovimConfig {
      # https://github.com/NixOS/nixpkgs/blob/db24d86dd8a4769c50d6b7295e81aa280cd93f35/pkgs/applications/editors/neovim/utils.nix#L24
      withPython3 = false; # defaults to true
      extraPython3Packages = _: [ ];
      withNodeJs = false;
      withRuby = false; # defaults to true
      extraLuaPackages = _: [ ];
      plugins = [];
      customRC = '''';

      # https://github.com/NixOS/nixpkgs/blob/db24d86dd8a4769c50d6b7295e81aa280cd93f35/pkgs/applications/editors/neovim/wrapper.nix#L13
      extraName = "";
      withPython2 = false;
      vimAlias = true; # defaults to false
      viAlias = false;
      wrapRc = true;
      neovimRcContent = "";
    });

    luaInit = pkgs.writeText "init.lua" ''
        vim.api.nvim_command('set number')
        vim.api.nvim_command('set relativenumber')
        print("Hello")
    '';

    marcusNeovim = { stdenv, makeBinaryWrapper }: stdenv.mkDerivation {
      pname = "marcus-neovim";
      version = "unstable";
      src = ./.;

      nativeBuildInputs = [ makeBinaryWrapper ];

      installPhase = ''
        mkdir $out;
        makeWrapper ${neovim}/bin/nvim $out/bin/vim --add-flags "-u ${luaInit}"
      '';
    };
  in rec {
    packages.marcus-neovim = pkgs.callPackage marcusNeovim {};
    packages.default = packages.marcus-neovim;
  });
}
