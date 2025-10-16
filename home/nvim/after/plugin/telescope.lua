require('telescope').load_extension('fzf')

local builtin = require('telescope.builtin')

my_find_files = function(opts, no_ignore)
  opts = opts or {}
  no_ignore = vim.F.if_nil(no_ignore, false)
  opts.attach_mappings = function(_, map)
    map({ "n", "i" }, "<C-h>", function(prompt_bufnr)
      local prompt = require("telescope.actions.state").get_current_line()
      require("telescope.actions").close(prompt_bufnr)
      my_find_files({ default_text = prompt }, not no_ignore)
    end)
    return true
  end

  if no_ignore then
    opts.no_ignore = true
    opts.hidden = true
    opts.prompt_title = "Find Files <ALL>"
  else
    opts.prompt_title = "Find Files <Git>"
  end
  builtin.find_files(opts)
end

local opts = { noremap = true }

vim.api.nvim_create_user_command("MyFindFiles", my_find_files, {})
vim.keymap.set("n", "<leader>f", my_find_files)
-- vim.keymap.set('n', '<leader>f', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
vim.keymap.set('n', '<leader>rgg', builtin.grep_string, {})
vim.keymap.set('n', '<leader>rg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>o', function() builtin.jumplist({ show_line = false }) end)
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, opts)
-- vim.keymap.set('n', '<leader>vp', builtin.help_tags, {})

-- visual mode: grep for the selected text
vim.keymap.set("v", "<leader>rgg", function()
  -- yank selection into "v" register without overwriting default
  local save_reg = vim.fn.getreg('v')
  vim.cmd('normal! "vy')  -- yank visual selection into v
  local text = vim.fn.getreg('v')
  vim.fn.setreg('v', save_reg)

  builtin.grep_string({ search = text })
end, { desc = "Grep for selection" })
