local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local extras = require("luasnip.extras")
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node

-- Helper function to replicate SnipMate's ${VISUAL} behavior
local get_visual = function(args, parent)
    if (#parent.snippet.env.LS_SELECT_RAW > 0) then
        return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
    else
        return sn(nil, i(1, ""))
    end
end

return{

    -- AUTO SNIPPETS
	s({trig = "dt", snippetType = "autosnippet"}, {
		t("downto")
	}),

	s({trig = "sl", snippetType = "autosnippet"}, {
		t("std_logic")
	}),

	s({trig = "slv", snippetType = "autosnippet"}, {
		t("std_logic_vector")
	}),


    -- SNIPPETS
    s("header", fmt(
        [[
        -------------------------------------------------
        --  File:          {}
        --
        --  Entity:        {}
        --  Architecture:  {}
        --  Author:        {}
        --  Created:       {}
        --  Modified:      {}
        --  VHDL'08
        --  Description:   The following is the entity and
        --                 architectural description of a
        --                 {}
        -------------------------------------------------
        {}
        ]],
        {
        f(function() return vim.fn.expand("%:t") end),
        d(1, function()
            local filename = vim.fn.expand("%:t:r")
            return sn(nil, { i(1, filename == "" and "entity_name" or filename) })
        end),
        i(2, "behavioral"),
        i(3, os.getenv("USER") or os.getenv("USERNAME") or "Author"),
        f(function() return os.date("%Y-%m-%d %H:%M:%S") end),
        f(function() return os.date("%Y-%m-%d %H:%M:%S") end),
        i(4, "The following is the entity and architectural description..."),
        i(0)
        }
    )),

	s("lib", fmt(
		[[
        library ieee;
        use ieee.std_logic_1164.all;
        {}
		]],
		{
			i(0),
		}
	)),

    s("uun", fmt(
        [[
        use ieee.std_logic_unsigned.all;
        {}
        ]],
        {
            i(0)
        }
    )),

    s("num", fmt(
        [[
        use ieee.numeric_std.all;
        {}
        ]],
        {
            i(0)
        }
    )),

    s("ent", fmt(
        [[
        entity {{{}}} is
            port (
            );
        end{{{}}};

        architecture {} of {} is
        begins
        {}
        end {};
        ]],
        {
            i(1), rep(1), i(2), rep(1), rep(2), i(0)
        }
    )),

    s("genent", fmt(
        [[
        entity {{{}}} is
            generic(

            );
            port (

            );
        end{{{}}};

        architecture {} of {} is
        begins
        {}
        end {};
        ]],
        {
            i(1), rep(1), i(2), rep(1), rep(2), i(0)
        }
    )),

    -- "with ... select"
    s("with", fmt(
        [[
        with {} select
            {} <=
        ]],
        {
            i(1),
            i(2)
        }
    )),

    -- "component"
    s("comp", fmt(
        [[
        component {}
            Port(
            );
        end component;
        ]],
        {
            d(1, get_visual)
        }
    )),

    -- "...: ... port map(...);"
    s("pm", fmt(
        [[
        {}: {} port map({});
        ]],
        {
            i(1),
            i(2),
            i(3)
        }
    )),

    -- "type ... is (...);"
    s("type", fmt(
        [[
        type {} is ({});
        ]],
        {
            i(1),
            i(2)
        }
    )),

    -- "... : process (...) ..."
    s("proc", fmt(
        [[
        {} : process ({}) begin
        {}
        end process;
        ]],
        {
            i(1),
            i(2, "clk"),
            i(0)
        }
    )),

    -- "if rising_edge(clk) then ..."
    s("ifup", fmt(
        [[
        if rising_edge({}) then
            {}
        end if;
        ]],
        {
            i(1, "clk"),
            d(2, get_visual)
        }
    )),

    -- "elsif rising_edge(clk) then ..."
    s("elsup", fmt(
        [[
        elsif rising_edge({}) then
            {}
        end if;
        ]],
        {
            i(1, "clk"),
            d(2, get_visual)
        }
    )),

    -- "case ... is ..."
    s("case", fmt(
        [[
        case {} is
            when others => '0';
        end case;
        ]],
        {
            d(1, get_visual)
        }
    )),

    -- "clk_proc : process ..."
    s("clkproc", fmt(
        [[
        {}:process
        begin
            clk <= '1';
            wait for {};
            clk <= '0';
            wait for {};
        end process;
        {}
        ]],
        {
            i(1, "clk_proc"),
            i(2, "50 ns"),
            rep(2), -- Replicates the behavior of repeating $2 from your original snippet
            i(0)
        }
    )),

    -- "assert ... report ... severity ...;"
    s("assert", fmt(
        [[
        assert {}
            report {}
            severity {};
        ]],
        {
            i(1, "condition"),
            i(2, '"string"'),
            i(3, "error")
        }
    )),

    -- "report Testbench Concluded severity failure;"
    s("end", fmt(
        [[
        report "Testbench Concluded" severity failure;
        ]],
        {}
    )),

}

