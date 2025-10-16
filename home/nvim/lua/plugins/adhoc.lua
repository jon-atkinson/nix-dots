return {
    {
        "ellisonleao/gruvbox.nvim", priority = 1000 , config = true,
        opts = function()
            local palette = require'gruvbox'.palette
            return {
                italic = {
                    strings = false,
                },
                overrides = {
                    Todo = { bg = palette.dark3, },
                    -- StatusLine = { bg = palette.dark3, },
                    ["@variable"] = { fg = palette.bright_blue, },
                    ["@parameter"] = { fg = palette.neutral_aqua, },
                }
            }
        end,
    },
    'Yggdroot/indentLine',
    {
        'tpope/vim-commentary',
        config = function()
            vim.cmd [[ autocmd FileType c,cpp setlocal commentstring=//\ %s ]]
        end,
    },
    'lambdalisue/suda.vim',
    "mbbill/undotree",
    "tpope/vim-fugitive", -- alternatives?
    -- 'm4xshen/autoclose.nvim', -- experimenting
    'rcarriga/nvim-notify',
    {
        "airblade/vim-gitgutter",
        event = { "BufReadPre", "BufNewFile" },
        init = function()
            -- Signs
            vim.g.gitgutter_sign_added = "▎"
            vim.g.gitgutter_sign_modified = "▎"
            vim.g.gitgutter_sign_removed = "▁"

            -- Keymaps - these are the defaults
            -- vim.keymap.set("n", "]c", "<Plug>(GitGutterNextHunk)", { desc = "Next Git hunk" })
            -- vim.keymap.set("n", "[c", "<Plug>(GitGutterPrevHunk)", { desc = "Previous Git hunk" })
            -- vim.keymap.set("n", "<leader>hs", ":GitGutterStageHunk<CR>", { desc = "Stage hunk" })
            -- vim.keymap.set("n", "<leader>hu", ":GitGutterUndoHunk<CR>", { desc = "Undo hunk" })
            -- vim.keymap.set("n", "<leader>hp", ":GitGutterPreviewHunk<CR>", { desc = "Preview hunk" })
            -- vim.keymap.set("n", "<leader>ht", ":GitGutterToggle<CR>", { desc = "Toggle GitGutter" })
        end,
    },
}
