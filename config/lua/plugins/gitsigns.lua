return{
	"gitsigns.nvim",
	for_cat = "ui",
    event = "DeferredUIEnter",
    keys = {
      {"<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", mode = {"n"}, noremap = true, desc = "[G]it [P]review hunk"},
    },
	after = function()
		require("gitsigns").setup ()
	end,
}
