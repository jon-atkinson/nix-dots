local cmp = require("cmp")
local cmp_select = {}

cmp.setup({
	sources = {
		{ name = "nvim_lsp" },
	},
	snippet = {
		expand = function(args)
			-- You need Neovim v0.10 to use vim.snippet
			vim.snippet.expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<C-y>"] = cmp.config.disable,
		["<Tab>"] = cmp.mapping.select_next_item(cmp_select),
		["<S-Tab>"] = cmp.mapping.select_prev_item(cmp_select),
		["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
})

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
	sources = cmp.config.sources({
		{ name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
	}, {
		{ name = "buffer" },
	}),
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", { buffer = args.buf })
		vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", { buffer = args.buf })
		vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", { buffer = args.buf })
		vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", { buffer = args.buf })
		vim.keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", { buffer = args.buf })
		-- vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', { buffer = args.buf })
		vim.keymap.set({ "n", "i" }, "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", { buffer = args.buf })
		vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", { buffer = args.buf })
		vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", { buffer = args.buf })
		vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", { buffer = args.buf })
		vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", { buffer = args.buf })
		vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", { buffer = args.buf })
	end,
})

-- diagnostic popups open
vim.diagnostic.config({ jump = { float = true } })

vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, { focusable = false })
	end,
})

-- clangd for C / C++
-- <install instructions>
vim.lsp.config("clangd", {
	cmd = {
		"clangd",
		-- "--log=verbose",
		"--background-index",
		"--query-driver=/opt/morse/gcc-arm-none-eabi-10.3-2021.07/bin/arm-none-eabi-gcc",
	},
})
vim.lsp.enable("clangd")

-- basedpyright for Python
-- pip install basedpyright
vim.lsp.config("basedpyright", {
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "basic", -- not too strict

				diagnosticSeverityOverrides = {
					-- silence low-value noise
					-- reportUnusedImport = "none",
					-- reportUnusedVariable = "none",
					-- reportUnusedFunction = "none",
					-- reportUnusedClass = "none",
					reportMissingTypeStubs = "none",
					reportInvalidTypeForm = "none", -- quiet for things like TypeAlias syntax

					-- downgrade optional-type stuff to warnings
					reportOptionalMemberAccess = "warning",
					reportOptionalSubscript = "warning",
					reportOptionalCall = "warning",

					-- keep important ones as errors
					reportGeneralTypeIssues = "error",
					reportUndefinedVariable = "error",
					reportMissingImports = "error",
				},
			},
		},
	},
})
vim.lsp.enable("basedpyright")

-- bashls for shell
-- sudo snap install bash-language-server --classic
vim.lsp.enable("bashls")

-- lua-language-server for lua
-- < Installed from github >
vim.lsp.enable("lua_ls")

-- Optional: inlay-hints toggle
vim.keymap.set("n", "<leader>li", function()
	local b = vim.api.nvim_get_current_buf()
	local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = b })
	vim.lsp.inlay_hint.enable(not enabled, { bufnr = b })
end, { desc = "Toggle Inlay Hints" })

vim.opt.completeopt = { "menu", "menuone", "noselect" }
