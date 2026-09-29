inputs: { config, wlib, lib, pkgs, ... }: {

    imports = [ wlib.wrapperModules.neovim ];
    options.nvim-lib.neovimPlugins = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf wlib.types.stringable;
        default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
    };

    config.settings.config_directory = ./config;
    
    # Handle colorschemes nicely (only install colorschemes that are actually in use)
    options.settings.colorscheme = lib.mkOption {
        type = lib.types.str;
        default = "catppuccin-mocha";
    };
    # config.settings.colorscheme = "catppuccin-mocha";
    config.specs.colorscheme = {
        lazy = true;
        data = builtins.getAttr config.settings.colorscheme ( with pkgs.vimPlugins; {
            "catppuccin-nvim" = catppuccin-nvim;
            "catppuccin-mocha" = catppuccin-nvim;
            "catppuccin-frappe" = catppuccin-nvim;
            "catppuccin-latte" = catppuccin-nvim;
            "catppuccin-macchiato" = catppuccin-nvim;
        });
    };

    # lzextras setup
    config.specs.lze = [
        config.nvim-lib.neovimPlugins.lze{
            data = config.nvim-lib.neovimPlugins.lzextras;
            name = "lzextras";
        }
    ];

    # LSP Setup
    config.specs.lsp = {
        after = [ "general" ];
        lazy = true;
        data = with pkgs.vimPlugins; [
            nvim-lspconfig
        ];
    };

    config.specs.nix = {
        after = [ "lsp" ];
        lazy = true;
        data = null;
        runtimePkgs = with pkgs; [
            nixd
            nixfmt
        ];
    };
    # Handed to lua via nixInfo so nixd evaluates the same nixpkgs this wrapper uses
    options.settings.nixpkgs_path = lib.mkOption {
        type = lib.types.str;
        default = "${pkgs.path}";
    };

    config.specs.lua = {
        after = [ "lsp" ];
        lazy = true;
        data = with pkgs.vimPlugins; [
            lazydev-nvim
        ];
        runtimePkgs = with pkgs; [
            lua-language-server
            stylua
        ];
    };

    config.specs.latex = {
        after = [ "lsp" ];
        lazy = false;
        data = with pkgs.vimPlugins; [
            vimtex
        ];
        runtimePkgs = with pkgs; [
            zathura
            pandoc
            texlab # contains the tex LSP
        ];
    };

    config.specs.python = {
        after = [ "lsp" ];
        lazy = true;
        data = null;
        runtimePkgs = with pkgs; [
            pyright
        ];
    };

    config.specs.verilog = {
        after = [ "lsp" ];
        lazy = false;
        data = null;
        runtimePkgs = with pkgs; [
			slang-server
			verible
        ];
    };

    config.specs.vhdl = {
        after = [ "lsp" ];
        lazy = false;
        data = null;
        runtimePkgs = with pkgs; [
            vhdl-ls
        ];
    };

    config.specs.bash = {
        after = [ "lsp" ];
        lazy = false;
        data = null;
        runtimePkgs = with pkgs; [
            bash-language-server
            shellcheck # bash-language-server diagnostics
            shfmt      # bash-language-server formatting
        ];
    };

    config.specs.markdown = {
        after = [ "general" ];
        lazy = true;
        data = with pkgs.vimPlugins; [
            markdown-preview-nvim
            markview-nvim 
        ];
    };

    # Some setup plugins
    config.specs.setup = {
        after = [ "lze" ];
        lazy = false;
        data = with pkgs.vimPlugins; [
		    plenary-nvim
			nvim-web-devicons
            vim-tmux-navigator
        ];
    };

    # General plugins
    config.specs.general = {
        after = [ "setup" ];
        lazy = true;
        runtimePkgs = with pkgs; [
			ripgrep
            tree-sitter
        ];
        data = with pkgs.vimPlugins; [
            snacks-nvim
            nvim-treesitter.withAllGrammars
            nvim-treesitter-textobjects
			nvim-treesitter-context
            # autoclose-nvim
            nvim-autopairs
            trouble-nvim
            undotree
        ];
    };

    config.specs.completion = {
        after = [ "general" ];
        lazy = true;
        data = with pkgs.vimPlugins; [
            blink-cmp
            blink-compat
            cmp-cmdline
            luasnip
            colorful-menu-nvim
        ];
    };

    config.specs.ui = {
        after = [ "general" "colorscheme" ];
        lazy = true;
        data = with pkgs.vimPlugins; [
			nvim-colorizer-lua
			bufferline-nvim
			lualine-nvim
			todo-comments-nvim
            gitsigns-nvim
            fidget-nvim
            which-key-nvim
        ];
    };

    # TODO: Does this need to be its own spec? Probably moving to snacks...
    config.specs.telescope = {
        after = [ "general" ];
        lazy = true;
        data = with pkgs.vimPlugins; [
        	telescope-nvim
			telescope-fzf-native-nvim
            telescope-ui-select-nvim

        ];

    };

    config.specMods = { parentSpec ? null, parentOpts ? null, parentName ? null, config, ... }: {
        options.runtimePkgs = lib.mkOption {
            type = lib.types.listOf wlib.types.stringable;
            default = [ ];
            description = "a runtimePkgs spec field to put packages to suffix to the PATH";
        };
    };
    config.runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ];

    # Inform lua of which top level specs are enabled
    # All enabled by default
    options.settings.cats = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf lib.types.bool;
        default = builtins.mapAttrs (_: v: v.enable) config.specs;
    };
    # build plugins from inputs set
    options.nvim-lib.pluginsFromPrefix = lib.mkOption {
        type = lib.types.raw;
        readOnly = true;
        default = prefix: inputs:
        lib.pipe inputs [
            builtins.attrNames
            (builtins.filter (s: lib.hasPrefix prefix s))
            (map (
            input:
                let
                    name = lib.removePrefix prefix input;
                in {
                    inherit name;
                    value = config.nvim-lib.mkPlugin name inputs.${input};
                }
            ))
            builtins.listToAttrs
        ];
  };
}



