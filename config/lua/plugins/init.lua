nixInfo.lze.register_handlers {
	{
		-- adds an `auto_enable` field to lze specs
		-- if true, will disable it if not installed by nix.
		-- if string, will disable if that name was not installed by nix.
		-- if a table of strings, it will disable if any were not.
		spec_field = "auto_enable",
		set_lazy = false,
		modify = function(plugin)
			if vim.g.nix_info_plugin_name then
				if type(plugin.auto_enable) == "table" then
					for _, name in pairs(plugin.auto_enable) do
						if not nixInfo.get_nix_plugin_path(name) then
							plugin.enabled = false
							break
						end
					end
				elseif type(plugin.auto_enable) == "string" then
					if not nixInfo.get_nix_plugin_path(plugin.auto_enable) then
						plugin.enabled = false
					end
				elseif type(plugin.auto_enable) == "boolean" and plugin.auto_enable then
					if not nixInfo.get_nix_plugin_path(plugin.name) then
						plugin.enabled = false
					end
				end
			end
			return plugin
		end,
	},
	{
		spec_field = "for_cat",
		set_lazy = false,
		modify = function(plugin)
			if vim.g.nix_info_plugin_name then
				if type(plugin.for_cat) == "string" then
					plugin.enabled = nixInfo(false, "settings", "cats", plugin.for_cat)
				end
			end
			return plugin
		end,
	},
	nixInfo.lze.lsp,
}


-- lze loading
nixInfo.lze.load {
	-- Load catppuccin colorscheme
    { import = "plugins.catppuccin" },

    -- Other UI
	{ import = "plugins.lualine" },
	{ import = "plugins.bufferline" },
	{ import = "plugins.colorizer" },
	{ import = "plugins.whichkey" },
	{ import = "plugins.fidget" },
	{ import = "plugins.todo" },
	{ import = "plugins.gitsigns" },

    -- Completion
	{ import = "plugins.completion" },
	{ import = "plugins.luasnip" },

    -- Markup
	{ import = "plugins.markdown" },
	{ import = "plugins.latex" },

    -- Diagnostics
	{ import = "plugins.trouble" },
	{ import = "plugins.undotree" },

    -- Navigation
	{ import = "plugins.tmux" },

    -- Snacks
    -- - Picker (telescope replacement)
    -- - Indent
    -- - Notifier
    { import = "plugins.snacks" },

	{ import = "plugins.treesitter" },
	{ import = "plugins.autopair" },

}

vim.cmd.colorscheme(nixInfo("catppuccin-mocha", "settings", "colorscheme"))


