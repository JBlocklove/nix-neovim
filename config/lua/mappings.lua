vim.g.mapleader = '\\'
vim.g.maplocalleader = '\\'

-- Enforce purity
vim.keymap.set("i", "<Up>", "<Nop>")
vim.keymap.set("i", "<Down>", "<Nop>")
vim.keymap.set("i", "<Left>", "<Nop>")
vim.keymap.set("i", "<Right>", "<Nop>")
vim.keymap.set("n", "<Up>", "<Nop>")
vim.keymap.set("n", "<Down>", "<Nop>")
vim.keymap.set("n", "<Left>", "<Nop>")
vim.keymap.set("n", "<Right>", "<Nop>")

-- Splitting
vim.keymap.set("n", "<leader>v", ":vsplit<CR>")
vim.keymap.set("n", "<leader>h", ":split<CR>")

-- Clear highlights
-- vim.keymap.set("n", "<leader>q", ":noh<CR>")
vim.keymap.set('',  '<Esc>', "<ESC>:noh<CR>", {silent = true})

-- Better searching
vim.keymap.set("n", "/", "/\\v")
vim.keymap.set("v", "/", "/\\v")

-- Move lines in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Diffs
vim.keymap.set("v", "<leader>dg", ":'<,'>diffget<CR>")
vim.keymap.set("v", "<leader>dp", ":'<,'>diffput<CR>")

-- Native neovim commenting
vim.keymap.set("n", "<leader>c", "gcc", {
    remap = true,
    silent = true,
    desc = "Toggle line comment"
})
vim.keymap.set("v", "<leader>c", "gc", {
    remap = true,
    silent = true,
    desc = "Toggle multiline comment"
})
