local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local extras = require("luasnip.extras")
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt
local c = ls.choice_node
local d = ls.dynamic_node
local f = ls.function_node
local sn = ls.snippet_node

-------------
-- HELPERS --
-------------

-- recursive \item: choose branch 2 to add another item, branch 1 to stop
local rec_item
rec_item = function()
	return sn(
		nil,
		c(1, {
			t(""),
			sn(nil, { t({ "", "\t\\item " }), i(1), d(2, rec_item, {}) }),
		})
	)
end

-- turn "figures/plot-v2.pdf" into an editable default label "plot-v2"
local function label_from_path(args)
	local path = args[1][1] or ""
	local base = path:match("([^/\\]+)$") or path
	base = base:gsub("%.%w+$", ""):gsub("[^%w%-]+", "-"):gsub("^%-+", ""):gsub("%-+$", "")
	return sn(nil, { i(1, base) })
end

-- \left( ... \right) -- picks the closing delimiter from the opening one
local closing = {
	["("] = ")",
	["["] = "]",
	["\\{"] = "\\}",
	["|"] = "|",
	["\\|"] = "\\|",
	["\\langle"] = "\\rangle",
	["\\lceil"] = "\\rceil",
	["\\lfloor"] = "\\rfloor",
}

local function close_delim(args)
	return closing[args[1][1]] or "."
end

-- math-only snippets. Falls back to "always on" when vimtex isn't loaded.
local function in_math()
	if vim.fn.exists("*vimtex#syntax#in_mathzone") == 0 then
		return true
	end
	return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

