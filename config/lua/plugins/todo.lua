return{
	"todo-comments.nvim",
	for_cat = "ui",
	lazy = false,
	keys = {
      {"]t", function() require("todo-comments").jump_next() end, mode = {"n"}, noremap = true, desc = "Next [T]odo Comment"},
      {"[t", function() require("todo-comments").jump_prev() end, mode = {"n"}, noremap = true, desc = "Previous [T]odo Comment"},
      {"<leader>ft", function() Snacks.picker.todo_comments() end, mode = {"n"}, desc = "[F]ind [T]odos", },
	},
	after = function()
		require("todo-comments").setup({
			keywords = {
				CITE = {
					icon = "",
					color = "warning",
					alt = { "needcite", "\\needcite" },
				}
			},
			merge_keywords = true,
			highlight = {
				comments_only = false,
			}
		})
	end,
}

