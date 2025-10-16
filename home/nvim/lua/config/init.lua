require('config.options')
require('config.keymaps') -- key-maps must be before plugins so leader is set
require('config.lazy')
require('config.lsp')

function CleanWhitespace()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd('silent! %s/\\s\\+$//g')
    vim.api.nvim_win_set_cursor(0, pos) -- Restore cursor
end

local function _run_cmd(cmd, show_output)
    -- Run command and capture output
    local output = vim.fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 then
        table.insert(output, 1, "[Command failed with exit code " .. vim.v.shell_error .. "]")
        vim.notify("[Command failed with exit code " .. vim.v.shell_error .. "]", "error")
    end
end

local function run_cmd(cmd, show_output)
    -- Run command and capture output
    local output = vim.fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 then
        table.insert(output, 1, "[Command failed with exit code " .. vim.v.shell_error .. "]")
        vim.notify("[Command failed with exit code " .. vim.v.shell_error .. "]", "error")
    end
    if not show_output then
        return
    end
    -- Create scratch buffer for floating window
    local float_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, output)
    vim.api.nvim_buf_set_option(float_buf, 'filetype', 'text')
    vim.api.nvim_buf_set_option(float_buf, 'modifiable', false)

    -- Window dimensions
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.5)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Create floating window
    local float_win = vim.api.nvim_open_win(float_buf, false, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
    })

    -- Make the window scrollable and resizable
    vim.api.nvim_win_set_option(float_win, 'wrap', false)
    vim.api.nvim_win_set_option(float_win, 'cursorline', true)

    -- Optional: enter window temporarily, or just let user jump in with `<C-w>w`
    -- Add keybindings to close the window or make it more interactive
    vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(float_win, true)
    end, { buffer = float_buf, nowait = true })
end


local function save_run_cmd_reload(cmd, show_output)
    local buf = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(buf)
    if not file or file == '' then
        vim.notify("Buffer is not a file.", vim.log.levels.WARN)
        return
    end
    if vim.bo.modified then
        vim.cmd("write")
    end

    local mtime_before = vim.uv.fs_stat(file).mtime.sec

    run_cmd(cmd, show_output)

    -- Reload if file changed
    local mtime_after = vim.uv.fs_stat(file).mtime.sec
    if mtime_after > mtime_before then
        vim.cmd("edit")
    end
end

function ClangFormat()
    local buf = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(buf)
    save_run_cmd_reload("pipenv run make -j$(nproc) TARGET=mcu-hosted clang-format CLANG_FORMAT_FILES=".. file, false)
end

function LintMe()
    CleanWhitespace()
    ClangFormat()
    vim.notify("Linting complete.", "info")
end

vim.api.nvim_create_user_command("LintMe", LintMe, {})
vim.api.nvim_create_user_command("CleanWhitespace", CleanWhitespace, {})

vim.cmd("highlight TrailingWhitespace ctermbg=red guibg=#e62f2f")

-- Gipperty suggested toggle of lint checks 
-- 1. Create an augroup (will own your autocmds)
local lint_grp = vim.api.nvim_create_augroup("LintToggleGroup", { clear = true })

-- 2. Define a function to add your autocmds
local function add_autocmds()
    vim.api.nvim_create_autocmd({"BufWinEnter", "InsertLeave"}, {
        pattern = "*",
        group   = lint_grp,
        callback = function()
            vim.cmd("match TrailingWhitespace /\\s\\+$/")
        end,
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
        pattern = "*",
        group   = lint_grp,
        callback = function()
            vim.cmd("match TrailingWhitespace /\\s\\+\\%#\\@<!$/")
        end,
    })
end

-- 3. Track state and toggle
local enabled = false
local function toggle_my_ac()
  if enabled then
    vim.api.nvim_clear_autocmds({ group = lint_grp })
    print("→ autocmds disabled")
  else
    add_autocmds()
    print("→ autocmds enabled")
  end
  enabled = not enabled
end

-- 4. Expose a user command
vim.api.nvim_create_user_command("ToggleWhitespaceHighlight", toggle_my_ac, {})
-- Gipperty end
