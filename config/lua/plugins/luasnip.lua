return {
	{
		"luasnip",
		for_cat = "completion",
		dep_of = { "blink.cmp" },
		after = function ()
			local luasnip = require "luasnip"
			local snippet_paths = vim.api.nvim_get_runtime_file("lua/snippets", true)[1]
			require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip.loaders.from_lua").lazy_load{
				paths = snippet_paths
			}
			luasnip.config.setup {
				enable_autosnippets = true,
			}

			vim.keymap.set({ "i", "s" }, "<C-f>", function()
				if luasnip.choice_active() then
					luasnip.change_choice(1)
				end
			end)

			-- vim.keymap.set({ "i", "s" }, "<C-f>", function()
			-- 	if luasnip.choice_active() then
			-- 		luasnip.change_choice(1)
			-- 	end
			-- end)
		end,
	},
}
