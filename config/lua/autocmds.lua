local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- augroups
local general_settings = augroup("general_settings", {})
local auto_resize = augroup("auto_resize", {})

-- autocmds
autocmd(
	{"FileType"},
	{
		group = general_settings,
		pattern = "*",
		callback = function()
			vim.opt_local.formatoptions:remove({ "c", "r", "o" })
		end,
	}
)
autocmd(
	{"FileType"},
	{
		group = general_settings,
		pattern = "qf",
		command = "set nobuflisted",
	}
)
autocmd(
	{"VimLeavePre"},
	{
		group = general_settings,
		pattern = "*",
		command = "set title titleold=",
	}
)

-- Strip trailing whitespace on write
autocmd(
	{"BufWritePre"},
	{
		group = general_settings,
		pattern = "*",
		callback = function(ev)
			local skip = { markdown = true, mail = true, diff = true, gitcommit = true }
			if skip[vim.bo[ev.buf].filetype] or vim.bo[ev.buf].binary then
				return
			end
			local view = vim.fn.winsaveview()
			vim.cmd([[keeppatterns keepjumps silent! %s/\s\+$//e]])
			vim.fn.winrestview(view)
		end,
	}
)

autocmd(
	{"VimResized"},
	{
		group = auto_resize,
		pattern = "*",
		command = "wincmd =",
	}
)
