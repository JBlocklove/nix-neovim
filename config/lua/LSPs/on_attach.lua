return function(_, bufnr)
	-- we create a function that lets us more easily define mappings specific
	-- for LSP related items. It sets the mode, buffer and description for us each time.

	local nmap = function(keys, func, desc)
		if desc then
			desc = 'LSP: ' .. desc
		end

		vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
	end

	nmap('<Space>rn', vim.lsp.buf.rename, '[R]e[n]ame')
	nmap('<Space>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

	nmap('<Space>gd', vim.lsp.buf.definition, '[G]oto [D]efinition')

    if nixInfo(false, "settings", "cats", "telescope") then
		nmap('<Space>gr', function() require('telescope.builtin').lsp_references() end, '[G]oto [R]eferences')
		nmap('<Space>gI', function() require('telescope.builtin').lsp_implementations() end, '[G]oto [I]mplementation')
		nmap('<Space>ds', function() require('telescope.builtin').lsp_document_symbols() end, '[D]ocument [S]ymbols')
		nmap('<Space>ws', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, '[W]orkspace [S]ymbols')
	end 

	nmap('<Space>D', vim.lsp.buf.type_definition, 'Type [D]efinition')

	-- See `:help K` for why this keymap
	nmap('<Space>k', function() vim.lsp.buf.hover { border = "single" } end, 'Hover Documentation')
	nmap('<Space>j', vim.diagnostic.open_float, 'Show Line Diagnostics')
	nmap('<Space>sd', vim.lsp.buf.signature_help, 'Signature Documentation')

	-- Lesser used LSP functionality
	nmap('<Space>gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
	nmap('<Space>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
	nmap('<Space>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
	nmap('<Space>wl', function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, '[W]orkspace [L]ist Folders')

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
		vim.lsp.buf.format()
	end, { desc = 'Format current buffer with LSP' })

    -- FIXME: Force diagnostic initialization on attach (needed for lua maybe)
    vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
            vim.diagnostic.enable(true, { bufnr = bufnr })
        end
    end)

end

