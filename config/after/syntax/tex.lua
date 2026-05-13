-- Don't conceal spacing commands
vim.cmd([[syntax match texUnconcealedSpace "\\vspace" display]])
vim.cmd([[syntax match texUnconcealedSpace "\\hspace" display]])
vim.cmd([[highlight def link texUnconcealedSpace texCmd]])
