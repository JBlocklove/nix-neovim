return{
	"bufferline.nvim",
	for_cat = "ui",
	-- lazy = false,
    event = "DeferredUIEnter",
    keys = {
      {"<Tab>", "<cmd>BufferLineCycleNext<CR>", mode = {"n"}, noremap = true, desc = "Next tab"},
      {"<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", mode = {"n"}, noremap = true, desc = "Prev tab"},
      {"<leader><Tab>", "<cmd>BufferLineMoveNext<CR>", mode = {"n"}, noremap = true, desc = "Move tab to next position"},
      {"<leader><S-Tab>", "<cmd>BufferLineMovePrev<CR>", mode = {"n"}, noremap = true, desc = "Move tab to previous position"},
      {"<leader>bj", "<cmd>BufferLinePick<CR>", mode = {"n"}, noremap = true, desc = "[B]ufferline [J]ump to other tab"},
      {"<leader>bd", "<cmd>BufferLinePickClose<CR>", mode = {"n"}, noremap = true, desc = "[B]ufferline [Delete] tab"},
      {"<leader>bp", "<cmd>BufferLineTogglePin<CR>", mode = {"n"}, noremap = true, desc = "[B]ufferline [P]in tab"},
    },
	after = function()
		local palette = require("catppuccin.palettes").get_palette("mocha")
		require("bufferline").setup{ ---@diagnostic disable-line: redundant-parameter
			options = {
				right_mouse_command = nil,
				left_mouse_command = nil,
				middle_mouse_command = nil,
				indicator = {
					style = 'none'
				},
				diagnostics = true,
				offsets = {
				    {
				        filetype = "NvimTree",
				        text = "File Explorer",
						highlight = "PanelHeading",
						padding = 1,
				        separator = true,
				    },
				},
				color_icons = true, -- whether or not to add the filetype icon highlights
				show_buffer_icons = true, -- disable filetype icons for buffers
				show_buffer_close_icons = false,
				show_close_icon = false,
				show_tab_indicators = true,
				persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
				enforce_regular_tabs = false,
				always_show_bufferline = true,
				sort_by = 'id',
		        max_name_length = 15,
		        tab_size = 15,
				separator_style = {"│", "│"},

				-- Don't show quickfix buffers in bufferline
				custom_filter = function(buf_number, _)
					if vim.bo[buf_number].filetype == "qf" then return false end
					return true
				end,

			},
			highlights = require("catppuccin.special.bufferline").get_theme{
				styles = { "italic", "bold" },
				custom = {
					all = {
						separator = { fg = palette.overlay2 },
						fill = { bg = palette.base },
						trunc_marker = { fg = palette.yellow, bg = palette.base },

					},
				},
			},
		}
	end,
}
