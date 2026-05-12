return {
	{
		"markdown-preview.nvim",
        -- auto_enable = true,
    	for_cat = "markdown",
    	cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle", },
    	ft = "markdown",
    	keys = {
    	  {"<leader>mp", "<cmd>MarkdownPreview <CR>", mode = {"n"}, noremap = true, desc = "[M]arkdown [P]review"},
    	  {"<leader>ms", "<cmd>MarkdownPreviewStop <CR>", mode = {"n"}, noremap = true, desc = "Markdown Preview [S]top"},
    	  {"<leader>mt", "<cmd>MarkdownPreviewToggle <CR>", mode = {"n"}, noremap = true, desc = "[M]arkdown Preview [T]oggle"},
    	},
    	before = function()
    	  vim.g.mkdp_auto_close = 0
    	end,
	},
	{
		"markview.nvim",
        -- auto_enable = true,
		for_cat = "markdown",
		ft = "markdown",
    	keys = {
    	  {"<leader>mm", "<cmd>Markview toggle <CR>", mode = {"n"}, noremap = true, desc = "[M]arkview [M]Toggle"},
    	  {"<leader>ms", "<cmd>Markview splitToggle<CR>", mode = {"n"}, noremap = true, desc = "[M]arkview Sp[L]it"},
    	},
		lazy = true,
        after = function()
            require("markview").setup({
                markdown = {
                    enable = true,
                }
            })
            -- Necessary to keep concealcursor = ""
            vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter" }, {
                pattern = "*.md",
                callback = function()
                    vim.schedule(function()
                        if vim.bo.filetype == "markdown" then
                            vim.opt_local.concealcursor = ""
                        end
                    end)
                end,
            })
        end
	},
}
