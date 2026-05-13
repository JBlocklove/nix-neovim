return{
	"snacks.nvim",
	for_cat = "general",
    auto_enable = true,
    lazy = false,
    priority = 1000,
    keys = {
    },
	after = function()
        -- vim.api.nvim_set_hl( 0, "MySnacksIndent", {fg = "#ff0000"} )
		require("snacks").setup ({
            -- Telescope replacements
            explorer = {
                enable = true,
                replace_netrw = true,
            },
            picker = {
                enable = true,
                sources = {
                    explorer = {
                        auto_close = true,
                    }
                }
            },

            -- Indentline guides
            indent = {
                enable = true,
                -- scope = {
                --     hl = "MySnacksIndent"
                -- },
                -- chunk = {
                --     hl = "MySnacksIndent"
                -- },
            },

            -- Status columns
            statuscolumn = {
                enable = true,
                left = { "git" },
                right = { "sign", "fold" },
                folds = {
                    open = false,
                    git_hl = false,
                },
                git = {
                    patterns = { "GitSign", "MiniDiffSign" },

                }
            },

            -- Notifications
            notifier = {
                enable = true,
            },
        })

        -- NOTE: we aren't loading this lazily, and the keybinds already are so it is fine to just set these here

        -- Files
        vim.keymap.set("n", "<leader>-", function() Snacks.picker.files() end, { desc = '[-] Find Files' })
        vim.keymap.set("n", "<leader>fh", function() Snacks.picker.files({ cwd = "~/" }) end, { desc = '[F]ind Files in [Home]' })
        vim.keymap.set('n', "<leader>sf", function() Snacks.picker.smart() end, { desc = "[S]mart Find [F]iles" })

        -- [/] Fuzzily Search in Current Buffer
        vim.keymap.set("n", "<leader>/", function()
            Snacks.picker.lines({
                layout = { preset = "ivy", preview = false },
            })
        end, { desc = "[/] Fuzzily Search in Current Buffer" })

        vim.keymap.set('n', "<leader>sb", function() Snacks.picker.lines() end, { desc = "[S]nacks [B]uffer Lines" })

        vim.keymap.set("n", "<leader>f/", function()
            Snacks.picker.grep({
                buffers = true,
                title = "Grep in Open Files",
            })
        end, { desc = "[F]ind [/] in Open Files" })
        vim.keymap.set("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "[F]ind Existing [B]uffers" })
        vim.keymap.set("n", "<leader>f.", function() Snacks.picker.recent() end, { desc = '[F]earch Recent Files ("." for repeat)' })
        vim.keymap.set("n", "<leader>fr", function() Snacks.picker.registers() end, { desc = "[F]ind [R]egisters" })
        vim.keymap.set("n", "<leader>fd", function() Snacks.picker.diagnostics() end, { desc = "[F]ind [D]iagnostics" })
        vim.keymap.set("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "[F]ind by [G]rep" })
        vim.keymap.set("n", "<leader>fw", function() Snacks.picker.grep_word() end, { desc = "[F]ind current [W]ord" })
        vim.keymap.set("n", "<leader>ff", function() Snacks.picker.pickers() end, { desc = "[F]ind Builtin Pickers" })
        vim.keymap.set("n", "<leader>fc", function() Snacks.picker.commands() end, { desc = "[F]ind [C]ommands" })
        vim.keymap.set("n", "<leader>fm", function() Snacks.picker.keymaps() end, { desc = "[F]ind Key[m]aps" })
        vim.keymap.set("n", "<leader>fq", function() Snacks.picker.qflist() end, { desc = "[F]ind in [Q]uickfix" })
        vim.keymap.set("n", "<leader>fs", function() Snacks.picker.spelling() end, { desc = "[F]ind [S]pelling" })
        vim.keymap.set('n', "<leader>fu", function() Snacks.picker.undo() end, { desc = "[F]ind [U]ndo History" })



        -- search
        vim.keymap.set('n', "<leader>sh", function() Snacks.picker.help() end, { desc = "[S]nacks [H]elp Pages" })

        -- vim.keymap.set('n', "<leader>sj", function() Snacks.picker.jumps() end, { desc = "Jumps" })
        -- vim.keymap.set('n', "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
        -- vim.keymap.set('n', "<leader>sl", function() Snacks.picker.loclist() end, { desc = "Location List" })
        -- vim.keymap.set('n', "<leader>sM", function() Snacks.picker.man() end, { desc = "Man Pages" })
        -- vim.keymap.set('n', "<leader>sq", function() Snacks.picker.qflist() end, { desc = "Quickfix List" })
        -- vim.keymap.set('n', "<leader>sR", function() Snacks.picker.resume() end, { desc = "Resume" })
        --
        vim.keymap.set('n', "<leader>q", function() Snacks.toggle.dim() end, { desc = "Snacks Toggle Dim" })
	end,
}

