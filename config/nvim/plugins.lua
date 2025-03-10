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
    vim.schedule(function() callback(timer) end)
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
            function(config) return config.fill_char:rep(3) end,
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
    config = function() require("bqf").setup({ preview = { winblend = 0 } }) end,
  },
  -- }}}
  -- floating command line {{{
  -- require("plugins/noice.nvim")
  -- }}}
  -- chord keybinds {{{
  {
    "kana/vim-arpeggio",
    init = function()
      -- vim.g.arpeggio_timeoutlen = 40
    end,
    config = function()
      -- write
      vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'we', ':FormatAndSave<cr>')")
      -- write-quit
      vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'wq', ':wq<cr>')")
      -- write-quit-all
      vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'wr', ':wqa<cr>')")
      -- write-quit
      vim.api.nvim_command("silent call arpeggio#map('i', 's', 0, 'wq', '<ESC>:wq<CR>')")
      -- save
      vim.api.nvim_command("silent call arpeggio#map('i', 's', 0, 'jk', '<ESC>')")
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

      -- vim.api.nvim_command("Arpeggio nmap kl yiw")

      local id = 0
      registerMapping = function(mapping, target)
        id = id + 1
        vim.api.nvim_create_user_command("ArpeggioLeap" .. id, function()
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

      registerMapping("yw", "yiw\\<C-n>")
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
  -- }}}

  require("plugins.outline"),

  require("plugins.obsidian"),

  require("plugins.jumping"),
  require("plugins.lsp"),
  require("plugins.completion"),
  -- autoamtically rename JSX tags {{{
  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    opts = { enable_close = false },
    ft = { "typescriptreact", "javascriptreact" },
  },
  -- }}}
  require("plugins.language-typescript"),
  require("plugins.language-markdown"),
  require("plugins.copy-imports"),
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
  require("plugins.formatting"),
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
          expand = function(args) require("luasnip").lsp_expand(args.body) end,
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
          get_commit_characters = function(commit_characters) return {} end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-[>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-]>"] = cmp.mapping(function(fallback)
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
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "luasnip" },
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
  require("plugins.telescope"),
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
      vim.keymap.set("n", "<leader>l", function() vim.api.nvim_command("RnvimrToggle") end, {})
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
    config = function() require("crates").setup() end,
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
    config = function() require("gopher").setup({}) end,
    build = function() vim.cmd([[silent! GoInstallDeps]]) end,
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
    config = function() require("nvim-surround").setup({}) end,
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
    config = function() require("colorizer").setup({ user_default_options = { mode = "virtualtext", names = false } }) end,
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

-- vim.api.nvim_set_keymap("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
-- vim.api.nvim_set_keymap("n", "gi", "<Plug>(coc-implementation)", { silent = true })
vim.keymap.set("n", "<leader>[e", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<leader>]e", vim.diagnostic.goto_next)
vim.keymap.set("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end)
vim.keymap.set("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end)

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

-- tab/S-tab completion menu
function _G.check_back_space()
  local col = vim.fn.col(".") - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
end

-- code actions
vim.keymap.set({ "n", "v" }, "<space>a", vim.lsp.buf.code_action, { silent = true })
vim.keymap.set(
  { "n", "v" },
  "<space>k",
  function() require("telescope").extensions.omnibar.omnibar() end,
  { silent = true }
)
-- refactor
vim.keymap.set(
  { "n", "x" },
  "<leader>r",
  function() require("telescope").extensions.refactoring.refactors() end,
  { silent = true }
)
vim.api.nvim_create_user_command("RenameFile", "silent CocCommand workspace.renameCurrentFile", {})

local function quickfix()
  vim.lsp.buf.code_action({
    filter = function(a) return a.isPreferred end,
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
      if entries == nil then return end
      if #entries == 0 then return end
      -- remove the item from the quickfix list
      table.remove(entries, curqfidx)
      vim.fn.setqflist(entries, "r")
      -- reopen quickfix window to refresh the list
      vim.cmd("copen")
      local new_idx = curqfidx < #entries and curqfidx or math.max(curqfidx - 1, 1)
      local winid = vim.fn.win_getid()
      if winid == nil then return end
      vim.api.nvim_win_set_cursor(winid, { new_idx, 0 })
    end, { silent = true, noremap = true, buffer = 0 })
    vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", { silent = true, noremap = true, buffer = 0 })
  end,
})

vim.keymap.set("n", "<leader>n", function()
  local qf_exists = false
  local info = vim.fn.getwininfo()
  if info == nil then return end
  for _, win in pairs(info) do
    if win["quickfix"] == 1 then qf_exists = true end
  end
  if qf_exists == true then return vim.cmd("cclose") end
  local info = vim.fn.getwininfo()
  if info == nil then return end
  if not vim.tbl_isempty(info) then return vim.cmd("copen") end
end, {})

-- }}}

