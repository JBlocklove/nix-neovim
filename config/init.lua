vim.loader.enable() -- <- bytecode caching
do
	-- Set up a global in a way that also handles non-nix compat
	local ok
	ok, _G.nixInfo = pcall(require, vim.g.nix_info_plugin_name)
	if not ok then
		package.loaded[vim.g.nix_info_plugin_name] = setmetatable({}, {
			__call = function (_, default) return default end
		})
		_G.nixInfo = require(vim.g.nix_info_plugin_name)
		-- If you always use the fetcher function to fetch nix values,
		-- rather than indexing into the tables directly,
		-- it will use the value you specified as the default
		-- TODO: for non-nix compat, vim.pack.add in another file and require here.
	end
	nixInfo.isNix = vim.g.nix_info_plugin_name ~= nil
	---@module 'lzextras'
	---@type lzextras | lze
	nixInfo.lze = setmetatable(require('lze'), getmetatable(require('lzextras')))
	function nixInfo.get_nix_plugin_path(name)
		return nixInfo(nil, "plugins", "lazy", name) or nixInfo(nil, "plugins", "start", name)
	end
end

require("options")
require("mappings")

require("plugins")
require("LSPs")

require("colorscheme") -- FIXME: Shouldn't need this but it's necessary for markview?
