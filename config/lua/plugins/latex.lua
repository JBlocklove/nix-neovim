-- TODO: Work on the following configs:
--		- toc
return {
	"vimtex",
	for_cat = "latex",
	before = function()
		vim.g.vimtex_fold_enabled = "1"
		vim.g.vimtex_fold_manual = "1"

		vim.g.vimtex_view_method = "zathura_simple"
		vim.g.vimtex_view_forward_search_on_start = "0"

		vim.g.vimtex_quickfix_mode = "2"
		vim.g.vimtex_quickfix_open_on_warning = "0"
		vim.g.vimtex_quickfix_ignore_filters = {
			"Marginpar on page",
			"Overfull \\hbox",
			"Underfull \\hbox",
		}
		vim.g.vimtex_quickfix_autoclose_after_keystrokes = "10"

		vim.g.vimtex_indent_enabled = "0"
	end,
}
