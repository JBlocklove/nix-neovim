-- Oh boy getting word and letter counts to work for LaTeX is a pain
-- Also, the latex word count only updates on write anyway
vim.api.nvim_create_augroup("LualineVimtexCache", {clear = true})
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
	group = "LualineVimtexCache",
	pattern = { "*.tex" },
	callback = function()
		if vim.fn.exists("*vimtex#misc#wordcount") == 1 then
			vim.b.vimtex_words = vim.fn['vimtex#misc#wordcount']()
			vim.b.vimtex_chars = vim.fn['vimtex#misc#wordcount']({ count_letters = true })
		end
	end,
})

local function get_wordcount()
	local ft = vim.bo.filetype
	if (ft == "latex" or ft == "tex") then
		return vim.b.vimtex_words or "..."
	elseif vim.fn.mode():find("[vV]") then
		return vim.fn.wordcount().visual_words
	else
		return vim.fn.wordcount().words
	end
end

local function get_charcount()
	local ft = vim.bo.filetype
	if (ft == "latex" or ft == "tex") then
		return vim.b.vimtex_chars or "..."
	elseif vim.fn.mode():find("[vV]") then
		return vim.fn.wordcount().visual_chars
	else
		return vim.fn.wordcount().chars
	end
end

local function wordcount()
	return "" .. " " .. get_wordcount()
end

local function charcount()
	return "󰾹" .. " " .. get_charcount()
end

local function is_prose()
	local ft = vim.bo.filetype
	return ft == "markdown" or ft == "text" or ft == "mail" or ft == "latex" or ft == "tex"
end


return {
	"lualine.nvim",
	for_cat = "ui",
	event = "DeferredUIEnter",
	after = function()
		local palette = require("catppuccin.palettes").get_palette("mocha")
		-- local navic = require 'nvim-navic'

		local conditions = {
			buffer_not_empty = function()
				return vim.fn.empty(vim.fn.expand '%:t') ~= 1
			end,
			hide_in_width = function()
				return vim.fn.winwidth(0) > 80
			end,
			check_git_workspace = function()
				local filepath = vim.fn.expand '%:p:h'
				local gitdir = vim.fn.finddir('.git', filepath .. ';')
				return gitdir and #gitdir > 0 and #gitdir < #filepath
			end,
		}

		local statusline = {
			options = {
				globalstatus = true,
				theme = {
					normal = {
						a = { fg = palette.text, bg = palette.base },
						b = { fg = palette.text, bg = palette.base },
						c = { fg = palette.text, bg = palette.base },
					},
				},
				component_separators = '',
				section_separators = '',
				disabled_filetypes = {},
				always_divide_middle = true,
			},
			sections = {
				lualine_a = {
					{
						function()
							local mode_color = {
								n = palette.blue,
								i = palette.green,
								v = palette.lavender,
								[''] = palette.lavender,
								V = palette.lavender,
								c = palette.yellow,
								no = palette.blue,
								s = palette.peach,
								S = palette.peach,
								[''] = palette.peach,
								ic = palette.yellow,
								R = palette.lavender,
								Rv = palette.lavender,
								cv = palette.red,
								ce = palette.red,
								r = palette.sky,
								rm = palette.sky,
								['r?'] = palette.sky,
								['!'] = palette.red,
								t = palette.red,
							}
							vim.api.nvim_command('hi! LualineMode guifg=' .. mode_color[vim.fn.mode()] .. ' guibg=' .. palette.base)
							return '▊'
						end,
						color = 'LualineMode',
						padding = { left = 0, right = 0 },
					},
				},
				lualine_b = {
					{
						'branch',
						icon = '',
						color = { fg = palette.lavender, gui = 'bold' }
					},
					{
						'diff',
						symbols = { added = ' ', modified = ' ', removed = ' ' },
						diff_color = {
							added = { fg = palette.green },
							modified = { fg = palette.yellow },
							removed = { fg = palette.red },
						},
						cond = conditions.hide_in_width,
					}
				},
				lualine_c = {
					{
						'filename',
						cond = conditions.buffer_not_empty,
						color = { fg = palette.magenta, gui = 'bold' },
					},
				},
				lualine_x = {
					{
						'diagnostics',
						sources = { 'nvim_diagnostic' },
						symbols = { error = ' ', warn = ' ', info = ' ', hint = "󰌵 "},
						diagnostics_color = {
							color_error = { fg = palette.red },
							color_warn = { fg = palette.yellow },
							color_info = { fg = palette.sky },
						}
					},
					{
						function()
							local msg = 'No Active Lsp'
							local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
							local clients = vim.lsp.get_clients()
							if next(clients) == nil then
								return msg
							end
							for _, client in ipairs(clients) do
								local filetypes = client.config.filetypes
								if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
									return client.name
								end
							end
							return msg
						end,
						color = { fg = palette.text, gui = 'bold' },
					},
					{
						'filetype', icons_enabled=false
					},
				},
				lualine_y = {
					{ charcount, cond = is_prose },
					{ wordcount, cond = is_prose },
				},
				lualine_z = {
					{ "location" },
					{ "progress" },
				}
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {}
			},
			tabline = {},
			extensions = {},
			winbar = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					{
						--navic.get_location,
						--cond = navic.is_available,
					},
				},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
			inactive_winbar = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
		}
		local lualine = require('lualine')
		lualine.setup(statusline) ---@diagnostic disable-line: redundant-parameter
	end,
}
