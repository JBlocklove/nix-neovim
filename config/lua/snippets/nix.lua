local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local extras = require("luasnip.extras")
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt

--ls.add_snippets("nix", {
return{
	s("shell", fmt(
		[[
		{{ pkgs ? import <nixpkgs> {{}} }}:
		pkgs.mkShell {{

			name = "{}";

			packages = with pkgs; [
				{}
			];

			{}
		}}
		]],
		{
			i(1), i(2), i(0),
		}
	)),
	s("shelllib", fmt(
		[[

		env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
			{}
		];
		]],
		{
			i(0,"pkgs.libz pkgs.stdenv.cc.cc.lib")
		}
	)),

	s("pypkgs", fmt(
		[[

		(python3.withPackages(pypkgs: with pypkgs; [
			{}
		]))
		{}
		]],
		{
			i(1),i(0)
		}
	)),

}
--})

