local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Alias method
local keymap = vim.keymap.set

keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap("n", "<leader>e", ":Lex 30<cr>", opts)

keymap("n", "<leader>hh", "<C-w>h", opts)
keymap("n", "<leader>jj", "<C-w>j", opts)
keymap("n", "<leader>kk", "<C-w>k", opts)
keymap("n", "<leader>ll", "<C-w>l", opts)
keymap("n", "<leader>w", "<C-w>w", opts)

-- keymap("n", "<leader>t", ":tab", {silent = false})
keymap("n", "<leader>tt", ":tabnew ", {silent = false})
keymap("n", "<leader>tn", ":tabnext <CR>", opts)
keymap("n", "<leader>tp", ":tabnext -<CR>", opts)

keymap("n", "<leader>q", ":q<CR>", opts)
keymap("n", "<leader>c", ":ccl<CR>", opts)
keymap("n", "<leader>h", ":set hls!<CR>", opts)

-- keymap("n", "<C-Up>", ":resize -2<CR>", opts)
-- keymap("n", "<C-Down>", ":resize +2<CR>", opts)
-- keymap("n", "<C-Left>", ":vertical resize +2<CR>", opts)
-- keymap("n", "<C-Right>", ":vertical resize -2<CR>", opts)

-- -- Primeagan
-- keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
-- keymap("v", "K", ":m '<-2<CR>gv=gv", opts)
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

keymap({"n", "v"}, "<leader>y", [["+y]], opts)
keymap("n", "<leader>Y", [["+Y]], opts)
keymap({"n", "v"}, "<leader>d", [["_d]])
keymap("n", "Q", "<nop>")
-- <leader>p gives old p behaviour
keymap("x", "<leader>p", "p", opts)
keymap("x", "p", [["_dP]], opts)

-- Delete in /* */ multi-line comment
-- Limitations: if /* found but forwards */ not found cursor position changes
--   and error displayed
-- TODO: convert to function that handles limitations
keymap("n", "dic", "?\\/\\*?e+<CR>d/\\*\\//e<CR>A  */<Esc>hh", opts)
keymap("n", "dac", "?\\/\\*<CR>d/\\*\\//e<CR>", opts)

keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

keymap("c", "w!!", "SudaWrite", opts)
