local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.api.nvim_create_augroup("default", { clear = true })

local notify = function(message)
  if type(message) == "string" then
    require("notify")(message)
  else
    require("notify")(vim.inspect(message))
  end
end

function set_timeout(timeout, callback)
  local uv = vim.loop
  local timer = uv.new_timer()
  local function ontimeout()
    uv.timer_stop(timer)
    uv.close(timer)
    vim.schedule(function()
      callback(timer)
    end)
  end
  uv.timer_start(timer, timeout, 0, ontimeout)
  return timer
end

require("lazy").setup({
  -- additional motion targets {{{
  {
    "https://github.com/wellle/targets.vim",
  },
  -- }}}
  -- pretty folds {{{
  {
    "bbjornstad/pretty-fold.nvim",
    config = function()
      require("pretty-fold").setup({
        fill_char = " ",
        sections = {
          left = { "content" },
          right = {
            " ",
            "number_of_folded_lines",
            function(config)
              return config.fill_char:rep(3)
            end,
          },
        },
        process_comment_signs = false,
      })
    end,
  },
  -- }}}
  -- syntax tree navigation
  -- {{{
  -- {
  --   "ziontee113/syntax-tree-surfer",
  --   config = function()
  --     local sts = require("syntax-tree-surfer")
  --     sts.setup({})
  --     --.go_to_top_node_and_execute_commands(false, { "normal! O", "normal! O", "startinsert" })<cr>
  --     vim.keymap.set({ "n", "v" }, "<Down>", function()
  --       -- sts.move("down")
  --       sts.select()
  --     end, { silent = true })
  --     vim.keymap.set({ "n" }, "<Right>", function()
  --       sts.surf("next")
  --       vim.api.nvim_input("o<ESC>")
  --     end, { silent = true })
  --     vim.keymap.set({ "v" }, "<Right>", function()
  --       sts.surf("parent", "visual")
  --     end, { silent = true })
  --   end,
  -- },
  -- {
  --   dir = "~/.dotfiles/config/nvim/lua/treesitter-navigation",
  --   dependencies = { "nvim-treesitter/nvim-treesitter" },
  --   opts = {},
  --   -- ft = { "html", "typescriptreact" },
  --   config = function()
  --     local tn = require("treesitter-navigation")
  --     tn.setup({})
  --     vim.keymap.set({ "n", "v" }, "<Down>", function()
  --       --
  --     end, { silent = true })
  --     vim.keymap.set({ "n", "v" }, "<Up>", function()
  --       tn.go("parent")
  --     end)
  --     vim.keymap.set({ "n", "v" }, "<Right>", function()
  --       tn.go("next")
  --     end)
  --     vim.keymap.set({ "n", "v" }, "<Left>", function()
  --       tn.go("prev")
  --     end)
  --     vim.keymap.set({ "n" }, "<Down>", function()
  --       tn.select_current_node()
  --     end)
  --   end,
  -- },
  -- }}}
  -- fancy notifications
  -- {{{
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("notify").setup({
        render = "minimal",
        stages = "static",
        top_down = false,
      })
    end,
  },
  -- }}}
  -- highlight symbol under cursor {{{
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function()
      require("illuminate").configure({
        providers = {
          "lsp",
          "treesitter",
        },
        delay = 200,
      })
    end,
  },
  -- }}}
  -- better quickfix window {{{
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    config = function()
      require("bqf").setup({ preview = { winblend = 0 } })
    end,
  },
  -- }}}
  -- chord keybinds {{{
  {
    "kana/vim-arpeggio",
    init = function()
      -- vim.g.arpeggio_timeoutlen = 40
    end,
    config = function()
      -- write
      vim.api.nvim_command("silent call arpeggio#map('n', '', 0, 'we', ':FormatAndSave<cr>')")
      -- write-quit
      vim.api.nvim_command("silent call arpeggio#map('n', '', 0, 'wq', ':wq<cr>')")
      -- write-quit-all
      vim.api.nvim_command("silent call arpeggio#map('n', '', 0, 'wr', ':wqa<cr>')")
      -- write-quit
      vim.api.nvim_command("silent call arpeggio#map('i', '', 0, 'wq', '<ESC>:wq<CR>')")
      -- save
      vim.api.nvim_command("silent call arpeggio#map('i', '', 0, 'jk', '<ESC>')")
      -- close buffer
      vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'ap', '<ESC>:q<CR>')")
      -- only buffer
      vim.api.nvim_command("call arpeggio#map('n', 's', 0, 'ao', '<C-w>o')")
      -- Ag
      -- vim.api.nvim_command("call arpeggio#map('n', '', 0, 'ag', ':Ag<CR>')")

      -- files, surpress false warning about jk being mapped already
      vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'jk', ':Files<cr>')")
      -- vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'di', '<CMD>wincmd w<CR>')")

      -- common movement shortcuts

      -- vim.api.nvim_create_user_command("ArpeggioReplaceWord", function()
      -- 	vim.fn.feedkeys("cimw")
      -- end, {})
      -- vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'mw', '<cmd>silent ArpeggioReplaceWord<cr>')")
      --
      -- vim.api.nvim_create_user_command("ArpeggioReplaceTag", function()
      -- 	vim.fn.feedkeys("cimt")
      -- end, {})
      -- vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'mt', '<cmd>silent ArpeggioReplaceTag<cr>')")

      vim.api.nvim_command("Arpeggio nmap kl yiw")

      local id = 0
      registerMapping = function(mapping, target)
        id = id + 1
        vim.api.nvim_create_user_command("ArpeggioLeap" .. id, function()
          -- print(99)
          -- require("leap").leap({ target_windows = { vim.fn.win_getid() } })
          vim.fn.feedkeys(target)
          -- vim.api.nvim_feedkeys("\\<C-n>", "m", true)

          -- local key = vim.api.nvim_replace_termcodes("<C-n>", true, false, true)
          -- vim.api.nvim_feedkeys("\\<C-d>", "m", true)
        end, {})
        vim.api.nvim_command(
          "silent call arpeggio#map('n', 's', 0, '" .. mapping .. "', '<cmd>ArpeggioLeap" .. id .. "<cr>')"
        )
      end

      registerMapping("mq", "cmiq")
      registerMapping("mw", "cmiw")
      registerMapping("mb", "cmib")
      -- registerMapping("nq", "vaq")
      -- registerMapping("mw", "viw")
      -- registerMapping("nw", "viW")
      -- registerMapping("mb", "vib")
      -- -- registerMapping("mv", "V")

      -- local registerYankMapping = function(mapping, target)
      --   vim.api.nvim_create_user_command("ArpeggioLeap" .. target, function()
      --     -- require("leap").leap({ target_windows = { vim.fn.win_getid() } })
      --     -- vim.fn.feedkeys(target)
      --     require("leap").leap({
      --       target_windows = { vim.fn.win_getid() },
      --       action = require("leap-spooky").spooky_action(function()
      --         return "yiw"
      --       end, {
      --         -- keeppos = true,
      --         -- on_exit = (vim.v.operator == 'y') and 'p',
      --       }),
      --     })
      --   end, {})
      --   vim.api.nvim_command(
      --     "silent call arpeggio#map('n', 's', 0, '" .. mapping .. "', '<cmd>silent ArpeggioLeap" .. target .. "<cr>')"
      --   )
      -- end

      registerMapping("yw", "yiw\\<C-n>")
      -- vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'yw', 'yirm')")
    end,
  },
  -- }}}
  -- CWD managmnent {{{
  {
    "airblade/vim-rooter",
    event = "VeryLazy",
    init = function()
      vim.g.rooter_change_directory_for_non_project_files = "current"
      vim.g.rooter_silent_chdir = 1
      vim.g.rooter_resolve_links = 1
      vim.g.rooter_patterns = { "cargo.toml", ".git" }

      -- only if requested
      vim.g.rooter_manual_only = 1

      -- cwd to root
      -- nmap <leader>;r :Rooter<cr>
      -- cwd to current
      -- nmap <leader>;t :cd %:p:h<cr>
      -- auto change cwd to current file
      -- set autochdir
    end,
  },
  -- }}}
  -- diff {{{
  -- {
  --   "sindrets/diffview.nvim",
  -- },
  -- }}}
  -- git {{{
  {
    "tpope/vim-fugitive",
    -- lazy = true,
    -- keys = {
    -- 	{ "<leader>gd", ":Gdiff<CR>" },
    -- },
    init = function()
      vim.opt.diffopt = vim.opt.diffopt + "vertical"

      vim.keymap.set("n", "<leader>gd", ":Gdiff<CR>", {})
      -- nnoremap <leader>ga :Git add %:p<CR><CR>
      -- nnoremap <leader>gs :Gstatus<CR>
      -- nnoremap <leader>gc :Gcommit -v -q<CR>
      -- nnoremap <leader>gt :Gcommit -v -q %:p<CR>
      -- nnoremap <leader>ge :Gedit<CR>
      -- "nnoremap <leader>gr :Gread<CR>
      -- nnoremap <leader>gw :Gwrite<CR><CR>
      -- nnoremap <leader>gl :silent! Glog<CR>:bot copen<CR>
      -- nnoremap <leader>gp :Ggrep<Space>
      -- "nnoremap <leader>gm :Gmove<Space>
      -- nnoremap <leader>gb :Git branch<Space>
      -- nnoremap <leader>go :Git checkout<Space>
      -- nnoremap <leader>gps :Dispatch! git push<CR>
      -- nnoremap <leader>gpl :Dispatch! git pull<CR>

      -- " 72 is the number
      -- autocmd Filetype gitcommit setlocal spell textwidth=72
      -- " auto cleanup buffers
      -- autocmd BufReadPost fugitive://* set bufhidden=delete
    end,
  },
  {
    "airblade/vim-gitgutter",
    init = function()
      vim.g.gitgutter_map_keys = 0
      vim.g.gitgutter_show_msg_on_hunk_jumping = 0
      -- vim.g["gitgutter_signs"] = 0
      vim.g.gitgutter_highlight_linenrs = 1
      vim.g.gitgutter_sign_allow_clobber = 0
      vim.g.gitgutter_sign_removed = "⠀"
      vim.g.gitgutter_sign_added = "⠀"
      vim.g.gitgutter_sign_modified = "⠀"
      vim.g.gitgutter_sign_removed = "⠀"
      vim.g.gitgutter_sign_removed_first_line = "⠀"
      vim.g.gitgutter_sign_removed_above_and_below = "⠀"
      vim.g.gitgutter_sign_modified_removed = "⠀"
    end,
    config = function()
      -- nnoremap <leader>gh <Plug>(GitGutterPreviewHunk)
      vim.api.nvim_set_keymap("n", "<C-A-Z>", "<Plug>(GitGutterUndoHunk)", { silent = true })
      vim.api.nvim_set_keymap(
        "n",
        "[c",
        "<Plug>(GitGutterPrevHunk) | :let g:gitgutter_floating_window_options['border'] = 'rounded'<CR> | <Plug>(GitGutterPreviewHunk)",
        { silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "]c",
        "<Plug>(GitGutterNextHunk) | :let g:gitgutter_floating_window_options['border'] = 'rounded'<CR> | <Plug>(GitGutterPreviewHunk)",
        { silent = true }
      )
    end,
  },
  -- }}}

  -- syntax highlight {{{
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "typescript",
          "tsx",
          "javascript",
          "css",
          "scss",
          "styled",
          "rust",
          "json",
          "lua",
          "sql",
          "go",
        },
        auto_install = true,
        highlight = { enable = true },
        incremental_selection = { enable = true },
        indent = { enable = true },
        context_commentstring = { enable = true },
      })
      -- vim.o.foldmethod = "expr"
      -- vim.o.foldexpr = "nvim_treesitter#foldexpr()"
    end,
  },
  -- }}}
  -- movement {{{
  -- {
  --   "ggandor/leap.nvim",
  --   init = function() end,
  --   config = function()
  --     local leap = require("leap")
  --     -- leap.opts.case_sensitive = true
  --     leap.opts.safe_labels = "sfnut"
  --     leap.opts.labels = "abcdefghijklmnopqrstuvwxyz"
  --     -- leap.opts.highlight_unlabeled_phase_one_targets = true
  --
  --     vim.keymap.set("n", "s", "<Plug>(leap-forward-to)")
  --     vim.keymap.set("n", "S", "<Plug>(leap-backward-to)")
  --
  --     require("leapLineJump")
  --   end,
  -- },
  -- {
  --   "ggandor/leap-spooky.nvim",
  --   dependencies = { "https://github.com/wellle/targets.vim" },
  --   config = function()
  --     local spooky = require("leap-spooky")
  --     spooky.setup({
  --       extra_text_objects = { 'iq', 'aq', 'ib', 'ab' },
  --     })
  --
  --     -- the plugin is broken with custom objects, fix that
  --     local broken_text_objects = { 'i\'', 'iq', 'aq', 'ib', 'ab' }
  --     for _, tobj in ipairs(broken_text_objects) do
  --       vim.keymap.set({'x', 'o'}, tobj:sub(1,1)..'r'..tobj:sub(2), function ()
  --         require('leap.remote').action { input = tobj }
  --       end)
  --     end
  --
  --     -- vim.keymap.set({'n'}, 'crs', function ()
  --     --     require('leap.remote').action { input = "cs", count = 1 }
  --     -- end)
  --
  --
  --     -- remove all insert mode binds we don't like
  --     -- for _, value in ipairs(vim.api.nvim_get_keymap("x")) do
  --     --   if value.lhs:sub(1, 1) == "i" or value.lhs:sub(1, 1) == "x" then
  --     --     vim.keymap.del("x", value.lhs, {})
  --     --   end
  --     -- end
  --   end,
  -- },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
      local flash = require("flash")
      flash.setup({
        search = {     
          mode = function(input)
            input = input:gsub("\\", "\\\\")

            local sep = "\\[^\\ ]\\{-}"
            -- local sep = "\\.\\{-}"

            local pattern = input:gsub(" ", sep)

            local ignore_case_flag = "\\c"
            local magick_matching_flag = "\\V"

            local ret = magick_matching_flag .. ignore_case_flag .. pattern
            return ret
          end,
        },
        label = { uppercase = false },
        modes = {
          char = {
            highlight = { backdrop = false },
            multi_line = false,
          },
        }
      })

      local text_objects = { 
        "c", "C", "y",
        "iw", "iq", "aq", "it", "at",
        "ib", "ab", "i{", "a{", "i}", "i(", "i)", "a(", "a)",
        "a}", "w", "W", "iW", "aa", "ia", "t.", "f.",
        "if", "af"
      }


      local remote_action = function(action, opts)
        local count = vim.v.count
        local view_info = vim.fn.winsaveview()

        require("flash").jump()

        local after_view_info = vim.fn.winsaveview()

        -- quit if aborted (position didn't change)
        if after_view_info.col == view_info.col and after_view_info.lnum == view_info.lnum then
          return
        end

        if count > 0 then vim.fn.feedkeys(count) end
        vim.fn.feedkeys(action)

        if mode == 'm' then return end

        -- if prefix == "y" or prefix == "d" then
        --   vim.schedule(function() vim.fn.winrestview(view_info) end)
        --   return
        -- end

        vim.schedule(function()
        vim.api.nvim_create_autocmd({'TextChanged', 'ModeChanged'}, {
          callback = function()
            local m1 = vim.v.event.old_mode
            local m2 = vim.v.event.new_mode

            if (m2 == "i") then return end
            if (m1 == "i" and m2 == "niI") then return end

            vim.fn.winrestview(view_info)
            return true
          end
        })
        end)
      end

      for _, tobj in ipairs(text_objects) do
        for _, prefix in ipairs({ "y", "c", "d", "v" }) do
          for _, mode in ipairs({ 'r', 'm' }) do
            local tobj_with_r = prefix..mode..tobj:gsub("%.", "")
            vim.keymap.set({"n"}, tobj_with_r, function ()
              local suffix = ""
              if tobj:sub(2,2) == "." then
                char = vim.fn.getchar()
                if char == 27 then return end
                suffix = vim.fn.nr2char(char)
              end

              local tobj = tobj:gsub("%.", "")
              local count = vim.v.count
              local view_info = vim.fn.winsaveview()

              require("flash").jump()

              local after_view_info = vim.fn.winsaveview()

              -- quit if aborted (position didn't change)
              if after_view_info.col == view_info.col and after_view_info.lnum == view_info.lnum then
                return
              end

              if count > 0 then vim.fn.feedkeys(count) end
              vim.fn.feedkeys(prefix..tobj..suffix)

              if mode == 'm' then return end

              if prefix == "y" or prefix == "d" then
                vim.schedule(function() vim.fn.winrestview(view_info) end)
                return
              end

              vim.schedule(function()
              vim.api.nvim_create_autocmd({'TextChanged', 'ModeChanged'}, {
                callback = function()
                  local m1 = vim.v.event.old_mode
                  local m2 = vim.v.event.new_mode

                  if (m2 == "i") then return end
                  if (m1 == "i" and m2 == "niI") then return end

                  vim.fn.winrestview(view_info)
                  return true
                end
              })
              end)
            end)
          end
        end
      end

      vim.keymap.set({"n"}, "grC", function ()
        remote_action("C")
      end)
    end,
    keys = {
      { "s", mode = { "n", "o" }, function() require("flash").jump() end, desc = "Flash" },
      -- { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      -- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      -- { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {
    "haya14busa/incsearch.vim",
    dependencies = { "haya14busa/incsearch-fuzzy.vim" },
    keys = {
      { "<leader>/", "<Plug>(incsearch-fuzzy-/)" },
      { "<leader>?", "<Plug>(incsearch-fuzzy-?)" },
    },
    init = function()
      vim.g["incsearch#auto_nohlsearch"] = 1
    end,
  },
  -- }}}
  -- LSP server, auto-complete {{{
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvimtools/none-ls-extras.nvim" },
    event = "VeryLazy",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
          require("none-ls.code_actions.eslint"),
          -- null_ls.builtins.completion.spell,

          -- golang
          null_ls.builtins.formatting.gofmt,
          null_ls.builtins.formatting.gofumpt,
          null_ls.builtins.formatting.goimports_reviser,
          null_ls.builtins.formatting.golines,
        },
      })
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
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "hrsh7th/nvim-cmp",
    },
    -- event = "VeryLazy",
    init = function()
      local signs = {
        Error = "☢️",
        Warn = "⚠",
        Hint = "❓",
        Info = "ℹ",
      }

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
    config = function()
      local lspconfig = require("lspconfig")
      local util = require("lspconfig/util")
      require("mason").setup()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "stylua", -- lua format
          "lua-language-server", -- lua
          "typescript-language-server", -- TS
          "prettierd", -- JS/TS format - prettier
          "eslint-lsp", -- JS/TS lint
          -- "rust-analyzer", -- rust
          "taplo", -- toml
          "tailwindcss-language-server", -- tailwind
          "json-lsp", -- json
          "nil", -- nix
          "gopls", -- golang
          "gofumpt", -- golang format
          -- "goimports-reviser", -- golang format
          "golines", -- golang format
        },
      })
      -- capabilities.textDocument.completion.completionItem.snippetSupport = tru

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local servers = {
        {
          "jsonls",
          {
            filetypes = { "json", "jsonc" },
            capabilities = capabilities,
            settings = {
              json = {
                -- Schemas https://www.schemastore.org
                schemas = {
                  {
                    fileMatch = { "package.json" },
                    url = "https://json.schemastore.org/package.json",
                  },
                  {
                    fileMatch = { "tsconfig*.json" },
                    url = "https://json.schemastore.org/tsconfig.json",
                  },
                  {
                    fileMatch = {
                      ".prettierrc",
                      ".prettierrc.json",
                      "prettier.config.json",
                    },
                    url = "https://json.schemastore.org/prettierrc.json",
                  },
                  {
                    fileMatch = { ".eslintrc", ".eslintrc.json" },
                    url = "https://json.schemastore.org/eslintrc.json",
                  },
                  {
                    fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
                    url = "https://json.schemastore.org/babelrc.json",
                  },
                  {
                    fileMatch = { "lerna.json" },
                    url = "https://json.schemastore.org/lerna.json",
                  },
                  {
                    fileMatch = { "now.json", "vercel.json" },
                    url = "https://json.schemastore.org/now.json",
                  },
                  {
                    fileMatch = {
                      ".stylelintrc",
                      ".stylelintrc.json",
                      "stylelint.config.json",
                    },
                    url = "http://json.schemastore.org/stylelintrc.json",
                  },
                },
              },
            },
          },
        },
        { "tailwindcss" },
        -- { "eslint" },
        { "rust_analyzer" },
        { "taplo" },
      }

      for _, info in ipairs(servers) do
        local lsp = info[1]
        local options = {}
        if info[2] ~= nil then
          options = info[2]
        end
        lspconfig[lsp].setup(options)
      end

      lspconfig.gopls.setup({
        settings = {
          gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
              unusedparams = true,
            },
          },
        },
      })
    end,
  },
  -- }}}
  -- autoamtically close/rename JSX tags {{{
  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    opts = {
      enable_close = false,
    },
    ft = { "typescriptreact", "javascriptreact" },
  },
  -- }}}
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig", "hrsh7th/nvim-cmp" },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require("typescript-tools").setup({
        capabilities = capabilities,
        settings = {
          -- LSP snipets crash cmp, try out if it's fixed after a while
          complete_function_calls = true,
          publish_diagnostic_on = "change",
          tsserver_file_preferences = { importModuleSpecifierPreference = "non-relative" },
          tsserver_plugins = {
            "@styled/typescript-styled-plugin",
            -- "typescript-styled-plugin",
          },
        },
      })
    end,
  },
  -- hide tailwind strings when not in focus
  {
    dir = "~/.dotfiles/config/nvim/lua/tw-conceal",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
    ft = { "html", "typescriptreact" },
  },
  -- NPM package versions
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    ft = { "json" },
    opts = {
      hide_up_to_date = true,
      icons = { enable = false },
    },
  },
  {
    "robitx/gp.nvim",
    config = function()
      local conf = {
        providers = {
          openai = {
            disable = true,
            endpoint = "https://api.openai.com/v1/chat/completions",
            -- secret = os.getenv("OPENAI_API_KEY"),
          },
          ollama = {
            endpoint = "http://localhost:11434/v1/chat/completions",
            -- secret = "dummy_secret",
          },
        },
        agents = {
          {
            provider = "ollama",
            -- name = "ChatOllamaLlama3.1-8B",
            name = "ChatOllamaLlama3",
            chat = true,
            -- command = false,
            command = true,
            -- string with model name or table with model name and parameters
            model = {
              -- model = "llama3.1",
              model = "llama3",
              temperature = 0.6,
              top_p = 1,
              min_p = 0.05,
            },
            -- system prompt (use this to specify the persona/role of the AI)
            -- system_prompt = "You are a general AI assistant.",
            system_prompt = "You are a code generator. Output only code.",
          },
        },
        -- default_command_agent = "ollama",
        -- default_chat_agent = "ollama",
      }
      require("gp").setup(conf)
      -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
    end,
  },
  -- formatting
  {
    "stevearc/conform.nvim",
    -- event = { "BufReadPre", "BufNewFile" },
    event = "VeryLazy",
    cmd = { "ConformInfo" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          lua = { "stylua" },
          svelte = { "prettierd" },
          javascript = { "dprint" },
          typescript = { "dprint" },
          javascriptreact = { "dprint" },
          typescriptreact = { "dprint" },
          json = { "prettierd" },
          graphql = { "prettierd" },
          java = { "google-java-format" },
          kotlin = { "ktlint" },
          ruby = { "standardrb" },
          markdown = { "prettierd" },
          erb = { "htmlbeautifier" },
          html = { "htmlbeautifier" },
          bash = { "beautysh" },
          proto = { "buf" },
          rust = { "rustfmt" },
          yaml = { "yamlfix" },
          toml = { "taplo" },
          css = { "prettierd" },
          scss = { "prettierd" },
        },
      })
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    config = function()
      local luasnip = require("luasnip")
      luasnip.setup({
        load_ft_func = require("luasnip.extras.filetype_functions").from_cursor_pos,
      })
      require("snippets.javascript").register()
      require("snippets.rust").register()
      require("snippets.go").register()
    end,
  },
  { "dorage/ts-manual-import.nvim", dependencies = { "L3MON4D3/LuaSnip" } },

  {
    dir = "~/.dotfiles/config/nvim/lua/luasnip-more",
    dependencies = { "L3MON4D3/LuaSnip" },
    opts = {},
  },
  {
    "hrsh7th/nvim-cmp",
    -- TS-LSP and preselect are broken after this commit
    commit = "b356f2c",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    event = "InsertEnter",
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      -- vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }

      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        preselect = cmp.PreselectMode.None,
        completion = {
          completeopt = "menu,menuone,noinsert",
          -- autocomplete = {
          --   cmp.TriggerEvent.TextChanged,
          --   cmp.TriggerEvent.InsertEnter,
          -- },
          -- keyword_length = 0,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        confirmation = {
          get_commit_characters = function(commit_characters)
            return {}
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<Left>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<Right>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert })
            elseif luasnip.expandable() then
              luasnip.expand()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<ESC>"] = cmp.mapping(function(fallback)
            luasnip.unlink_current()
            fallback()
          end, { "i" }),
        }),
        sources = cmp.config.sources({
          { name = "luasnip", priority = 999999 },
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
        }, {
          -- { name = "buffer" },
          { name = "path" },
        }),
      })

      cmp.setup.filetype("lua", {
        { name = "nvim_lua" },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
      validation_token = 0

      cmp.event:on("menu_opened", function()
        validation_token = validation_token + 1
        local _validation_token = validation_token
        -- set_timeout(150, function()
        --   if validation_token ~= _validation_token then
        --     return
        --   end
        --   notify(validation_token)
        --   cmp.select_next_item({
        --     behavior = cmp.SelectBehavior.Select,
        --   })
        -- end)
      end)
    end,
  },
  -- comments {{{
  {
    "numToStr/Comment.nvim",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    -- lazy = true,
    init = function()
      -- avoid comment plugin warning
      vim.g.skip_ts_context_commentstring_module = true
    end,
    -- keys = {
    --   { "<C-_>", "", mode = "n" },
    --   { "<C-_>", "", mode = "x" },
    -- },
    config = function()
      require("ts_context_commentstring").setup({ enable_autocmd = false })
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })

      vim.api.nvim_command("xmap <C-_> gc")
      vim.api.nvim_command("nmap <C-_> gccj")
    end,
  },
  -- }}}

  -- find and replace {{{
  {
    "nvim-pack/nvim-spectre",
    lazy = true,
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<C-S-R>", "<cmd>lua require('spectre').toggle()<CR>", mode = "n", silent = true },
      { "<Leader>R", "<cmd>lua require('spectre').toggle()<CR>", mode = "n", silent = true },
    },
  },
  -- }}}
  -- find files, changes and more {{{
  {
    "nvim-telescope/telescope.nvim",
    -- tag = "0.1.5",
    branch = "master",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      -- "fannheyward/telescope-coc.nvim",
      "natecraddock/telescope-zf-native.nvim",
    },
    config = function()
      local telescope_actions = require("telescope.actions")

      local ts_select_dir_for_grep = function(prompt_bufnr)
        local action_state = require("telescope.actions.state")
        local fb = require("telescope").extensions.file_browser
        local live_grep = require("telescope.builtin").live_grep
        local current_line = action_state.get_current_line()

        fb.file_browser({
          files = false,
          depth = false,
          attach_mappings = function(prompt_bufnr)
            require("telescope.actions").select_default:replace(function()
              local entry_path = action_state.get_selected_entry().Path
              local dir = entry_path:is_dir() and entry_path or entry_path:parent()
              local relative = dir:make_relative(vim.fn.getcwd())
              local absolute = dir:absolute()

              live_grep({
                results_title = relative .. "/",
                cwd = absolute,
                default_text = current_line,
              })
            end)

            return true
          end,
        })
      end

      require("telescope").setup({
        defaults = {
          mappings = { i = { ["<esc>"] = telescope_actions.close } },
          layout_config = {
            vertical = {
              height = 0.6,
              -- mirror = true,
            },
          },
          layout_strategy = "flex",
        },
        file_ignore_patterns = {
          "node%_modules/.*",
          "./target/.*",
        },
        pickers = {
          live_grep = {
            mappings = {
              i = { ["<C-f>"] = ts_select_dir_for_grep },
              n = { ["<C-f>"] = ts_select_dir_for_grep },
            },
          },
        },
      })

      require("telescope").load_extension("zf-native")
      require("telescope").load_extension("file_browser")

      local sorter = require("top-results-sorter").sorter()
      local tele_builtin = require("telescope.builtin")
      local actions = require("telescope.actions")
      function layout()
        local width = vim.fn.winwidth(0)
        local height = vim.fn.winheight(0)

        if (width / 2) > height then
          return "horizontal"
        end
        return "vertical"
      end

      function files(show_hidden)
        -- local find_command = nil
        -- if show_hidden then
        -- find_command = { "rg", "--files", "--hidden", "-g", "!.git" }
        -- end

        require("telescopePickers").prettyFilesPicker({
          picker = "find_files",

          options = {
            sorter = sorter,
            previewer = false,
            layout_strategy = layout(),
            find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
            -- attach_mappings = function(_, map)
            --   map("n", "zh", function(prompt_bufnr)
            --   	actions.close(prompt_bufnr)
            --   	files(not show_hidden)
            --   end)
            --   return true
            -- end,
          },
        })
      end

      vim.api.nvim_create_user_command("Files", function()
        files()
      end, {})
      vim.keymap.set("n", "<leader>f", function()
        tele_builtin.resume()
      end, {})

      vim.keymap.set("n", "<leader>F", function()
        require("telescopePickers").prettyGrepPicker({
          picker = "live_grep",
          options = { layout_strategy = layout() },
        })
      end, {})
      vim.keymap.set("n", "<leader>s", function()
        require("telescopePickers").prettyWorkspaceSymbolsPicker({
          sorter = sorter,
          prompt_title = "Workspace symbols",
          layout_strategy = layout(),
        })
      end, {})
      vim.keymap.set("n", "<leader>d", function()
        require("telescopePickers").prettyGitPicker({
          sorter = sorter,
          layout_strategy = layout(),
        })
      end, {})
      vim.keymap.set("n", "<leader>h", function()
        tele_builtin.git_bcommits({
          layout_strategy = layout(),
        })
      end, {})

      vim.keymap.set("x", "<leader>h", function()
        tele_builtin.git_bcommits_range({
          layout_strategy = layout(),
        })
      end, {})

      vim.keymap.set("n", "gr", function()
        vim.api.nvim_command("m'")
        require("telescope.builtin").lsp_references({
          layout_strategy = layout(),
          -- on_complete = {
          --     function(picker)
          --         -- remove this on_complete callback
          --         picker:clear_completion_callbacks()
          --         -- if we have exactly one match, select it
          --         if picker.manager.linked_states.size == 1 then
          --             require("telescope.actions").select_default(picker.prompt_bufnr)
          --         end
          --     end,
          -- }
        })
      end)

      vim.api.nvim_create_user_command("Highlights", "lua require('telescope.builtin').highlights()", {})
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },
  -- }}}

  -- file manager {{{
  {
    "kevinhwang91/rnvimr",
    -- keys = { { "<leader>l", "" } },
    init = function()
      vim.g.rnvimr_enable_ex = 1
      vim.g.rnvimr_enable_picker = 1
      vim.g.rnvimr_draw_border = 0
      vim.g.rnvimr_layout = {
        relative = "editor",
        width = vim.fn.winwidth(0),
        height = vim.fn.winheight(0) / 2,
        col = 0,
        row = vim.fn.winheight(0) / 4,
        style = "minimal",
      }
      -- vim.g.rnvimr_ranger_views = {
      -- 	-- { minwidth = 50, maxwidth = 89, ratio = { 1, 1 } },
      -- 	{ ratio = { 1, 1 } },
      -- }
      vim.g.rnvimr_ranger_cmd = {
        "ranger",
        "--cmd=set preview_directories false",
        "--cmd=set column_ratios 2,5,0",
        "--cmd=set preview_files false",
        "--cmd=set preview_images false",
        "--cmd=set padding_right false",
        "--cmd=set collapse_preview true",
      }
    end,
    config = function()
      vim.keymap.set("n", "<leader>l", function()
        vim.api.nvim_command("RnvimrToggle")
      end, {})
    end,
  },
  --- }}}

  -- language-specific stuff {{{

  -- rust
  { "rust-lang/rust.vim", ft = "rust" },
  { "arzg/vim-rust-syntax-ext", ft = "rust" },
  -- {
  -- 	"mrcjkb/rustaceanvim",
  -- 	version = "^4", -- Recommended
  -- 	ft = { "rust" },
  -- },
  {
    "saecki/crates.nvim",
    ft = "toml",
    tag = "stable",
    config = function()
      require("crates").setup()
    end,
  },
  -- }}}

  -- go
  -- {{{
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("gopher").setup({})
    end,
    build = function()
      vim.cmd([[silent! GoInstallDeps]])
    end,
  },
  -- }}}

  -- misc {{{

  -- detect file shiftwidth, tab mode
  "tpope/vim-sleuth",

  -- mappings to easily delete, change and add such surroundings in pairs, such as quotes, parens, etc.
  -- {{{
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
  -- }}}

  -- convinient pair mappings
  --Plug "tpope/vim-unimpaired"

  -- enables repeating other supported plugins with the . command
  "tpope/vim-repeat",
  -- }}}
  -- pretty UI {{{
  {
    "stevearc/dressing.nvim",
    opts = {},
    event = "VeryLazy",
  },
  -- }}}
  -- show color hex codes {{{
  {
    "NvChad/nvim-colorizer.lua",
    event = "VeryLazy",
    config = function()
      require("colorizer").setup({ user_default_options = { mode = "virtualtext", names = false } })
    end,
  },
  -- }}}

  {
    "pwntester/octo.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("octo").setup({
        suppress_missing_scope = {
          projects_v2 = true,
        },
      })
    end,
  },
}, { rocks = { enabled = false } })

