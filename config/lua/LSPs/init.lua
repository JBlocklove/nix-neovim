-- Buffer-local setup lives in one LspAttach LSPs/attach.lua.
require("LSPs.attach")

-- NOTE: This config uses lzextras.lsp handler https://github.com/BirdeeHub/lzextras?tab=readme-ov-file#lsp-handler
-- Because we have the paths, we can set a more performant fallback function
-- for when you don't provide a filetype to trigger on yourself.
-- If you do provide a filetype, this will never be called.
nixInfo.lze.h.lsp.set_ft_fallback(function(name)
    local lspcfg = nixInfo.get_nix_plugin_path "nvim-lspconfig"
    if lspcfg then
        local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
        return (ok and cfg or {}).filetypes or {}
    else
        -- the less performant thing we are trying to avoid at startup
        return (vim.lsp.config[name] or {}).filetypes or {}
    end
end)

nixInfo.lze.load {
    {
        "nvim-lspconfig",
        for_cat = "lsp",
        auto_enable = true,
        lsp = function(plugin)
            vim.lsp.config(plugin.name, plugin.lsp or {})
            vim.lsp.enable(plugin.name)
        end,
        before = function(_)
            -- Defaults shared by every server. vim.lsp.config('*') merges under each server's own config
            local base = {}
            local ok, blink = pcall(require, "blink.cmp")
            if ok then
                base.capabilities = blink.get_lsp_capabilities()
            end
            vim.lsp.config("*", base)
        end,
    },
    {
        "mason.nvim",
        enabled = not nixInfo.isNix,
        priority = 100,
        on_plugin = { "nvim-lspconfig" },
        lsp = function(plugin)
            vim.cmd.MasonInstall(plugin.name)
        end,
    },
    {
        "lazydev.nvim",
        for_cat = "lua",
        cmd = { "LazyDev" },
        ft = "lua",
        after = function(_)
            -- Nix: point at the plugin's lua/ dir directly.
            -- Non-nix: fall back to the plugin name, which lazydev resolves itself.
            local function lib(name, words)
                local path = nixInfo.get_nix_plugin_path(name)
                return { path = path and (path .. "/lua") or name, words = words }
            end
            require('lazydev').setup({
                library = {
                    lib("lze", { "nixInfo%.lze" }),
                    lib("lzextras", { "nixInfo%.lze" }),
                    -- types for the global Snacks object used in keymaps
                    lib("snacks.nvim", { "Snacks" }),
                },
            })
        end,
    },
    {
        "lua_ls",
        for_cat = "lua",
        lsp = {
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    hint = { enable = true },
                    diagnostics = {
                        globals = { "nixInfo", "vim", },
                        disable = { 'missing-fields' },
                    },
                },
            },
        },
    },

	-- LaTeX LSP, works with vimtex
    {
        "texlab",
        for_cat = "latex",
        lsp = {
            filetypes = { "tex", "bib" },

			-- Reads vimtex latexmk configs to find necessary aux and out directories
            before_init = function(_, config)
                local latexmk = vim.g.vimtex_compiler_latexmk or {}
                local engine = (vim.g.vimtex_compiler_latexmk_engines or {})._ or "-pdf"
                local aux = latexmk.aux_dir or "."
                local out = latexmk.out_dir or "."

                local texlab = config.settings.texlab
                texlab.build.auxDirectory = aux
                texlab.build.logDirectory = aux
                texlab.build.pdfDirectory = out
                texlab.build.args = {
                    engine, "-interaction=nonstopmode", "-file-line-error", "-synctex=1",
                    "-auxdir=" .. aux, "-outdir=" .. out, "%f",
                }
                texlab.diagnostics = {
                    ignoredPatterns = vim.g.vimtex_quickfix_ignore_filters or {},
                }
            end,
            settings = {
                texlab = {
                    bibtexFormatter = "texlab",
                    build = {
                        executable = "latexmk",
                        forwardSearchAfter = false,
                        onSave = false,
                    },
                    chktex = {
                        onEdit = false,
                        onOpenAndSave = false,
                    },
                    diagnosticsDelay = 300,
                    formatterLineLength = 80,
                    latexFormatter = "latexindent",
                    latexindent = {
                        modifyLineBreaks = false
                    },
                },
            },
        },
    },

    {
        -- non-nix fallback only
        "nil_ls",
        enabled = not nixInfo.isNix,
        lsp = {},
    },

    {
        "nixd",
        for_cat = "nix",
        enabled = nixInfo.isNix,
        lsp = {
            settings = {
                nixd = {
                    nixpkgs = {
                        -- The exact nixpkgs this neovim was built from so completions work without a NIX_PATH channel.
                        expr = ("import %s {}"):format(nixInfo("<nixpkgs>", "settings", "nixpkgs_path")),
                    },
					-- TODO: Figure out how to get the system info proframmatically
                    -- Option completion for the system config, e.g.:
                    -- options = {
                    --     nixos = { expr = [[(builtins.getFlake "/path/to/flake").nixosConfigurations.HOST.options]] },
                    --     home_manager = { expr = [[(builtins.getFlake "/path/to/flake").homeConfigurations.USER.options]] },
                    -- },
                    formatting = {
                        command = { "nixfmt" }
                    },
                    diagnostic = {
                        suppress = {
                            "sema-escaping-with"
                        }
                    }
                }
            },
        },
    },

    {
        "pyright",
        for_cat = "python",
        lsp = {},
    },

	-- HDL LSP configs
    {
        "slang_server",
        for_cat = "verilog",
        lsp = {
            cmd = { "slang-server" },
            filetypes = { "verilog", "systemverilog" },
            root_markers = { ".slang", ".git" },
        },
    },
    {
        "verible",
        for_cat = "verilog",
        lsp = {
            filetypes = { "verilog", "systemverilog" },
            cmd = {
                "verible-verilog-ls",
                "--rules_config_search",
                "--indentation_spaces=4",
            },
            on_init = function(client)
                local caps = client.server_capabilities
                if not caps then return end
                caps.hoverProvider = false
                caps.definitionProvider = false
                caps.referencesProvider = false
                caps.renameProvider = false
                caps.documentSymbolProvider = false
                caps.workspaceSymbolProvider = false
                caps.documentHighlightProvider = false
                caps.completionProvider = nil
            end,
        },
    },

    {
        "vhdl_ls",
        for_cat = "vhdl",
        lsp = {
            filetypes = { "vhdl" },
            root_markers = { "vhdl_ls.toml", ".git" },
        },
    },
    {
        "bashls",
        for_cat = "bash",
        lsp = {
            root_dir = function(bufnr, on_dir)
                local fname = vim.api.nvim_buf_get_name(bufnr)
                if fname:match("%.zsh$") then
                    return
                end
                on_dir(vim.fs.root(bufnr, { ".git" }) or vim.fs.dirname(fname))
            end,
        },
    },
}

vim.diagnostic.config {
    severity_sort = true,
    float = {
        source = "if_many",
    },
    virtual_lines = false,
    virtual_text = {
        severity = { min = vim.diagnostic.severity.ERROR }
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "󰌶",
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
        }
    }
}
