return{
	"eyeliner.nvim",
	for_cat = "general",
	after = function()
		local palette = require("catppuccin.palettes").get_palette("mocha")
		require("eyeliner").setup{
			highlight_on_key = true,
			dim = true,
		}
		vim.api.nvim_set_hl(0, "EyelinerPrimary", { fg = palette.yellow, bold = true, underline = true })
		vim.api.nvim_set_hl(0, "EyelinerSecondary", { fg = palette.blue, underline = true })
	end,
}
