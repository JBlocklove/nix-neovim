-- LSP buffer setup.

-- Everything LSP lives under <Space> as the leader
local L = "<Space>"

-- A lone <Space> should do nothing instead of moving the cursor right.
vim.keymap.set({ "n", "x" }, L, "<Nop>")

-- LSP belongs to <Space> here, so drop the defaults and give `gr` back to vim.
for _, m in ipairs({
    { "n", "grn" }, { "n", "gra" }, { "x", "gra" }, { "n", "grr" },
    { "n", "gri" }, { "n", "grt" }, { "n", "gO" },
}) do
    pcall(vim.keymap.del, m[1], m[2])
end

local pick = function(name)
    return function() Snacks.picker[name]() end
end

local lsp_keys = {
    { "rn", vim.lsp.buf.rename,                  "[R]e[n]ame" },
    { "ca", vim.lsp.buf.code_action,             "[C]ode [A]ction", { "n", "x" } },
    { "f",  function() vim.lsp.buf.format({ async = true }) end, "[F]ormat", { "n", "x" } },

    { "gd", pick("lsp_definitions"),             "[G]oto [D]efinition" },
    { "gD", pick("lsp_declarations"),            "[G]oto [D]eclaration" },
    { "gr", pick("lsp_references"),              "[G]oto [R]eferences" },
    { "gI", pick("lsp_implementations"),         "[G]oto [I]mplementation" },
    { "D",  pick("lsp_type_definitions"),        "Type [D]efinition" },

    { "ds", pick("lsp_symbols"),                 "[D]ocument [S]ymbols" },
    { "ws", pick("lsp_workspace_symbols"),       "[W]orkspace [S]ymbols" },

    { "sd", vim.lsp.buf.signature_help,          "[S]ignature [D]ocumentation" },

    { "wa", vim.lsp.buf.add_workspace_folder,    "[W]orkspace [A]dd Folder" },
    { "wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder" },
    { "wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "[W]orkspace [L]ist Folders" },
}

local function no_client()
    vim.notify("No LSP client attached to this buffer", vim.log.levels.WARN)
end
for _, k in ipairs(lsp_keys) do
    vim.keymap.set(k[4] or "n", L .. k[1], no_client, { desc = "LSP: " .. k[3] .. " (no client)" })
end

-- Diagnostics maps
vim.keymap.set("n", L .. "j", vim.diagnostic.open_float, { desc = "LSP: Show Line Diagnostics" })

vim.keymap.set("n", L .. "tv", function()
    local on = not vim.diagnostic.config().virtual_lines
    vim.diagnostic.config({ virtual_lines = on and { current_line = true } or false })
end, { desc = "LSP: [T]oggle Diagnostic [V]irtual Lines" })

-- LspAttach / LspDetach
local attach_group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true })
local hl_group = vim.api.nvim_create_augroup("user-lsp-highlight", { clear = true })
local lens_group = vim.api.nvim_create_augroup("user-lsp-codelens", { clear = true })

local function set_buffer_keys(bufnr)
    for _, k in ipairs(lsp_keys) do
        vim.keymap.set(k[4] or "n", L .. k[1], k[2], { buffer = bufnr, desc = "LSP: " .. k[3] })
    end

    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "LSP: Hover Documentation" })

    vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
        vim.lsp.buf.format()
    end, { desc = "Format current buffer with LSP" })
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = attach_group,
    callback = function(ev)
        local bufnr = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then return end

        -- LspAttach fires once per client; keymaps only need setting once.
        if not vim.b[bufnr].user_lsp_keys then
            vim.b[bufnr].user_lsp_keys = true
            set_buffer_keys(bufnr)
        end

        -- Highlight other references to the symbol under the cursor
        -- Driven by 'updatetime' (CursorHold).
        if client:supports_method("textDocument/documentHighlight", bufnr) then
            vim.api.nvim_clear_autocmds({ group = hl_group, buffer = bufnr })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                group = hl_group, buffer = bufnr, callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
                group = hl_group, buffer = bufnr, callback = vim.lsp.buf.clear_references,
            })
        end

        -- Inlay hints: off by default, toggle per buffer
        if client:supports_method("textDocument/inlayHint", bufnr) then
            vim.keymap.set("n", L .. "th", function()
                local on = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
                vim.lsp.inlay_hint.enable(not on, { bufnr = bufnr })
            end, { buffer = bufnr, desc = "LSP: [T]oggle Inlay [H]ints" })
        end

        -- Code lenses (slang-server exposes its HDL actions through these)
        if client:supports_method("textDocument/codeLens", bufnr) then
            if vim.lsp.codelens.enable then
                -- Neovim 0.12+: core keeps lenses refreshed
                vim.lsp.codelens.enable(true, { bufnr = bufnr })
            else
                vim.api.nvim_clear_autocmds({ group = lens_group, buffer = bufnr })
                vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                    group = lens_group,
                    buffer = bufnr,
                    callback = function() vim.lsp.codelens.refresh({ bufnr = bufnr }) end,
                })
                vim.lsp.codelens.refresh({ bufnr = bufnr })
            end
            vim.keymap.set("n", L .. "cl", vim.lsp.codelens.run,
                { buffer = bufnr, desc = "LSP: [C]ode [L]ens Run" })
        end
    end,
})

vim.api.nvim_create_autocmd("LspDetach", {
    group = attach_group,
    callback = function(ev)
        -- Only tear down highlighting if no remaining client provides it.
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
            if c.id ~= ev.data.client_id
                and c:supports_method("textDocument/documentHighlight", ev.buf) then
                return
            end
        end
        vim.lsp.util.buf_clear_references(ev.buf)
        vim.api.nvim_clear_autocmds({ group = hl_group, buffer = ev.buf })
    end,
})
