-- TODO: Work on the following configs:
--		- toc
return {
	"vimtex",
	for_cat = "latex",
	before = function()
		vim.g.vimtex_fold_enabled = 1
		vim.g.vimtex_fold_manual = 1

		vim.g.vimtex_view_method = "zathura_simple"
		vim.g.vimtex_view_forward_search_on_start = 0

		vim.g.vimtex_quickfix_mode = 2
		vim.g.vimtex_quickfix_open_on_warning = 0

		vim.g.vimtex_quickfix_autoclose_after_keystrokes = 10

		vim.g.vimtex_indent_enabled = 0

		-- texlab provides completion
		vim.g.vimtex_complete_enabled = 0

		-- K is LSP hover (LSPs/attach.lua), can't use for docs
		vim.g.vimtex_mappings_disable = { n = { "K" } }

		vim.g.vimtex_quickfix_ignore_filters = {
			[[Underfull \\hbox]], -- hide underfull hbox warnings
			[[Overfull \\hbox]], -- hide overfull hbox warnings too
			[[Underfull \\vbox]], -- hide underfull vbox warnings too

		}

		vim.g.vimtex_compiler_latexmk = {
			aux_dir = "./aux",
			out_dir = "./out",
			continuous = 0,
			options = {
				"-verbose",
				"-file-line-error",
				"-synctex=1",
				"-interaction=nonstopmode",
				"-f",
			}
		}

		vim.g.vimtex_compiler_latexmk_engines = {
			['_'] = '-lualatex',
		}
	end,

	after = function()
		local group = vim.api.nvim_create_augroup("vimtex_config", { clear = true })

		-- texlab publishes diagnostics for every file in the project, and Neovim creates an unlisted buffer for each one it hasn't opened yet. Make sure those show up in the buffer list once actually visited.
		vim.api.nvim_create_autocmd("BufEnter", {
			group = group,
			pattern = { "*.tex", "*.bib" },
			callback = function()
				if not vim.bo.buflisted then
					vim.bo.buflisted = true
				end
			end,
		})

		local mains = {}
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "VimtexEventInitPost",
			callback = function()
				local ok, main = pcall(vim.fn.eval, "b:vimtex.tex")
				if ok and main ~= "" then
					mains[vim.api.nvim_get_current_buf()] = main
				end
			end,
		})

		local function mtime(path)
			local stat = vim.uv.fs_stat(path)
			return stat and (stat.mtime.sec + stat.mtime.nsec / 1e9) or nil
		end

		local function compile(main)
			local opts = vim.g.vimtex_compiler_latexmk or {}
			local engine = (vim.g.vimtex_compiler_latexmk_engines or {})._ or "-pdf"
			local cmd = { "latexmk", engine, "-interaction=nonstopmode", "-file-line-error", "-synctex=1", "-f" }
			if opts.out_dir then
				table.insert(cmd, "-outdir=" .. opts.out_dir)
			end
			if opts.aux_dir then
				table.insert(cmd, "-auxdir=" .. opts.aux_dir)
			end
			table.insert(cmd, vim.fn.fnamemodify(main, ":t"))
			-- two minutes; on timeout vim.system kills latexmk and returns 124
			return vim.system(cmd, { cwd = vim.fn.fnamemodify(main, ":h"), text = true }):wait(120000)
		end

		-- On exit, offer to compile any project whose sources are newer than its PDF
		vim.api.nvim_create_autocmd("VimLeavePre", {
			group = group,
			callback = function()
				if #vim.api.nvim_list_uis() == 0 then
					return
				end

				local newest = {}
				for buf, main in pairs(mains) do
					if vim.api.nvim_buf_is_valid(buf) then
						local t = mtime(vim.api.nvim_buf_get_name(buf))
						if t and t > (newest[main] or 0) then
							newest[main] = t
						end
					end
				end

				local dirs = vim.g.vimtex_compiler_latexmk or {}
				for main, src in pairs(newest) do
					src = math.max(src, mtime(main) or 0)
					local root = vim.fn.fnamemodify(main, ":h")
					local pdf = vim.fs.joinpath(root, dirs.out_dir or ".", vim.fn.fnamemodify(main, ":t:r") .. ".pdf")
					local built = mtime(pdf)
					local name = vim.fn.fnamemodify(main, ":t")

					if built and src > built then
						local answer = vim.fn.confirm(
							name .. " has changed since its last compile. Compile before exiting?",
							"&Yes\n&No",
							1
						)
						if answer == 1 then
							vim.api.nvim_echo({ { "Compiling " .. name .. "...", "MoreMsg" } }, false, {})
							vim.cmd.redraw()
							local ok, result = pcall(compile, main)
							if not ok or result.code ~= 0 then
								local why = ok and ("latexmk exited " .. result.code) or tostring(result)
								vim.fn.confirm(
									name .. " failed to compile (" .. why .. "). Log: "
										.. vim.fs.joinpath(root, dirs.aux_dir or ".", vim.fn.fnamemodify(main, ":t:r") .. ".log"),
									"&OK"
								)
							end
						end
					end
				end
			end,
		})

		-- Clean aux files on quit
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "VimtexEventQuit",
			callback = function()
				pcall(vim.cmd, "VimtexClean")
			end,
		})
	end,
}
