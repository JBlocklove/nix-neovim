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
			-- LSP namespace (<Space>)
			{ "<Space>g", group = "LSP [g]oto" },
			{ "<Space>w", group = "LSP [w]orkspace" },
			{ "<Space>c", group = "LSP [c]ode" },
			{ "<Space>d", group = "LSP [d]ocument" },
			{ "<Space>t", group = "LSP [t]oggles" },
			{ "<leader>l", group = "[l]atex (VimTex)" },
    	}
    end,
}
