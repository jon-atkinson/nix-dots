local options = {
    backup = false,
    colorcolumn = "100",
    cursorline = true,
    expandtab = true,
    hlsearch = false,
    ignorecase = true,
    list = true,
    listchars = {
        tab = "▸-",
        trail = ".",
        extends = "❯",
        precedes = "❮",
        nbsp = "␣",
    },
    modeline = false,
    mouse = 'a',
    number = true,
    numberwidth = 2,
    pumheight = 10, -- Max pop-up menu height
    relativenumber = true,
    scrolloff = 8,
    shiftwidth = 4,
    showbreak="↪",
    showtabline = 2, -- 2= always show tab line
    sidescrolloff = 4, -- Only applied when wrap off
    signcolumn = "yes",
    smartcase = true,
    smartindent = true,
    spelllang = "en_au",
    spellsuggest = "best,10",
    splitright = true,
    splitbelow = true,
    softtabstop = 4,
    swapfile = false,
    tabstop = 4,
    termguicolors = true,
    timeoutlen = 400,
    undofile = true,
    undodir = os.getenv("HOME") .. "/.local/share/nvim/undodir",
    updatetime = 100, -- gitgutter responsiveness
    visualbell = true,
    wrap = true,
    writebackup = false,
}

for k, v in pairs(options) do
    vim.opt[k] = v
end

vim.opt.shortmess:append "c"
vim.opt.iskeyword:append "-"