local function in_text()
	if vim.fn.exists("*vimtex#syntax#in_mathzone") == 0 then
		return true
	end
	return vim.fn["vimtex#syntax#in_mathzone"]() == 0
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
				sn(nil, fmt("[{}]", { i(1, "opts") })),
			}),
			i(2, "article"), i(0)
		}
	)),

	s("template", fmt(
		[[
		\documentclass{}{{{}}}

		\usepackage[utf8]{{inputenc}}
		\usepackage[T1]{{fontenc}}
		\usepackage{{amsmath, amssymb}}
		\usepackage{{graphicx}}
		\usepackage[colorlinks=true, allcolors=blue]{{hyperref}}
		{}

		\title{{{}}}
		\author{{{}}}
		\date{{{}}}

		\begin{{document}}
			\maketitle

			{}
		\end{{document}}
		]],
		{
			c(1, {
				t(""),
				sn(nil, fmt("[{}]", { i(1, "opts") })),
			}),
			i(2, "article"), i(3), i(4, "Title"), i(5, "Author"),
			c(6, {
				t("\\today"),
				sn(nil, { i(1) }),
				t(""),
			}),
			i(0)
		}
	)),

	s("up", fmt(
		[[
		\usepackage{}{{{}}}{}
		]],
		{
			c(1, {
				t(""),
				sn(nil, fmt("[{}]", { i(1, "opts") })),
			}),
			i(2,"package"),i(0)
		}
	)),

	s("nc", fmt(
		[[
		\newcommand{{{}}}{}{{{}}}{}
		]],
		{
			i(1,"\\cmdname"),
			c(2, {
				t(""),
				sn(nil, fmt("[{}]", { i(1, "1") })),
			}),
			i(3, "definition"), i(0)
		}
	)),

	s("nenv", fmt(
		[[
		\newenvironment{{{}}}
			{{{}}}
			{{{}}}
		{}
		]],
		{
			i(1,"envname"), i(2,"begin code"), i(3,"end code"), i(0)
		}
	)),

	s("dmo", fmt(
		[[
		\DeclareMathOperator{}{{{}}}{{{}}}{}
		]],
		{
			c(1, { t(""), t("*") }),
			i(2,"\\argmax"), i(3,"arg\\,max"), i(0)
		}
	)),

	s("title", fmt(
		[[
		\title{{{}}}
		\author{{{}}}
		\date{{{}}}
		\maketitle
		{}
		]],
		{
			i(1), i(2),
			c(3, {
				t("\\today"),
				sn(nil, { i(1) }),
				t(""),
			}),
			i(0)
		}
	)),

	s("bib", fmt(
		[[
		\bibliographystyle{{{}}}
		\bibliography{{{}}}
		{}
		]],
		{
			i(1,"plain"), i(2,"references"), i(0)
		}
	)),

	---------------
	-- STRUCTURE --
	---------------
	s("sec", fmt(
		[[
		\section{}{{{}}}
		{}
		]],
		{
			c(1, { t(""), t("*") }), i(2), i(0)
		}
	)),

	s("ssec", fmt(
		[[
		\subsection{}{{{}}}
		{}
		]],
		{
			c(1, { t(""), t("*") }), i(2), i(0)
		}
	)),

	s("sssec", fmt(
		[[
		\subsubsection{}{{{}}}
		{}
		]],
		{
			c(1, { t(""), t("*") }), i(2), i(0)
		}
	)),

	s("chap", fmt(
		[[
		\chapter{}{{{}}}
		{}
		]],
		{
			c(1, { t(""), t("*") }), i(2), i(0)
		}
	)),

	s("toc", fmt(
		[[
		\tableofcontents
		{}
		]],
		{
			i(0)
		}
	)),

	s("label", fmt(
		[[\label{{{}:{}}}{}]],
		{
			c(1, { t("sec"), t("fig"), t("tab"), t("eq"), t("thm"), t("app") }),
			i(2), i(0)
		}
	)),

	-- \ref \cref \eqref \autoref \pageref
	s("ref", fmt(
		[[\{}ref{{{}}}{}]],
		{
			c(1, { t(""), t("c"), t("eq"), t("auto"), t("page") }),
			i(2), i(0)
		}
	)),

	s("cite", fmt(
		[[\cite{}{{{}}}{}]],
		{
			c(1, {
				t(""),
				sn(nil, fmt("[{}]", { i(1, "p.~1") })),
			}),
			i(2), i(0)
		}
	)),

	s("fn", fmt(
		[[\footnote{{{}}}{}]],
		{
			i(1), i(0)
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
			\item {}{}
		\end{{itemize}}
		{}
		]],
		{
			i(1), d(2, rec_item, {}), i(0),
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
			\item {}{}
		\end{{enumerate}}
		{}
		]],
		{
			c(1, {
				t(""),
				t("[label=\\alph*)]"),
				t("[label=\\roman*.]"),
				sn(nil, fmt("[{}]", { i(1, "opts") })),
			}),
			i(2), d(3, rec_item, {}), i(0),
		}
	)),

	s("desc", fmt(
		[[
		\begin{{description}}
			\item[{}] {}
		\end{{description}}
		{}
		]],
		{
			i(1), i(2), i(0),
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
			\includegraphics[width={}]{{{}}}
			\caption{{{}}}
			\label{{fig:{}}}
		\end{{figure}}
		{}
		]],
		{
			i(1,"htbp"), i(2,"0.8\\textwidth"), i(3,"path/to/image"),
			i(4,"Caption"), d(5, label_from_path, {3}), i(0)
		}
	)),

	-- needs \usepackage{booktabs}
	s("tab", fmt(
		[[
		\begin{{table}}[{}]
			\centering
			\begin{{tabular}}{{{}}}
				\toprule
				{} \\
				\midrule
				{} \\
				\bottomrule
			\end{{tabular}}
			\caption{{{}}}
			\label{{tab:{}}}
		\end{{table}}
		{}
		]],
		{
			i(1,"htbp"), i(2,"lcr"), i(3,"a & b & c"), i(4,"1 & 2 & 3"),
			i(5,"Caption"), i(6,"label"), i(0)
		}
	)),

	-- needs \usepackage{amsthm}
	s("thm", fmt(
		[[
		\begin{{{}}}{}
			{}
		\end{{{}}}
		{}
		]],
		{
			c(1, {
				t("theorem"), t("lemma"), t("corollary"),
				t("proposition"), t("definition"), t("remark"), t("example"),
			}),
			c(2, {
				t(""),
				sn(nil, fmt("[{}]", { i(1, "name") })),
			}),
			i(3), rep(1), i(0),
		}
	)),

	s("proof", fmt(
		[[
		\begin{{proof}}
			{}
		\end{{proof}}
		{}
		]],
		{
			i(1), i(0)
		}
	)),

	s("verb", fmt(
		[[
		\begin{{verbatim}}
		{}
		\end{{verbatim}}
		{}
		]],
		{
			i(1), i(0)
		}
	)),

	s("lst", fmt(
		[[
		\begin{{lstlisting}}[language={}, caption={{{}}}]
		{}
		\end{{lstlisting}}
		{}
		]],
		{
			i(1,"Verilog"), i(2,"Caption"), i(3), i(0)
		}
	)),

	----------
	-- MATH --
	----------
	s({ trig = "mk", condition = in_text }, fmt(
		[[${}${}]],
		{
			i(1), i(0)
		}
	)),

	s({ trig = "dm", condition = in_text }, fmt(
		[[
		\[
			{}
		\]
		{}
		]],
		{
			i(1), i(0)
		}
	)),

	s("eq", fmt(
		[[
		\begin{{equation{}}}
			{}
		\end{{equation{}}}
		{}
		]],
		{
			c(1, { t(""), t("*") }), i(2), rep(1), i(0)
		}
	)),

	s("align", fmt(
		[[
		\begin{{align{}}}
			{} &= {} \\
			{}
		\end{{align{}}}
		{}
		]],
		{
			c(1, { t("*"), t("") }), i(2), i(3), i(4), rep(1), i(0)
		}
	)),

	s({ trig = "cases", condition = in_math }, fmt(
		[[
		\begin{{cases}}
			{} & \text{{if }} {} \\
			{} & \text{{otherwise}}
		\end{{cases}}
		{}
		]],
		{
			i(1), i(2), i(3), i(0)
		}
	)),

	-- bmatrix / pmatrix / vmatrix / Vmatrix / matrix
	s({ trig = "mat", condition = in_math }, fmt(
		[[
		\begin{{{}matrix}}
			{} & {} \\
			{} & {}
		\end{{{}matrix}}
		{}
		]],
		{
			c(1, { t("b"), t("p"), t("v"), t("V"), t("") }),
			i(2), i(3), i(4), i(5), rep(1), i(0)
		}
	)),

	s({ trig = "frac", condition = in_math }, fmt(
		[[
		\frac{{{}}}{{{}}}{}
		]],
		{
			i(1),i(2),i(0)
		}
	)),

	s({ trig = "sum", condition = in_math }, fmt(
		[[\sum_{{{}}}^{{{}}} {}]],
		{
			i(1,"i=1"), i(2,"n"), i(0)
		}
	)),

	s({ trig = "prod", condition = in_math }, fmt(
		[[\prod_{{{}}}^{{{}}} {}]],
		{
			i(1,"i=1"), i(2,"n"), i(0)
		}
	)),

	s({ trig = "int", condition = in_math }, fmt(
		[[\int_{{{}}}^{{{}}} {} \, \mathrm{{d}}{}]],
		{
			i(1,"0"), i(2,"\\infty"), i(3), i(0,"x")
		}
	)),

	s({ trig = "lim", condition = in_math }, fmt(
		[[\lim_{{{} \to {}}} {}]],
		{
			i(1,"n"), i(2,"\\infty"), i(0)
		}
	)),

	s({ trig = "sqrt", condition = in_math }, fmt(
		[[\sqrt{}{{{}}}{}]],
		{
			c(1, {
				t(""),
				sn(nil, fmt("[{}]", { i(1, "n") })),
			}),
			i(2), i(0)
		}
	)),

	s({ trig = "binom", condition = in_math }, fmt(
		[[\binom{{{}}}{{{}}}{}]],
		{
			i(1,"n"), i(2,"k"), i(0)
		}
	)),

	-- \left( ... \right) with the closing delimiter chosen automatically
	s({ trig = "lr", condition = in_math }, fmt(
		[[\left{}{}\right{}{}]],
		{
			c(1, {
				t("("), t("["), t("\\{"), t("|"),
				t("\\langle"), t("\\lceil"), t("\\lfloor"),
			}),
			i(2),
			f(close_delim, { 1 }),
			i(0)
		}
	)),

	-- \mathbb \mathcal \mathbf \mathrm \mathfrak \mathsf
	s({ trig = "mf", condition = in_math }, fmt(
		[[\math{}{{{}}}{}]],
		{
			c(1, { t("bb"), t("cal"), t("bf"), t("rm"), t("frak"), t("sf") }),
			i(2), i(0)
		}
	)),

	-- \hat \bar \vec \tilde \dot \widehat \overline
	s({ trig = "acc", condition = in_math }, fmt(
		[[\{}{{{}}}{}]],
		{
			c(1, {
				t("hat"), t("bar"), t("vec"), t("tilde"),
				t("dot"), t("widehat"), t("overline"),
			}),
			i(2), i(0)
		}
	)),

	s({ trig = "txt", condition = in_math }, fmt(
		[[\text{{{}}}{}]],
		{
			i(1), i(0)
		}
	)),

	s({ trig = "dd", condition = in_math }, fmt(
		[[\frac{{\mathrm{{d}}{}}}{{\mathrm{{d}}{}}}{}]],
		{
			i(1,"y"), i(2,"x"), i(0)
		}
	)),

	s({ trig = "pd", condition = in_math }, fmt(
		[[\frac{{\partial {}}}{{\partial {}}}{}]],
		{
			i(1,"f"), i(2,"x"), i(0)
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

	s("em", fmt(
		[[
		\emph{{{}}}{}
		]],
		{
			i(1),i(0)
		}
	)),

	s("href", fmt(
		[[\href{{{}}}{{{}}}{}]],
		{
			i(1,"https://"), i(2,"text"), i(0)
		}
	)),

	s("url", fmt(
		[[\url{{{}}}{}]],
		{
			i(1,"https://"), i(0)
		}
	)),

}
