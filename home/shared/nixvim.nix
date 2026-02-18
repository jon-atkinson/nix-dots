{
  lib,
  inputs,
  config,
  pkgs,
  mode,
  ...
}:

let
  venvSelector = pkgs.vimUtils.buildVimPlugin {
    pname = "venv-selector.nvim";
    version = "main";
    src = pkgs.fetchFromGitHub {
      owner = "linux-cultist";
      repo = "venv-selector.nvim";
      rev = "d4367f29df803e1fe79c0aa8e4c6250cd0ff0e5f";
      sha256 = "sha256-ZnFtEX6zUxanNVhchFmbXRjxnwUwJHQDB/HSt6aI6Fg";
    };
  };
in
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    nixpkgs.config.allowUnfree = true;

    opts = {
      number = true;
      relativenumber = true;

      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      smartindent = true;

      wrap = false;
      swapfile = false;
      backup = false;
      undodir = "${config.home.homeDirectory}/.vim/undodir";
      undofile = true;

      hlsearch = false;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      colorcolumn = "80,100,120";
    };

    globals = {
      mapleader = " ";
      netrw_bufsettings = "noma nomod nu nobl nowrap ro";
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>pv";
        action = "<cmd>Ex<CR>";
        options.desc = "Open netrw (nvim filetree)";
      }

      {
        mode = "v";
        key = "J";
        action = ":m '>+1<CR>gv=gv";
        options.desc = "Move selection down";
      }
      {
        mode = "v";
        key = "K";
        action = ":m '<-2<CR>gv=gv";
        options.desc = "Move selection up";
      }

      {
        mode = "n";
        key = "J";
        action = "mzJ`z";
        options.desc = "Join next line to current";
      }
      {
        mode = "n";
        key = "<C-d>";
        action = "<C-d>zz";
        options.desc = "Scroll down half a page and center cursor";
      }
      {
        mode = "n";
        key = "<C-u>";
        action = "<C-u>zz";
        options.desc = "Scroll up half a page and center cursor";
      }
      {
        mode = "n";
        key = "n";
        action = "nzzzv";
        options.desc = "Repeat search forward (center cursor)";
      }
      {
        mode = "n";
        key = "N";
        action = "Nzzzv";
        options.desc = "Repeat search backward (center cursor)";
      }

      {
        mode = "x";
        key = "<leader>p";
        action = "\"_dP";
        options.desc = "Delete without overwriting yank buffer";
      }

      {
        mode = "n";
        key = "<leader>y";
        action = "\"+y";
        options.desc = "Yank text to system clipboard";
      }
      {
        mode = "v";
        key = "<leader>y";
        action = "\"+y";
        options.desc = "Yank text to system clipboard";
      }
      {
        mode = "n";
        key = "<leader>Y";
        action = "\"+Y";
        options.desc = "Yank entire line to system clipboard";
      }

      {
        mode = "n";
        key = "<leader>s";
        action = ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>";
        options.desc = "Search and replace current word in file (case-insensitive)";
      }

      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        options.desc = "Display diagnostics";
      }

      {
        mode = "n";
        key = "<leader>vs";
        action = "<cmd>VenvSelect<CR>";
        options.desc = "Select Venv";
      }
      {
        mode = "n";
        key = "<leader>vc";
        action = "<cmd>VenvSelectCached<CR>";
        options.desc = "Select Cached Venv";
      }

      # === LSP Keymaps ===
      {
        mode = "n";
        key = "gR";
        action = "<cmd>Telescope lsp_references<CR>";
        options.desc = "Show LSP references";
      }
      {
        mode = "n";
        key = "grr";
        action = "<cmd>Trouble lsp_references focus=true<cr>";
        options.desc = "Show references";
      }
      {
        mode = "n";
        key = "gD";
        action = "<cmd>lua vim.lsp.buf.declaration()<CR>";
        options.desc = "Go to declaration";
      }
      {
        mode = "n";
        key = "gd";
        action = "<cmd>Telescope lsp_definitions<CR>";
        options.desc = "Show LSP definitions";
      }
      {
        mode = "n";
        key = "gi";
        action = "<cmd>Telescope lsp_implementations<CR>";
        options.desc = "Show LSP implementations";
      }
      {
        mode = "n";
        key = "gt";
        action = "<cmd>Telescope lsp_type_definitions<CR>";
        options.desc = "Show LSP type definitions";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>ca";
        action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
        options.desc = "See available code actions";
      }
      {
        mode = "n";
        key = "<leader>rn";
        action = "<cmd>lua vim.lsp.buf.rename()<CR>";
        options.desc = "Smart rename";
      }
      {
        mode = "n";
        key = "<leader>D";
        action = "<cmd>Telescope diagnostics bufnr=0<CR>";
        options.desc = "Show buffer diagnostics";
      }
      {
        mode = "n";
        key = "<leader>d";
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        options.desc = "Show line diagnostics";
      }
      {
        mode = "n";
        key = "[d";
        action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
        options.desc = "Go to previous diagnostic";
      }
      {
        mode = "n";
        key = "]d";
        action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
        options.desc = "Go to next diagnostic";
      }
      {
        mode = "n";
        key = "K";
        action = "<cmd>lua vim.lsp.buf.hover()<CR>";
        options.desc = "Show documentation for what is under cursor";
      }
      {
        mode = "n";
        key = "<leader>rs";
        action = "<cmd>LspRestart<CR>";
        options.desc = "Restart LSP";
      }
      {
        mode = "n";
        key = "gi";
        action = "<cmd>lua vim.lsp.buf.implementation()<CR>";
        options.desc = "Go to implementation";
      }
      {
        mode = "n";
        key = "gt";
        action = "<cmd>lua vim.lsp.buf.type_definition()<CR>";
        options.desc = "Go to type definition";
      }
    ];

    colorschemes = {
      moonfly = {
        enable = true;
        autoLoad = true;
      };
      kanagawa = {
        enable = false;
        autoLoad = true;
      };
      rose-pine = {
        enable = false;
        autoLoad = true;
      };
      catppuccin = {
        enable = false;
        autoLoad = true;
      };
      tokyonight = {
        enable = false;
        autoLoad = true;
      };
      gruvbox = {
        enable = false;
        autoLoad = true;
      };
    };

    plugins = {
      gitgutter.enable = true;
      trouble = {
        enable = true;
        settings = {
          modes = {
            lsp_references = {
              params = {
                include_declaration = true;
                include_current = true;
              };
            };
          };
        };
        luaConfig.pre = ''
          useDiagnosticSigns = true;
        '';
      };
      lexima.enable = true;
      lualine.enable = true;
      telescope.enable = true;
      treesitter.enable = true;
      web-devicons.enable = true;
      which-key.enable = true;
      lspconfig.enable = true;
      comment.enable = true;
      fugitive.enable = true;
      undotree.enable = true;
      todo-comments.enable = true;
      cmp = {
        enable = true;
        settings = {
          completion.completeopt = "menu,menuone,preview,noselect";
          mapping = {
            preset = "insert";
            "<C-k>" = "cmp.mapping.select_prev_item()";
            "<C-j>" = "cmp.mapping.select_next_item()";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = false })";
          };
          snippet.expand = ''
            function(args)
              require("luasnip").lsp_expand(args.body)
            end
          '';
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ]
          ++ lib.optionals (mode == "personal") [
            { name = "copilot"; }
          ];
        };
      };
      cmp-buffer.enable = true;
      cmp-path.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp_luasnip.enable = true;
      friendly-snippets.enable = true;
      copilot-cmp.enable = lib.mkIf (mode == "personal") true;
      luasnip.enable = true;
      lspkind.enable = true;
      harpoon.enable = true;
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            go = [ "gofumpt" ];
            javascript = [ "prettier" ];
            typescript = [ "prettier" ];
            javascriptreact = [ "prettier" ];
            typescriptreact = [ "prettier" ];
            svelte = [ "prettier" ];
            html = [ "prettier" ];
            json = [ "prettier" ];
            yaml = [ "prettier" ];
            markdown = [ "prettier" ];
            lua = [ "stylua" ];
            python = [ "ruff_format" ];
          };

          format_on_save = lib.mkIf (mode == "personal") {
            lsp_fallback = true;
            async = false;
            timeout_ms = 1000;
          };
        };
      };
    };
    extraPlugins = [
      venvSelector
    ];

    lsp.servers = {
      copilot.enable = lib.mkIf (mode == "personal") true;
      omnisharp.enable = true;
      gopls = {
        enable = true;
        config = {
          analyses = {
            unusedparams = true;
          };
          staticcheck = true;
          gofumpt = true;
        };
      };
      rust_analyzer = {
        enable = true;
        config = {
          imports = {
            granularity = {
              group = "module";
            };
            prefix = "self";
          };
          cargo = {
            buildScripts = {
              enable = true;
            };
          };
          procMacro = {
            enable = true;
          };
        };
      };
      lua_ls.enable = true;
      nixd.enable = true;
      nil_ls = {
        enable = true;
        config.nix.flake = {
          autoArchive = true;
          autoEvalInputs = true;
        };
      };
      clangd.enable = true;
      html.enable = true;
      ts_ls.enable = true;
      pyright.enable = true;
      terraform_lsp.enable = true;
      bashls.enable = true;
    };
    extraConfigLua = ''
      require("venv-selector").setup({
        name = ".venv",
        search_workspace = true,
        search_venv_managers = { "uv", "venv", "poetry", "pipenv" },
        auto_refresh = true,
        notify_user_on_activate = true,
      })
    '';
  };
}