local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    -- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  end,
})
-- vim.api.nvim_set_keymap("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
-- vim.api.nvim_set_keymap("n", "gi", "<Plug>(coc-implementation)", { silent = true })
vim.keymap.set("n", "<leader>[e", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<leader>]e", vim.diagnostic.goto_next)
vim.keymap.set("n", "[e", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set("n", "]e", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end)

-- vim.keymap.set("n", "<A-S-e>", vim.lsp.buf.rename, {})
vim.keymap.set("n", "<leader>e", vim.lsp.buf.rename, {})
-- vim.api.nvim_set_keymap("n", "<A-S-r>", "<Plug>(coc-refactor)", { silent = true })
-- vim.api.nvim_set_keymap("v", "<A-S-r>", "<Plug>(coc-refactor-selected)", { silent = true })
-- show outline (hierarchy)

-- function set_timeout(timeout, callback)
-- 	local uv = vim.loop
-- 	local timer = uv.new_timer()
-- 	local function ontimeout()
-- 		uv.timer_stop(timer)
-- 		uv.close(timer)
-- 		callback(timer)
-- 	end
-- 	uv.timer_start(timer, timeout, 0, ontimeout)
-- 	return timer
-- end

-- function toggleOutline()
-- 	local win_id = vim.api.nvim_eval("coc#window#find('cocViewId', 'OUTLINE')")
-- 	if win_id == -1 then
-- 		vim.fn.CocAction("showOutline", 1)
--
-- 		-- local foo = vim.api.nvim_eval("coc#float#get_float_by_kind('outline-preview')")
-- 		-- print(foo)
--
-- 		set_timeout(300, function()
-- 			vim.schedule(function()
-- 				win_id = vim.api.nvim_eval("coc#window#find('cocViewId', 'OUTLINE')")
-- 				if win_id == -1 then
-- 					return
-- 				end
-- 				vim.api.nvim_set_current_win(win_id)
-- 			end)
-- 		end)
-- 	else
-- 		vim.api.nvim_command("call coc#window#close(" .. win_id .. ")")
-- 	end
-- end
--
-- vim.keymap.set("n", "go", toggleOutline, { silent = true })
-- list warnings/errors in telescope
-- TODO

-- vim.keymap.set("i", "<C-Space>", "coc#refresh()", { expr = true, silent = true })

-- highlight the symbol under cursor
-- vim.api.nvim_create_autocmd("CursorHold", {
--     group = "CocGroup",
--     command = "silent call CocActionAsync('highlight')",
--     desc = "Highlight symbol under cursor on CursorHold"
-- })
--
-- _G.CloseAllFloatingWindows = function()
--     local closed_windows = {}
--     for _, win in ipairs(vim.api.nvim_list_wins()) do
--         local config = vim.api.nvim_win_get_config(win)
--         if config.relative ~= "" then          -- is_floating_window?
--             vim.api.nvim_win_close(win, false) -- do not force
--             table.insert(closed_windows, win)
--         end
--     end
--     print(string.format('Closed %d windows: %s', #closed_windows, vim.inspect(closed_windows)))
-- end
-- vim.keymap.set('i', '<ESC>', "coc#util#has_float() ? <CMD>lua _G.show_docs()<CR> : <ESC>", { expr = true });

-- show docs
-- function _G.show_docs()
-- 	local cw = vim.fn.expand("<cword>")
-- 	--if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
-- 	--    vim.api.nvim_command('h ' .. cw)
-- 	if vim.api.nvim_eval("coc#rpc#ready()") then
-- 		-- vim.fn.CocActionAsync("doHover")
-- 	else
-- 		vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
-- 	end
-- end

vim.keymap.set("n", "<C-P>", vim.lsp.buf.hover, { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-S-p>", "<CMD>lua _G.show_docs()<CR>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<F12>", "<CMD>lua _G.show_docs()<CR>", { noremap = true, silent = true })
-- vim.keymap.set("i", "<C-P>", "<CMD>lua _G.show_docs()<CR>", { noremap = true, silent = true })
-- vim.keymap.set("i", "<C-S-p>", "CocActionAsync('showSignatureHelp')", { silent = true, expr = true })
-- vim.keymap.set("i", "<F12>", "CocActionAsync('showSignatureHelp')", { silent = true, expr = true })
-- undo/redo
-- vim.keymap.set("n", "<leader>u", "<cmd>CocCommand workspace.undo<cr>')", { silent = true })
-- vim.keymap.set("n", "<leader><S-u>", "<cmd>CocCommand workspace.redo<cr>')", { silent = true })

-- tab/S-tab completion menu
function _G.check_back_space()
  local col = vim.fn.col(".") - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
end

-- code actions
vim.keymap.set({ "n", "v" }, "<space>a", vim.lsp.buf.code_action, { silent = true })
-- refactor
vim.keymap.set({ "n", "x" }, "<leader>r", function()
  require("telescope").extensions.refactoring.refactors()
end, { silent = true })
vim.api.nvim_create_user_command("RenameFile", "silent CocCommand workspace.renameCurrentFile", {})

local function quickfix()
  vim.lsp.buf.code_action({
    filter = function(a)
      return a.isPreferred
    end,
    apply = true,
  })
end
vim.keymap.set("n", "<leader>qf", quickfix, { silent = true })

-- reformat code
-- vim.keymap.set("n", "gl", function()
-- 	-- organize_imports()
-- 	format({
-- 		callback = save,
-- 	})
-- end, opts)

vim.keymap.set("n", "gl", function()
  organize_imports()
  format({ callback = save })
end, {})

vim.api.nvim_create_autocmd("FileType", {
  group = "default",
  pattern = "lua",
  command = "setl formatexpr=CocAction('formatSelected')",
})

-- language specific {{{

vim.api.nvim_create_autocmd("FileType", {
  group = "default",
  pattern = { "javascript", "typescript", "typescriptreact" },
  callback = function()
    -- vim.api.nvim_command("call arpeggio#map('n', '', 0, 'al', 'aconsole.log();<left><left>')")
    -- make import lazy
    -- vim.keymap.set(
    --   "n",
    --   ";1",
    --   '0ciwconst<esc>/from<cr>ciw= lazy(() => import(<esc>lxf"a))<esc>0',
    --   { silent = true, noremap = true }
    -- )
    -- create component
    -- vim.keymap.set(
    --   "n",
    --   ";1",
    --   '0ciwconst<esc>/from<cr>ciw= lazy(() => import(<esc>lxf"a))<esc>0',
    --   { silent = true, noremap = true }
    -- )
  end,
})

-- quickfix
vim.api.nvim_create_autocmd("FileType", {
  group = "default",
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "dd", function()
      local curqfidx = vim.fn.line(".")
      local entries = vim.fn.getqflist()
      if entries == nil then
        return
      end
      if #entries == 0 then
        return
      end
      -- remove the item from the quickfix list
      table.remove(entries, curqfidx)
      vim.fn.setqflist(entries, "r")
      -- reopen quickfix window to refresh the list
      vim.cmd("copen")
      local new_idx = curqfidx < #entries and curqfidx or math.max(curqfidx - 1, 1)
      local winid = vim.fn.win_getid()
      if winid == nil then
        return
      end
      vim.api.nvim_win_set_cursor(winid, { new_idx, 0 })
    end, { silent = true, noremap = true, buffer = 0 })
    vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", { silent = true, noremap = true, buffer = 0 })
  end,
})

vim.keymap.set("n", "<leader>n", function()
  local qf_exists = false
  local info = vim.fn.getwininfo()
  if info == nil then
    return
  end
  for _, win in pairs(info) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    return vim.cmd("cclose")
  end
  local info = vim.fn.getwininfo()
  if info == nil then
    return
  end
  if not vim.tbl_isempty(info) then
    return vim.cmd("copen")
  end
end, {})

-- }}}

function format(opts)
  opts = opts or {}
  -- only for files
  if vim.bo.buftype ~= "" then
    return
  end

  -- pcall(function()
  require("conform").format({
    async = true,
    lsp_fallback = true,
    timeout_ms = 500,
  }, opts.callback)
  -- end)
end

vim.api.nvim_create_user_command("Format", format, {})
vim.api.nvim_create_user_command("FormatAndSave", function()
  format({
    callback = function()
      save()
    end,
  })
end, {})

function organize_imports()
  if
    vim.bo.filetype == "typescript"
    or vim.bo.filetype == "typescriptreact"
    or vim.bo.filetype == "javascript"
    or vim.bo.filetype == "javascriptreact"
  then
    require("typescript-tools.api").add_missing_imports(true)
    -- requireTSToolsRemoveUnusedImports("typescript-tools.api").organize_imports(true)
    require("typescript-tools.api").remove_unused_imports(true)
  end
end

function save()
  -- only for files
  if vim.bo.buftype ~= "" then
    return
  end
  local filename = vim.api.nvim_buf_get_name(0)
  if filename == "" then
    return
  end
  if not vim.opt.modified:get() then
    return
  end
  if vim.fn.filereadable(filename) ~= 1 then
    return
  end
  vim.cmd.write({ mods = { silent = true } })
end

-- format on explicit save
vim.keymap.set("n", "<leader>w", save, {})
-- auto-save on focus lost/buffer change
vim.o.autowriteall = true
vim.api.nvim_create_autocmd("FocusLost", {
  group = "default",
  callback = save,
})

-- show command bar message when recording macros
-- https://github.com/neovim/neovim/issues/19193
vim.api.nvim_create_autocmd("RecordingEnter", { group = "default", command = "set cmdheight=1" })
vim.api.nvim_create_autocmd("RecordingLeave", { group = "default", command = "set cmdheight=0" })

-- move cursor and scroll by a fixed distance, with center support
function Jump(distance, center)
  local view_info = vim.fn.winsaveview()
  if view_info == nil then
    return
  end

  local height = vim.fn.winheight(0)
  local cursor_row = view_info.lnum
  local buffer_lines = vim.fn.line("$")

  local target_row = math.min(cursor_row + distance, buffer_lines)
  if center then
    -- scroll center cursor
    view_info.topline = target_row - math.floor(height / 2)
  else
    -- scroll by distance
    view_info.topline = math.max(view_info.topline + distance, 1)
  end
  -- avoid scrolling past last line
  view_info.topline = math.min(view_info.topline, math.max(buffer_lines - height - 6, 1))
  view_info.lnum = target_row

  vim.fn.winrestview(view_info)
end

vim.keymap.set("n", "<C-u>", function()
  Jump(math.max(vim.v.count, 1) * -18, true)
end, {})
vim.keymap.set("n", "<C-d>", function()
  Jump(math.max(vim.v.count, 1) * 18, true)
end, {})
vim.keymap.set("n", "<C-b>", function()
  Jump(math.max(vim.v.count, 1) * -32, true)
end, {})
vim.keymap.set("n", "<C-f>", function()
  Jump(math.max(vim.v.count, 1) * 32, true)
end, {})

vim.keymap.set("n", "<C-y>", function()
  Jump(math.max(vim.v.count, 1) * -3)
end, {})
vim.keymap.set("n", "<C-e>", function()
  Jump(math.max(vim.v.count, 1) * 3)
end, {})

-- paste with indent by default, this needs to be after plugins
vim.keymap.set("n", "p", "]p=`]", { silent = true, noremap = true })
vim.keymap.set("n", "<S-p>", "]P=`]", { silent = true, noremap = true })

-- restore substitute functionality
vim.keymap.set("x", "z", "s", { noremap = true })

-- set foldmethod since its being overriden by plugins
vim.opt.foldmethod = "indent"

-- TODO more plugins!
-- https://neovimcraft.com/plugin/jackMort/ChatGPT.nvim
-- https://neovimcraft.com/plugin/folke/noice.nvim
-- rust
-- https://github.com/Saecki/crates.nvim
-- https://neovimcraft.com/plugin/simrat39/rust-tools.nvim

-- vim.api.nvim_create_autocmd("User", {
-- 	pattern = "SuperLazy",
-- 	group = "default",
-- 	callback = function()
-- 		print("hello")
-- 	end,
-- })

-- vim.api.nvim_create_autocmd("BufEnter", {
-- 	group = "default",
-- 	callback = function()
-- 		local uv = vim.loop
-- 		local timer = uv.new_timer()
-- 		timer:start(
-- 			1000,
-- 			0,
-- 			vim.schedule_wrap(function()
-- 				print("?")
-- 				-- vim.api.nvim_exec_autocmds("User", { pattern = "SuperLazy" })
-- 				-- vim.api.nvim_exec
-- 				vim.api.nvim_command("LazyLoad")
-- 			end)
-- 		)
-- 	end,
-- })


-- change outer function
vim.keymap.set({ "n" }, "caf", function()
  local cr = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys("/("..cr..esc.."va(obs", "m", true)
end)

-- delete inner function
vim.keymap.set({ "n" }, "dif", function()
  local cr = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys("/("..cr..esc.."ds(db", "m", true)
end)

-- delete outer function
vim.keymap.set({ "n" }, "daf", function()
  local cr = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys("/("..cr..esc.."da(db", "m", true)
end)

vim.keymap.set({ "n", "i" }, "<C-b>", function()
  -- local lsp_node_type_data = ""
  local lsp_update_node_type = function(cb)
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local bufname = vim.api.nvim_buf_get_name(bufnr)

    local params = {
      textDocument = { uri = "file://" .. bufname },
      position = { line = cursor[1] - 1, character = cursor[2] },
    }

    vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(err, result, _, _)
      if err then
        error(tostring(err))
      end

      if not result then
        -- lsp_node_type_data = ""
        return
      end
      -- lsp_node_type_data = result
      cb(result)
    end)
  end

  local parse_lsp_node_type = function(lsp_node_type_data)
    local contents = lsp_node_type_data.contents

    if contents == nil then
      return nil, nil
    end

    local lsp_node_type_markdown = contents[1].value

    if lsp_node_type_markdown == nil then
      return nil, nil
    end

    local doc = string.match(lsp_node_type_markdown, "```(.*)```")
    local first_line = string.match(doc, "%w*\n([^\n]*)")
    -- notify(first_line)

    -- TODO implement various languages
    -- https://github.com/roobert/node-type.nvim/blob/32c30958f6f49776855cc4ee25f0c5fcf4a5ea6e/lua/node-type/init.lua

    -- typescript
    -- local node_type = string.match(first_line, "%(([^)]*)%).*")
    local type = string.match(first_line, ": (.*)")
    notify(type)

    -- local first_line_fingerprint = string.gsub(first_line, "%([^)]*%) ", "")
    -- local first_line_fingerprint_components = vim.split(first_line_fingerprint, " ")
    -- local node_kind
    --
    -- if first_line_fingerprint_components[2] == "->" then
    --   node_kind = first_line_fingerprint_components[3]
    -- else
    --   node_kind = first_line_fingerprint_components[2]
    --   if node_kind then
    --     node_kind = string.match(node_kind, "(%w*)")
    --   end
    -- end
    --
    -- return node_kind, node_type
  end

  lsp_update_node_type(parse_lsp_node_type)
end, {})
