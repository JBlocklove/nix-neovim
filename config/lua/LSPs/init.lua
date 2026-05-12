
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
	-- {
	-- 	"mason.nvim",
	-- 	enabled = not catUtils.isNixCats,
	-- 	on_plugin = { "nvim-lspconfig" },
	-- 	load = function(name)
	-- 		vim.cmd.packadd(name)
	-- 		vim.cmd.packadd("mason-lspconfig.nvim")
	-- 		require('mason').setup()
	-- 		-- auto install will make it install servers when lspconfig is called on them.
	-- 		require('mason-lspconfig').setup { automatic_installation = true, }
	-- 	end,
	-- },
	-- {
	-- 	-- lazydev makes your lsp way better in your config without needing extra lsp configuration.
	-- 	"lazydev.nvim",
	-- 	for_cat = "neonixdev",
	-- 	cmd = { "LazyDev" },
	-- 	ft = "lua",
	-- 	after = function(_)
	-- 		require('lazydev').setup({
	-- 			library = {
	-- 				{ words = { "nixCats" }, path = (nixCats.nixCatsPath or "") .. '/lua' },
	-- 			},
	-- 		})
	-- 	end,
	-- },
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
	  -- also these are regular specs and you can use before and after and all the other normal fields
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

  -- {
  --   "rnix",
  --   -- mason doesn't have nixd
  --   enabled = not catUtils.isNixCats,
  --   lsp = {
  --     filetypes = { "nix" },
  --   },
  -- },
  -- {
  --   "nil_ls",
  --   -- mason doesn't have nixd
  --   enabled = not catUtils.isNixCats,
  --   lsp = {
  --     filetypes = { "nix" },
  --   },
  -- },
  -- {
  --   "nixd",
  --   enabled = catUtils.isNixCats and (nixCats('nix') or nixCats('neonixdev')) or false,
  --   lsp = {
  --     filetypes = { "nix" },
  --     settings = {
  --       nixd = {
  --         -- nixd requires some configuration.
  --         -- luckily, the nixCats plugin is here to pass whatever we need!
  --         -- we passed this in via the `extra` table in our packageDefinitions
  --         -- for additional configuration options, refer to:
  --         -- https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
  --         nixpkgs = {
  --           -- in the extras set of your package definition:
  --           -- nixdExtras.nixpkgs = ''import ${pkgs.path} {}''
  --           expr = nixCats.extra("nixdExtras.nixpkgs") or [[import <nixpkgs> {}]],
  --         },
  --         options = {
  --           -- If you integrated with your system flake,
  --           -- you should use inputs.self as the path to your system flake
  --           -- that way it will ALWAYS work, regardless
  --           -- of where your config actually was.
  --           nixos = {
  --             -- nixdExtras.nixos_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").nixosConfigurations.configname.options''
  --             expr = nixCats.extra("nixdExtras.nixos_options")
  --           },
  --           -- If you have your config as a separate flake, inputs.self would be referring to the wrong flake.
  --           -- You can override the correct one into your package definition on import in your main configuration,
  --           -- or just put an absolute path to where it usually is and accept the impurity.
  --           ["home-manager"] = {
  --             -- nixdExtras.home_manager_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").homeConfigurations.configname.options''
  --             expr = nixCats.extra("nixdExtras.home_manager_options")
  --           }
  --         },
  --         formatting = {
  --           command = { "nixfmt" }
  --         },
  --         diagnostic = {
  --           suppress = {
  --             "sema-escaping-with"
  --           }
  --         }
  --       }
  --     },
  --   },
  -- },
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

