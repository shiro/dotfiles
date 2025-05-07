local M = {
  {
    "dundalek/lazy-lsp.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("lazy-lsp").setup({
        preferred_servers = {
          typescriptreact = {
            "typescript-language-server",
            "prettierd",
            "eslint",
            "tailwindcss",
          },
          typescript = {
            "typescript-language-server",
            "eslint",
          },
          javascript = {
            "typescript-language-server",
            "eslint",
          },
          python = { "pyright" },
          rust = {
            -- "rust_analyzer"
          },
          -- kotlin = {
          --   "kotlin-language-server",
          -- },
        },
        configs = {
          kotlin_language_server = {
            init_options = {
              storagePath = vim.env.XDG_DATA_HOME .. "/" .. "nvim-data",
            },
          },
        },
      })

      local signs = { Error = "☢️", Warn = "⚠", Hint = "❓", Info = "ℹ" }

      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl })
      end

      vim.diagnostic.config({
        virtual_text = false,
        update_in_insert = true,
        float = { border = "rounded" },
        signs = { priority = 200 },
      })
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
        close_events = { "BufHidden", "InsertLeave" },
      })
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      -- TODO rewrite the lazy plugin to use system rust_analyzer without wrapping it (fails proc macros)
      local lspconfig = require("lspconfig")
      lspconfig["rust_analyzer"].setup({})
      lspconfig.kotlin_language_server.setup({
        init_options = {
          storagePath = vim.env.XDG_DATA_HOME .. "/" .. "nvim-data",
        },
      })

      require("mason").setup()
      require("mason-tool-installer").setup({
        ensure_installed = {
          --         -- "stylua", -- lua format
          --         -- "lua-language-server", -- lua
          --         "typescript-language-server", -- TS
          "prettierd", -- JS/TS format - prettier
          "kotlin-language-server",
          --         "eslint-lsp", -- JS/TS lint
          --         -- "rust-analyzer", -- rust
          --         "taplo", -- toml
          --         "tailwindcss-language-server", -- tailwind
          --         "json-lsp", -- json
          --         "nil", -- nix
          --         "gopls", -- golang
          --         "gofumpt", -- golang format
          --         -- "goimports-reviser", -- golang format
          --         "golines", -- golang format
        },
      })
      --     -- capabilities.textDocument.completion.completionItem.snippetSupport = tru

      --
      --     local capabilities = require("cmp_nvim_lsp").default_capabilities()
      --     local servers = {
      --       {
      --         "jsonls",
      --         {
      --           filetypes = { "json", "jsonc" },
      --           capabilities = capabilities,
      --           settings = {
      --             json = {
      --               -- Schemas https://www.schemastore.org
      --               schemas = {
      --                 {
      --                   fileMatch = { "package.json" },
      --                   url = "https://json.schemastore.org/package.json",
      --                 },
      --                 {
      --                   fileMatch = { "tsconfig*.json" },
      --                   url = "https://json.schemastore.org/tsconfig.json",
      --                 },
      --                 {
      --                   fileMatch = {
      --                     ".prettierrc",
      --                     ".prettierrc.json",
      --                     "prettier.config.json",
      --                   },
      --                   url = "https://json.schemastore.org/prettierrc.json",
      --                 },
      --                 {
      --                   fileMatch = { ".eslintrc", ".eslintrc.json" },
      --                   url = "https://json.schemastore.org/eslintrc.json",
      --                 },
      --                 {
      --                   fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
      --                   url = "https://json.schemastore.org/babelrc.json",
      --                 },
      --                 {
      --                   fileMatch = { "lerna.json" },
      --                   url = "https://json.schemastore.org/lerna.json",
      --                 },
      --                 {
      --                   fileMatch = { "now.json", "vercel.json" },
      --                   url = "https://json.schemastore.org/now.json",
      --                 },
      --                 {
      --                   fileMatch = {
      --                     ".stylelintrc",
      --                     ".stylelintrc.json",
      --                     "stylelint.config.json",
      --                   },
      --                   url = "http://json.schemastore.org/stylelintrc.json",
      --                 },
      --               },
      --             },
      --           },
      --         },
      --       },
      --       { "tailwindcss" },
      --       -- { "eslint" },
      --       { "rust_analyzer" },
      --       { "taplo" },
      --     }
      --
      --     for _, info in ipairs(servers) do
      --       local lsp = info[1]
      --       local options = {}
      --       if info[2] ~= nil then
      --         options = info[2]
      --       end
      --       lspconfig[lsp].setup(options)
      --     end
      --
      --     lspconfig.gopls.setup({
      --       settings = {
      --         gopls = {
      --           completeUnimported = true,
      --           usePlaceholders = true,
      --           analyses = {
      --             unusedparams = true,
      --           },
      --         },
      --       },
      --     })
    end,
  },

  -- lua VIM documentation
  {
    "folke/neodev.nvim",
    ft = "lua",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("neodev").setup({})
      local lspconfig = require("lspconfig")
      lspconfig["lua_ls"].setup({})
    end,
  },
  -- rust
  {
    "mrcjkb/rustaceanvim",
    version = "6",
    lazy = false, -- this plugin is already lazy
  },
}

vim.api.nvim_create_autocmd("LspAttach", {
  -- group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    -- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    vim.keymap.set("n", "gd", function()
      if vim.bo.filetype == "markdown" and require("obsidian").util.cursor_on_markdown_link() then
        vim.cmd("ObsidianFollowLink")
        return
      end

      -- vim.lsp.buf.definition()
      require("telescope.builtin").lsp_definitions()
    end, { buffer = ev.buf })
  end,
})
-- code actions
vim.keymap.set({ "n", "v" }, "<space>a", vim.lsp.buf.code_action, { silent = true })
-- symbol info
vim.keymap.set(
  "n",
  "<C-P>",
  function() vim.lsp.buf.hover({ border = "rounded" }) end,
  { noremap = true, silent = true }
)
-- move to next/prev diagnostics
vim.keymap.set("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end)
vim.keymap.set("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end)

return M
