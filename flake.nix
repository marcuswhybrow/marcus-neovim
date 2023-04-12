{
  description = "Marcus Whybrow's personal NeoVim config";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};

    marcusNeovim = { stdenv, makeBinaryWrapper }: let
      neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (pkgs.neovimUtils.makeNeovimConfig {
        # https://github.com/NixOS/nixpkgs/blob/db24d86dd8a4769c50d6b7295e81aa280cd93f35/pkgs/applications/editors/neovim/utils.nix#L24
        withPython3 = false; # defaults to true
        extraPython3Packages = _: [ ];
        withNodeJs = false;
        withRuby = false; # defaults to true
        extraLuaPackages = _: [ ];
        customRC = '''';

        plugins = with pkgs.vimPlugins; [
          # Telescope
          telescope-fzf-native-nvim
          nvim-web-devicons
          plenary-nvim
          telescope-nvim
          (nvim-treesitter.withPlugins (p: with p; [
            nix
            go
            rust
            bash
            fish
          ]))
        ];

        # https://github.com/NixOS/nixpkgs/blob/db24d86dd8a4769c50d6b7295e81aa280cd93f35/pkgs/applications/editors/neovim/wrapper.nix#L13
        extraName = "";
        withPython2 = false;
        vimAlias = true; # defaults to false
        viAlias = false;
        wrapRc = false;
        neovimRcContent = "";
      });

      luaInit = pkgs.writeText "init.lua" ''
        vim.api.nvim_command('set number')
        vim.api.nvim_command('set relativenumber')

        -- Telescope --

        -- https://github.com/nvim-telescope/telescope.nvim#usage
        local telescopeBuiltin = require('telescope.builtin')

        vim.keymap.set('n', '<leader>ff', telescopeBuiltin.find_files, {})
        vim.keymap.set('n', '<leader>fg', telescopeBuiltin.live_grep, {})
        vim.keymap.set('n', '<leader>fb', telescopeBuiltin.buffers, {})
        vim.keymap.set('n', '<leader>fh', telescopeBuiltin.help_tags, {})

        -- Treesitter --

        require'nvim-treesitter.configs'.setup {
          highlight = {
            enable = true,
          },
        }

      '';
    in stdenv.mkDerivation {
      pname = "marcus-neovim";
      version = "unstable";
      src = ./.;

      nativeBuildInputs = [ makeBinaryWrapper ];

      installPhase = ''
        mkdir -p $out/bin
        mkdir -p $out/config
        cp ${luaInit} $out/config/init.lua
        makeWrapper ${neovim}/bin/nvim $out/bin/vim --add-flags "-u $out/config/init.lua"
      '';
    };
  in rec {
    packages.marcus-neovim = pkgs.callPackage marcusNeovim {};
    packages.default = packages.marcus-neovim;

    apps.marcus-neovim = {
      type = "app";
      program = "${self.packages.${system}.marcus-neovim}/bin/vim";
    };
    apps.default = apps.marcus-neovim;
  });
}
