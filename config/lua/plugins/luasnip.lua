return {
	{
		"luasnip",
		for_cat = "completion",
		dep_of = { "blink.cmp" },
		after = function()
			local luasnip = require("luasnip")
			local types = require("luasnip.util.types")

			luasnip.config.setup({
				update_events = { "TextChanged", "TextChangedI" },

				region_check_events = { "CursorMoved", "CursorHold", "InsertEnter" },
				delete_check_events = { "TextChanged", "InsertLeave" },

				link_children = true,

				store_selection_keys = "<Tab>",

				enable_autosnippets = true,

				ext_opts = {
					[types.choiceNode] = {
						active = {
							virt_text = { { "●", "DiagnosticWarn" } },
						},
					},
				},
			})

			require("luasnip.loaders.from_lua").lazy_load({
				paths = vim.api.nvim_get_runtime_file("lua/snippets", true),
			})

			vim.keymap.set({ "i", "s" }, "<C-l>", function()
				if luasnip.choice_active() then
					luasnip.change_choice(1)
				end
			end, { silent = true, desc = "LuaSnip: next choice" })
		end,
	},
}
