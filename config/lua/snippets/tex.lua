local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local extras = require("luasnip.extras")
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt
local c = ls.choice_node
local d = ls.dynamic_node
local sn = ls.snippet_node

local recursive_itemize
recursive_itemize = function ()
	return sn(
		nil,
		c(1, {
			t(""),
			sn(nil, { t({ "", "\t\\item " }), i(1), d(2, recursive_itemize, {}) }),
		})
	)
end

return{
	--------------
	-- PREAMBLE --
	--------------
	s("dclass", fmt(
		[[
		\documentclass{}{{{}}}
		{}
		]],
		{
			c(1, {
				t(""),
				fmt("[{}]", {i(1,"opts")}),
			}),
			i(2, "article"), i(0)
		}
	)),

	s("template", fmt(
		[[
		\documentclass{}{{{}}}

		{}

		\begin{{document}}
			{}
		\end{{document}}
		]],
		{
			c(1, {
				t(""),
				fmt("[{}]", {i(1,"opts")}),
			}),
			i(2, "article"), i(3), i(0)
		}
	)),

	s("nc", fmt(
		[[
		\newcommand{{{}}}[{}]{{{}}}{}
		]],
		{
			i(1,"cmdName"), i(2, "options"), i(3, "commands"), i(0)
		}
	)),

	s("up", fmt(
		[[
		\usepackage{}{{{}}}{}
		]],
		{
			c(1, {
				t(""),
				fmt("[{}]", {i(1,"opts")}),
			}),
			i(2,"package"),i(0)
		}
	)),

	-----------------
	-- ENVIRONMENT --
	-----------------
	s("beg", fmt(
		[[
		\begin{{{}}}
			{}
		\end{{{}}}
		]],
		{
			i(1), i(0), rep(1),
		}
	)),

	s("item", fmt(
		[[
		\begin{{itemize}}
			\item {}
			{}
		\end{{itemize}}
		]],
		{
			i(1), d(2, recursive_itemize, {}),
		}
	)),

	s("\\i", fmt(
		[[
		\item {}
		{}
		]],
		{i(1), i(0)}
	)),

	s("enum", fmt(
		[[
		\begin{{enumerate}}{}
			\item {}
			{}
		\end{{enumerate}}
		]],
		{
			c(1, {
				t(""),
				t("[a]"),
				t("[i]"),
				fmt("[{}]", {i(1,"opts")}),
			}),
			i(2), d(2, recursive_itemize, {}),
		}
	)),

	s("abs", fmt(
		[[
		\begin{{abstract}}
			{}
		\end{{abstract}}
		]],
		{
			i(0)
		}
	)),

	s("fig", fmt(
		[[
		\begin{{figure}}[{}]
			\centering
			\includegraphics[width={}]{}
			\caption{{{}}}
			\label{{fig:{}}}
		\end{{figure}}
		{}
		]],
		{
			i(1,"htpb"), i(2,"0.8\\textwidth"), i(3), i(4), rep(3), i{0}
		}
	)),

	----------
	-- MATH --
	----------
	s("frac", fmt(
		[[
		\frac{{{}}}{{{}}}{}
		]],
		{
			i(1),i(2),i(0)
		}
	)),

	----------
	-- TEXT --
	----------
	s("it", fmt(
		[[
		\textit{{{}}}{}
		]],
		{
			i(1),i(0)
		}
	)),

	s("bf", fmt(
		[[
		\textbf{{{}}}{}
		]],
		{
			i(1),i(0)
		}
	)),

	s("tt", fmt(
		[[
		\texttt{{{}}}{}
		]],
		{
			i(1),i(0)
		}
	)),

	s("sc", fmt(
		[[
		\textsc{{{}}}{}
		]],
		{
			i(1),i(0)
		}
	)),

	s("ul", fmt(
		[[
		\underline{{{}}}{}
		]],
		{
			i(1),i(0)
		}
	)),

}