function format(opts)
  opts = opts or {}
  -- only for files
  if vim.bo.buftype ~= "" then return end

  -- pcall(function()
  require("conform").format({
    async = true,
    lsp_fallback = true,
    timeout_ms = 500,
  }, opts.callback)
  -- end)
end
vim.g.format = format

vim.api.nvim_create_user_command("Format", format, {})
vim.api.nvim_create_user_command("FormatAndSave", function() format({ callback = save }) end, {})

function organize_imports()
  if
    vim.bo.filetype == "typescript"
    or vim.bo.filetype == "typescriptreact"
    or vim.bo.filetype == "javascript"
    or vim.bo.filetype == "javascriptreact"
  then
    pcall(function()
      require("typescript-tools.api").add_missing_imports(true)
      -- requireTSToolsRemoveUnusedImports("typescript-tools.api").organize_imports(true)
      require("typescript-tools.api").remove_unused_imports(true)
    end)
  end
end

function save()
  -- only for files
  if vim.bo.buftype ~= "" then return end
  local filename = vim.api.nvim_buf_get_name(0)
  if filename == "" then return end
  if not vim.opt.modified:get() then return end
  if vim.fn.filereadable(filename) ~= 1 then return end
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
  if view_info == nil then return end

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

vim.keymap.set("n", "<C-u>", function() Jump(math.max(vim.v.count, 1) * -18, true) end, {})
vim.keymap.set("n", "<C-d>", function() Jump(math.max(vim.v.count, 1) * 18, true) end, {})
vim.keymap.set("n", "<C-b>", function() Jump(math.max(vim.v.count, 1) * -32, true) end, {})
vim.keymap.set("n", "<C-f>", function() Jump(math.max(vim.v.count, 1) * 32, true) end, {})

vim.keymap.set("n", "<C-y>", function() Jump(math.max(vim.v.count, 1) * -3) end, {})
vim.keymap.set("n", "<C-e>", function() Jump(math.max(vim.v.count, 1) * 3) end, {})

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
  vim.api.nvim_feedkeys("/(" .. cr .. esc .. "va(obs", "m", true)
end)

-- delete inner function
vim.keymap.set({ "n" }, "dif", function()
  local cr = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys("/(" .. cr .. esc .. "ds(db", "m", true)
end)

-- delete outer function
vim.keymap.set({ "n" }, "daf", function()
  local cr = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys("/(" .. cr .. esc .. "da(db", "m", true)
end)

require("keybinds.general")
require("keybinds.jsx")

-- local function lineinfo()
--   if vim.bo.filetype == "alpha" then return "" end
--   return " %P %l:%c "
-- end
-- Statusline = {}
-- Statusline.active = function()
--   return table.concat({
--     "%#Statusline#",
--     -- update_mode_colors(),
--     -- mode(),
--     "%#Normal# ",
--     -- filepath(),
--     -- filename(),
--     "%#Normal#",
--     -- lsp(),
--     "%=%#StatusLineExtra#",
--     -- filetype(),
--     lineinfo(),
--   })
-- end
-- function Statusline.inactive() return " %F" end
-- function Statusline.short() return "%#StatusLineNC#   NvimTree" end
-- vim.api.nvim_exec(
--   [[
-- augroup Statusline
-- au!
-- au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline.active()
-- au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline.inactive()
-- au WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.Statusline.short()
-- augroup END
-- ]],
--   false
-- )
