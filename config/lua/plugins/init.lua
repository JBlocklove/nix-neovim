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
		-- we made an options.settings.cats with the value of enable for our top level specs
		-- give for_cat = "name" to disable if that one is not enabled
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
	-- From lzextras. This one makes it so that
	-- you can set up lsps within lze specs,
	-- and trigger lspconfig setup hooks only on the correct filetypes
	-- It is (unfortunately) important that it be registered after the above 2,
	-- as it also relies on the modify hook, and the value of enabled at that point
	nixInfo.lze.lsp,
}


-- lze loading
nixInfo.lze.load {
    -- load colorscheme
    {
        "trigger_colorscheme",
        event = "VimEnter",
        load = function(_name)
            vim.schedule(function()
                vim.cmd.colorscheme(nixInfo("catppuccin-mocha", "settings", "colorscheme"))
            end)
        end
    },
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
	-- { import = "plugins.eyeliner" }, -- FIXME: Install issue? Also kinda broken in general, see if there's a replacement

    -- Snacks
    -- - Picker (telescope replacement)
    -- - Indent
    -- - Notifier
    { import = "plugins.snacks" }, -- FIXME: Dim not working, change indent line color to green

	{ import = "plugins.treesitter" },
	{ import = "plugins.autopair" },

}
vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = false })


