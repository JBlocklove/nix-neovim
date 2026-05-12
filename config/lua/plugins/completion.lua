local load_w_after = function(name)
	vim.cmd.packadd(name)
	vim.cmd.packadd(name .. '/after')
end

return {
	{
		"cmp-cmdline",
		for_cat = "completion",
		on_plugin = { "blink.cmp" },
		load = load_w_after,
	},
	{
		"blink.compat",
		for_cat = "completion",
		dep_of = { "cmp-cmdline" },
	},
	{
		"colorful-menu.nvim",
		for_cat = "completion",
		on_plugin = { "blink.cmp" },
	},
	{
		"blink.cmp",
		for_cat = "completion",
		event = "DeferredUIEnter",
		after = function (_)
			require("blink.cmp").setup({
				keymap =  {
					preset = 'none',
					["<C-j>"] = { "select_next", "fallback_to_mappings" },
					["<C-k>"] = { "select_prev", "fallback_to_mappings" },

					["<C-o>"] = { "select_and_accept", "fallback" },
					["<C-s>"] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },

					["<C-n>"] = {"snippet_forward", "fallback_to_mappings"},
					["<C-p>"] = {"snippet_backward", "fallback_to_mappings"},

					["<C-b>"] = { "scroll_documentation_up", "fallback" },
					["<C-f>"] = { "scroll_documentation_down", "fallback" },

					["<C-e>"] = { "cancel", "fallback_to_mappings" },

				},
				cmdline = {
					enabled = true,
					keymap = {

						["<C-j>"] = { "select_next", "fallback_to_mappings" },
						["<C-k>"] = { "select_prev", "fallback_to_mappings" },
						["<C-o>"] = { "select_and_accept", "fallback" },
					},
					completion = {
						menu = {
							auto_show = true,
						},
					},
					sources = function()
						local type = vim.fn.getcmdtype()
						-- Search forward and backward
						if type == '/' or type == '?' then return { 'buffer' } end
						-- Commands
						if type == ':' or type == '@' then return { 'cmdline', 'cmp_cmdline' } end
						return {}
					end,
				},
				fuzzy = {
					sorts = {
						'exact',
						-- defaults
						'score',
						'sort_text',
					},
				},
				signature = {
					enabled = true,
					window = {
						show_documentation = true,
					},
				},
				completion = {
					menu = {
						border = "single",
						draw = {
							treesitter = { 'lsp' },
							components = {
								label = {
									text = function(ctx)
										return require("colorful-menu").blink_components_text(ctx)
									end,
									highlight = function(ctx)
										return require("colorful-menu").blink_components_highlight(ctx)
									end,
								},
							},
						},
					},
					documentation = {
						auto_show = true,
						window = {
							border = "single",
						},
					},
				},
				snippets = {
					preset = 'luasnip',
					active = function(filter)
						local snippet = require "luasnip"
						local blink = require "blink.cmp"
						if snippet.in_snippet() and not blink.is_visible() then
							return true
						else
							if not snippet.in_snippet() and vim.fn.mode() == "n" then snippet.unlink_current() end
							return false
						end
					end,
				},
				sources = {
					default = { 'lsp', 'path', 'snippets', 'buffer', 'omni' },
					providers = {
						path = {
							score_offset = 50,
						},
						lsp = {
							score_offset = 40,
						},
						snippets = {
							score_offset = 40,
							transform_items = function(ctx,items)
								for _, item in ipairs(items) do
									item.kind_icon = ''
									item.kind_name = 'Snippet'
								end
								return items
							end
						},
						cmp_cmdline = {
							name = 'cmp_cmdline',
							module = 'blink.compat.source',
							score_offset = -100,
							opts = {
								cmp_name = 'cmdline',
							},
						},
					},
				},
			})
		end,
	},
}
