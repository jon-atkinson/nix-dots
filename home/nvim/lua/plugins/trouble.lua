return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
      use_diagnostic_signs = true,
      -- warn_no_results = true,
      modes = {
          lsp_references = {
              params = {
                  include_declaration = false,
                  include_current = true,
              },
          },
          -- -- This is the default behaviour:
          -- -- The LSP base mode for:
          -- -- * lsp_definitions, lsp_references, lsp_implementations
          -- -- * lsp_type_definitions, lsp_declarations, lsp_command
          -- lsp_base = {
          --     params = {
          --         -- don't include the current location in the results
          --         include_current = false,
          --     },
          -- },
      },
  },
}
