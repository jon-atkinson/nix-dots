require("trouble")
local opts = { silent = true, noremap = true }
local kmap = vim.keymap.set

kmap("n", "<leader>x", "<cmd>Trouble close<cr>", opts)
-- kmap("n", "<leader>xd", "<cmd>Trouble document_diagnostics<cr>", opts)
kmap("n", "<F5>", "<cmd>Trouble diagnostics toggle<cr>", opts)
-- kmap("n", "<leader>xq", "<cmd>Trouble quickfix toggle<cr>", opts)
-- kmap("n", "<leader>xl", "<cmd>Trouble loclist<cr>", opts)
kmap("n", "gr", "<cmd>Trouble lsp_references focus=true<cr>", opts)
kmap("n", "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", opts)

