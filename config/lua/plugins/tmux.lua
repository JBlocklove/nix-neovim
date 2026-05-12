return{
	"vim-tmux-navigator",
	for_cat = "general",
	lazy = false,
	cmd = { "TmuxNavigateLeft", "TmuxNavigateRight", "TmuxNavigateUp", "TmuxNavigateDown" },
	keys = {
	  {"<C-S-h>", "<cmd>TmuxNavigateLeft<cr>", mode = {"n"}, noremap = true, desc = "Navigate to left pane"},
	  {"<C-S-l>", "<cmd>TmuxNavigateRight<cr>", mode = {"n"}, noremap = true, desc = "Navigate to right pane"},
	  {"<C-S-k>", "<cmd>TmuxNavigateUp<cr>", mode = {"n"}, noremap = true, desc = "Navigate to upper pane"},
	  {"<C-S-j>", "<cmd>TmuxNavigateDown<cr>", mode = {"n"}, noremap = true, desc = "Navigate to lower pane"},
	},
}
