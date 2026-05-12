return{
    "fidget.nvim",
    for_cat = "ui",
    event = "DeferredUIEnter",
    after = function()
      require("fidget").setup{
		  notification = {
			window = {
		  	    winblend = 0,
		  	    border = "single",
		  	},
		  },
	  }
    end,
}
