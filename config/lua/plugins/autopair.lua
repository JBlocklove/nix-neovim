return{
	"nvim-autopairs",
	for_cat = "ui",
	after = function()
		require("nvim-autopairs").setup({
            check_ts = true,
        })
	end,
}
