return{
    "which-key.nvim",
    for_cat = "general",
    event = "DeferredUIEnter",
    after = function()
		require('which-key').setup({
			win = {
			    border = "single",
			}
		})
		require('which-key').add {
			{ "<leader>b", group = "[b]uffer commands" },
    		{ "<leader>g", group = "[g]it" },
    		{ "<leader>m", group = "[m]arkdown" },
    		{ "<leader>f", group = "[f]ind (picker)" },
    		{ "<leader>s", group = "[s]nacks (extra picker finds)" },
    		{ "<leader>t", group = "[t]oggles" },
    		{ "<leader>w", group = "[w]orkspace" },
			{ "<leader>l", group = "[l]atex (VimTex)" },
    	}
    end,
}
