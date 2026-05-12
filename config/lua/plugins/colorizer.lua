return{
	"nvim-colorizer.lua",
	for_cat = "ui",
    keys = {
      {"<leader><leader>c", "<cmd>ColorizerToggle<CR>", mode = {"n"}, noremap = true, desc = "Toggle Colorizer"},
    },
	after = function()
		require("colorizer").setup()
	end,
}
