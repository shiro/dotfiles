local M = {
  {
    name = "omnibar",
    dir = "~/.dotfiles/config/nvim/lua/omnibar",
    -- dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
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
        extensions = {
          omnibar = {
            ["Inspect treesitter nodes"] = { command = function() vim.cmd("InspectTree") end },
            ["Toggle outline"] = { command = function() require("aerial").toggle() end },
            ["Toggle statusline"] = {
              command = function()
                if vim.opt.laststatus:get() == 0 then
                  vim.opt.laststatus = 3
                else
                  vim.opt.laststatus = 0
                end
              end,
            },
            ["Jump to Obsidian tag"] = { ft = { "markdown" }, command = function() vim.cmd("ObsidianTags") end },
            ["New Obsidian note"] = { ft = { "markdown" }, command = function() vim.cmd("ObsidianNew") end },
            ["Format buffer"] = { command = function() vim.g.format() end },
            ["Toggle block split"] = { command = function() require("treesj").toggle() end },
            ["Remove unused imports"] = {
              ft = { "typescriptreact", "typescript" },
              command = function() require("typescript-tools.api").remove_unused_imports() end,
            },
            ["Rename file"] = {
              ft = { "typescriptreact", "typescript" },
              command = function() require("typescript-tools.api").rename_file(true) end,
            },
            ["Open file explorer"] = {
              -- ft = { "typescriptreact" },
              -- condition = function()
              --   return true
              -- end,
              command = function() vim.api.nvim_command("RnvimrToggle") end,
            },
            -- ["Open file explorer2"] = {
            --   command = function()
            --     print(88)
            --   end,
            -- },
          },
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
      require("telescope").load_extension("omnibar")

      local tele_builtin = require("telescope.builtin")
      local actions = require("telescope.actions")
      local make_entry = require("telescope.make_entry")

      function layout()
        local width = vim.fn.winwidth(0)
        local height = vim.fn.winheight(0)

        if (width / 2) > height then return "horizontal" end
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
            sorter = require("top-results-sorter").sorter(),
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

      vim.api.nvim_create_user_command("Files", function() files() end, {})
      vim.api.nvim_create_user_command("Omnibar", function()
        -- require("telescope.Omnibar").load_command()
        require("telescope").extensions.omnibar.omnibar()
      end, {})
      vim.keymap.set("n", "<leader>f", function() tele_builtin.resume() end, {})

      vim.keymap.set(
        "n",
        "<leader>F",
        function()
          require("telescopePickers").prettyGrepPicker({
            picker = "live_grep",
            options = { layout_strategy = layout() },
          })
        end,
        {}
      )
      vim.keymap.set(
        "n",
        "<leader>s",
        function()
          require("telescopePickers").prettyWorkspaceSymbolsPicker({
            sorter = sorter,
            prompt_title = "Workspace symbols",
            layout_strategy = layout(),
          })
        end,
        {}
      )
      vim.keymap.set(
        "n",
        "<leader>d",
        function()
          require("telescopePickers").prettyGitPicker({
            sorter = sorter,
            layout_strategy = layout(),
          })
        end,
        {}
      )
      vim.keymap.set(
        "n",
        "<leader>h",
        function()
          tele_builtin.git_bcommits({
            layout_strategy = layout(),
          })
        end,
        {}
      )

      vim.keymap.set(
        "x",
        "<leader>h",
        function()
          tele_builtin.git_bcommits_range({
            layout_strategy = layout(),
          })
        end,
        {}
      )

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

      -- open last file if none was specified
      if vim.fn.argv(0) == "" then
        vim.schedule(function()
          require("top-results-sorter").load_history()
          local path = require("top-results-sorter").Recent.latest
          if path ~= nil and vim.uv.fs_stat(path) then vim.schedule(function() vim.cmd("e " .. path) end) end
        end)
      end
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },
}

return M
