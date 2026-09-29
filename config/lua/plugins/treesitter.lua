return {
    {
        "nvim-treesitter",
        lazy = false,
        auto_enable = true,
        after = function(plugin)
            ---@param buf integer
            ---@param language string
            local function treesitter_try_attach(buf, language)
                -- check if parser exists and load it
                if not vim.treesitter.language.add(language) then
                    return false
                end
                -- enables syntax highlighting and other treesitter features
                vim.treesitter.start(buf, language)

                -- enables treesitter based folds
                vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                vim.wo.foldmethod = "expr"
                -- ensure folds are open to begin with
                vim.o.foldlevel = 99

                -- enables treesitter based indentation
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

                return true
            end

            local installable_parsers = require("nvim-treesitter").get_available()
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local buf, filetype = args.buf, args.match

                    -- Prevent treesitter highlighting in latex files, required by vimtex
                    if filetype == "tex" or filetype == "latex" or filetype == "plaintex" then
                        return
                    end

                    local language = vim.treesitter.language.get_lang(filetype)
                    if not language then
                        return
                    end

                    if not treesitter_try_attach(buf,language) then
                        if vim.tbl_contains(installable_parsers, language) then
                            -- not already installed, so try to install them via nvim-treesitter if possible
                            require("nvim-treesitter").install(language):await(function()
                                treesitter_try_attach(buf, language)
                            end)
                        end
                    end
                end,
            })
        end,
    },
    {
        "nvim-treesitter-textobjects",
        auto_enable = true,
        lazy = false,
        before = function(plugin)
            -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main?tab=readme-ov-file#using-a-package-manager
            -- Disable entire built-in ftplugin mappings to avoid conflicts.
            -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
            vim.g.no_plugin_maps = true
        end,
        after = function(plugin)
            require("nvim-treesitter-textobjects").setup {
                select = {
                    -- Automatically jump forward to textobj
                    lookahead = true,
                    selection_modes = {
                        ['@parameter.outer'] = 'v', -- charwise
                        ['@function.outer'] = 'V', -- linewise
                    },
                    include_surrounding_whitespace = false,
                },
            }

            -- -- keymaps
            vim.keymap.set({ "x", "o" }, "am", function()
              require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "x", "o" }, "im", function()
              require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
            end)
            vim.keymap.set({ "x", "o" }, "ac", function()
              require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
            end)
            vim.keymap.set({ "x", "o" }, "ic", function()
              require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
            end)
            -- You can also use captures from other query groups like `locals.scm`
            vim.keymap.set({ "x", "o" }, "as", function()
              require "nvim-treesitter-textobjects.select".select_textobject("@local.scope", "locals")
            end)

            -- NOTE: for more textobjects options, see the following link.
            -- This template is using the new `main` branch of the repo.
            -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main
        end,
    },
	{
		"nvim-treesitter-context",
        auto_enable = true,
        lazy = false,
		after = function()
			require("treesitter-context").setup{
				line_numbers = true,
				separator = '─',
			}
		end,
	}
}
