return {
    "catppuccin-nvim",
    auto_enable = true,
    colorscheme = { "catppuccin-nvim", "catppuccin-mocha", "catppuccin-latte", "catppuccin-frappe", "catppuccin-macchiato" },
    after = function()
	    require("catppuccin").setup{
	    	flavour = "mocha", -- default with overrides for my moonlight colors
	    	styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
	    		comments = { "italic" }, -- Change the style of comments
            	conditionals = { "italic" },
            	loops = {},
            	functions = {},
            	keywords = {},
            	strings = {},
            	variables = {},
            	numbers = {},
            	booleans = {},
            	properties = {},
            	types = {},
            	operators = {},
	    	},
	    	lsp_styles = { -- Handles the style of specific lsp hl groups (see `:h lsp-highlight`).
	    	    virtual_text = {
        	        errors = { "italic" },
        	        hints = { "italic" },
        	        warnings = { "italic" },
        	        information = { "italic" },
        	        ok = { "italic" },
        	    },
        	    underlines = {
        	        errors = { "underline" },
        	        hints = { "underline" },
        	        warnings = { "underline" },
        	        information = { "underline" },
        	        ok = { "underline" },
        	    },
        	    inlay_hints = {
        	        background = true,
        	    },
        	},
	    	color_overrides = {
	    		mocha = {
	    			rosewater = "#f5e0dc",
	    			flamingo = "#f3aaf2",
	    			pink = "#ecb2f0",
	    			mauve = "#cba6f7",
	    			red = "#f38ba8",
	    			maroon = "#eba0ac",
	    			peach = "#f99a6a",
	    			yellow = "#ffc777",
	    			green = "#2df4c0",
	    			teal = "#40e0d0",
	    			sky = "#04dff9",
	    			sapphire = "#74c7ec",
	    			blue = "#4f99ff",
	    			lavender = "#b4a4f4",
	    			text = "#c5e1fb",
	    			subtext1 = "#bac2de",
	    			subtext0 = "#a6adc8",
	    			overlay2 = "#7486d6",
	    			overlay1 = "#7f849c",
	    			overlay0 = "#6c7086",
	    			surface2 = "#585b70",
	    			surface1 = "#45475a",
	    			surface0 = "#313244",
	    			base = "#212337",
	    			mantle = "#212337",
	    			crust = "#212337",
	    		}
	    	},
	    	custom_highlights = function(C)
	    		return{
	    			WinSeparator = { fg = C.lavender },
	    			TreesitterContextBottom = { style = {} },
	    			CursorLineNr = { fg = C.flamingo, style = {"bold"} },
	    		}
	    	end,
	    	auto_integrations = true,
	    	integrations = {
	    		gitsigns = true,
	    	},
	    }
    end,
}
