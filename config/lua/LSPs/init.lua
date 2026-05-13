
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
            vim.lsp.config('*', {
                on_attach = require('LSPs.on_attach'),
            })
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
            require('lazydev').setup({
                library = {
                    { words = { "nixInfo%.lze" }, path = nixInfo("lze", "plugins", "start", "lze") .. '/lua', },
                    { words = { "nixInfo%.lze" }, path = nixInfo("lzextras", "plugins", "start", "lzextras") .. '/lua' },
                },
            })
        end,
    },
    {
        "lua_ls",
        for_cat = "lua",
        lsp = {
            -- if you provide the filetypes it doesn't ask lspconfig for the filetypes
            filetypes = { 'lua' },
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    formatters = {
                        ignoreComments = true,
                    },
                    signatureHelp = { enabled = true },
                    diagnostics = {
                        globals = { "nixInfo", "vim", },
                        disable = { 'missing-fields' },
                    },
                    telemetry = { enabled = false },
                },
            },
        },
    },
    -- TeXLab - LaTeX LSP
    {
        "texlab",
        for_cat = "latex",
        lsp = {
            filetypes = { "tex", "bib" },
            on_attach = function(_)
                local group = vim.api.nvim_create_augroup("texlabunlistfix", { clear = true })
                vim.api.nvim_create_autocmd("BufEnter", {
                    group = group,
                    pattern = "*.tex",
                    callback = function()
                        if not vim.bo.buflisted then
                            vim.bo.buflisted = true
                        end
                    end,
                })
            end,
            settings = {
                texlab = {
                    auxDirectory = ".",
                    bibtexFormatter = "texlab",
                    build = {
                        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
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
                    forwardSearch = {
                        args = {},
                    },
                    latexFormatter = "latexindent",
                    latexindent = {
                        modifyLineBreaks = false
                    },
                },
            },
        },
    },
    {
        "rnix",
        -- mason doesn't have nixd
        enabled = not nixInfo.isNix,
        lsp = {
            filetypes = { "nix" },
        },
    },
    {
        "nil_ls",
        -- mason doesn't have nixd
        enabled = not nixInfo.isNix,
        lsp = {
            filetypes = { "nix" },
        },
    },
    {
        "nixd",
        for_cat = "nix",
        enabled = nixInfo.isNix,
        lsp = {
            filetypes = { "nix" },
            settings = {
                nixd = {
                    nixpkgs = {
                        expr = [[import <nixpkgs> {}]],
                    },
                    options = {
                    },
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
        lsp = {
            filetypes = { "python" },
        },
    },
    {
        "verible",
        for_cat = "verilog",
        lsp = {
            filetypes = { "verilog", "systemverilog" },
            cmd = { "verible-verilog-ls", "--rules_config_search" },
        },
    },
    {
        "svlangserver",
        for_cat = "verilog",
        lsp = {
            filetypes = { "systemverilog" },
            settings = {
                systemverilog = {
                    includeIndexing = { "**/*.{sv,svh}" },
                    linter = "verilator",
                    launchConfiguration =  "verilator --sv --lint-only --Wall",
                },
            },
        },
    },
    {
        "vhdl_ls",
        for_cat = "vhdl",
        lsp = {
            filetypes = { "vhdl" },
            settings = {},
        },
    },
    {
        "bashls",
        for_cat = "bash",
        lsp = {
            filetypes = { "sh" },
        },
    },
}

vim.diagnostic.config {
    float = {
        border = "single",
    },
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

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function (event)
        require("LSPs.on_attach")(nil, event.buf)
    end,
})

