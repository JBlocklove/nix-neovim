return{
	"indent-blankline.nvim",
	for_cat = "general",
	after = function()
		require("ibl").setup()
	end,
}
