local M = {
  {
    name = "omnibar",
    dir = "~/.dotfiles/config/nvim/lua/omnibar",
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
      local telescope = require("telescope")
      local telescope_actions = require("telescope.actions")

      local ts_select_dir_for_grep = function(prompt_bufnr)
        local action_state = require("telescope.actions.state")
        local fb = telescope.extensions.file_browser
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

      local select_one_or_multi = function(prompt_bufnr)
        local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
        local multi = picker:get_multi_selection()
        if not vim.tbl_isempty(multi) then
          require("telescope.actions").close(prompt_bufnr)
          for _, j in pairs(multi) do
            if j.path ~= nil then vim.cmd(string.format("%s %s", "edit", j.path)) end
          end
        else
          require("telescope.actions").select_default(prompt_bufnr)
        end
      end

      local pick_git_branch = function(callback)
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        -- get all branches
        local handle = io.popen("git branch -a --format='%(refname:short)'")
        local branches = {}
        if handle then
          for line in handle:lines() do
            if line ~= "" then table.insert(branches, line) end
          end
          handle:close()
        end

        -- pick a branch
        pickers
          .new({}, {
            prompt_title = "Select Branch",
            finder = finders.new_table({
              results = branches,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, map)
              actions.select_default:replace(function()
                local selected_branch = action_state.get_selected_entry()
                actions.close(prompt_bufnr)

                if selected_branch then callback(selected_branch.value) end
              end)
              return true
            end,
          })
          :find()
      end

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<esc>"] = telescope_actions.close,
              ["<CR>"] = select_one_or_multi,
            },
            n = {
              -- ["<c-d>"] = require("telescope.actions").delete_buffer,
            },
          },
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
            ["Run treesitter query"] = {
              command = function()
                vim.cmd("InspectTree")
                vim.cmd("EditQuery")
              end,
            },
            ["Diff with branch"] = { command = function() require("plugins.commands.diff-branch")() end },
            ["Get highlight group under cursor"] = { command = function() vim.cmd("Inspect") end },
            ["Switch AI model"] = { command = function() require("avante.api").select_model() end },
            ["Close all other buffers"] = { command = function() vim.cmd("%bd!|e#|bd#") end },
            ["New AI chat"] = {
              command = function() require("avante.api").ask({ new_chat = true }) end,
              keymaps = { { "n", "<leader>i" } },
            },
            ["Open AI chat"] = {
              command = function() require("avante.api").ask() end,
              keymaps = { { "n", "<leader>aa" } },
            },
            ["AI chat history"] = { command = function() require("avante.api").select_history() end },
            ["Edit with AI"] = {
              command = function() require("avante.api").edit() end,
              keymaps = { { "v", "<leader>ae" } },
            },
            ["Toggle outline"] = { command = function() require("aerial").toggle() end },
            ["Show git blame"] = { command = function() vim.cmd("Git blame") end },
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
            ["Close tab"] = { command = function() vim.cmd("tabclose") end },
            ["Go to next tab"] = { command = function() vim.cmd("tabnext") end },
            ["Toggle color inspector"] = {
              command = function() require("utils.color-inspector").toggle() end,
            },
            ["Review PR"] = { command = function() vim.cmd("Octo review") end },
            ["Show PR"] = { command = function() vim.cmd("Octo pr") end },
            ["Change git signs base branch"] = {
              command = function()
                pick_git_branch(function(branch_name) require("gitsigns").change_base(branch_name, true) end)
              end,
            },
            ["Github notifications"] = { command = function() vim.cmd("Octo notification list") end },
            ["Browse files on branch"] = {
              command = function()
                pick_git_branch(function(branch_name)
                  -- Open file browser for the selected branch
                  require("telescope.builtin").find_files({
                    prompt_title = "Files on " .. branch_name,
                    cwd = vim.fn.getcwd(),
                    find_command = { "git", "ls-tree", "-r", "--name-only", branch_name },
                    attach_mappings = function(prompt_bufnr, map)
                      require("telescope.actions").select_default:replace(function()
                        local entry = require("telescope.actions.state").get_selected_entry()
                        require("telescope.actions").close(prompt_bufnr)
                        -- Open file using fugitive
                        if entry then vim.cmd("Gedit " .. branch_name .. ":" .. entry.value) end
                      end)
                      return true
                    end,
                  })
                end)
              end,
            },
            ["Copy GitHub URL"] = {
              command = function()
                local file_path = vim.fn.expand("%:.")
                local line_number = vim.fn.line(".")
                local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
                local origin_url = vim.fn.systemlist("git config --get remote.origin.url")[1]
                local github_url = origin_url:gsub("^git@github.com:", "https://github.com/"):gsub("%.git$", "")
                local full_url = string.format("%s/blob/%s/%s#L%s", github_url, branch, file_path, line_number)
                vim.fn.setreg("+", full_url)
              end,
            },
            ["Format buffer"] = { command = function() vim.g.format() end },
            ["Buffers"] = { command = function() require("telescope.builtin").buffers() end },
            ["Toggle block split"] = { command = function() require("treesj").toggle() end },
            ["Remove unused imports"] = {
              ft = { "typescriptreact", "typescript" },
              command = function() require("typescript-tools.api").remove_unused_imports() end,
            },
            ["Organize imports"] = {
              ft = { "typescriptreact", "typescript" },
              command = function() require("typescript-tools.api").organize_imports() end,
              -- command = function()
              --   local params = {
              --     command = "_typescript.organizeImports",
              --     arguments = { vim.api.nvim_buf_get_name(0) },
              --     title = "",
              --   }
              --   vim.lsp.buf.execute_command(params)
              -- end,
            },
            ["Rename directory"] = {
              command = function() require("utils.typescript").rename_directory() end,
            },
            ["Rename file"] = {
              ft = { "typescriptreact", "typescript" },
              command = function() require("typescript-tools.api").rename_file(true) end,
            },
            ["Open file explorer"] = {
              command = function() vim.api.nvim_command("RnvimrToggle") end,
            },
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

      telescope.load_extension("zf-native")
      telescope.load_extension("file_browser")
      telescope.load_extension("omnibar")

      local builtin = require("telescope.builtin")

      function layout()
        local width = vim.fn.winwidth(0)
        local height = vim.fn.winheight(0)

        if (width / 2) > height then return "horizontal" end
        return "vertical"
      end

      function files(show_hidden)
        local find_command = { "rg", "--files", "-g", "!.git" }
        if show_hidden then table.insert(find_command, "--hidden") end

        require("telescopePickers").prettyFilesPicker({
          picker = "find_files",

          options = {
            sorter = require("top-results-sorter").sorter({ name = "file", most_recent_is_last = true }),
            previewer = false,
            layout_strategy = layout(),
            find_command = find_command,
            attach_mappings = function(_, map)
              map("n", "zh", function(prompt_bufnr)
                require("telescope.actions").close(prompt_bufnr)
                files(not show_hidden)
              end)
              return true
            end,
          },
        })
      end

      vim.api.nvim_create_user_command("Files", function() files() end, {})
      vim.api.nvim_create_user_command("Omnibar", function() telescope.extensions.omnibar.omnibar() end, {})
      vim.keymap.set("n", "<leader>f", function() builtin.resume() end, {})

      vim.keymap.set(
        "n",
        "<leader>F",
        function()
          require("telescopePickers").prettyGrepPicker({
            picker = "live_grep",
            options = {
              layout_strategy = layout(),
              layout_config = {
                width = 0.95,
                height = 0.95,
              },
            },
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
      vim.keymap.set("n", "<leader>hh", function() builtin.git_bcommits({ layout_strategy = layout() }) end, {})
      vim.keymap.set("x", "<leader>hh", function() builtin.git_bcommits_range({ layout_strategy = layout() }) end, {})

      vim.keymap.set("n", "gr", function()
        vim.api.nvim_command("m'")
        builtin.lsp_references({
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

      vim.keymap.set(
        { "n", "v" },
        "<leader>k",
        function() require("telescope").extensions.omnibar.omnibar() end,
        { silent = true }
      )

      vim.api.nvim_create_user_command("Highlights", "lua require('telescope.builtin').highlights()", {})

      -- open last file if called using `v` and no arguments were passed
      if not _G.opened_last_file then
        _G.opened_last_file = true

        if vim.env.OPEN_LAST == "1" and vim.fn.argv(0) == "" then
          vim.schedule(function()
            require("top-results-sorter").load_history("file")
            local path = require("top-results-sorter").Recent["file"].latest
            if path ~= nil and vim.uv.fs_stat(path) then vim.schedule(function() vim.cmd("e " .. path) end) end
          end)
        end
      end
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },
}

local push_current_path = function()
  -- use relative path to save disc space
  local relative_path = vim.fn.expand("%:.")
  if relative_path == "" then return end

  -- don't add files not under current working directory
  if not vim.startswith(vim.fn.fnamemodify(relative_path, ":p"), vim.fn.getcwd()) then return end

  require("top-results-sorter").PushRecent("file", relative_path)
end

vim.api.nvim_create_autocmd({ "FocusGained" }, {
  callback = function()
    require("top-results-sorter").load_history("file")
    push_current_path()
  end,
})

vim.api.nvim_create_autocmd({ "VimLeave", "FocusLost" }, {
  callback = function() require("top-results-sorter").save_history("file") end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = vim.schedule_wrap(function()
    if not _G.last_file_list_loaded then
      _G.last_file_list_loaded = true
      require("top-results-sorter").load_history("file")
      push_current_path()
      return
    end
    push_current_path()
  end),
})

-- https://www.vikasraj.dev/blog/vim-dot-repeat
-- vim.keymap.set({ "v" }, "gw", function() foo() end, {})

-- function _G.__dot_repeat(motion)
--   local is_visual = string.match(motion or "", "[vV]") -- 2.
--
--   if not is_visual and motion == nil then
--     vim.o.operatorfunc = "v:lua.__dot_repeat"
--     return "g@"
--   end
--
--   -- if is_visual then
--   --   print("VISUAL mode")
--   -- else
--   --   print("NORMAL mode")
--   -- end
--
--   -- starting = vim.api.nvim_buf_get_mark(0, is_visual and "<" or "["),
--   -- ending = vim.api.nvim_buf_get_mark(0, is_visual and ">" or "]"),
--   local starting, ending = get_selection()
--
--   print(vim.inspect({ starting, ending }))
-- end

-- local counter = 0
-- function _G.__dot_repeat(motion) -- 4.
--   -- if motion == nil then
--   --   vim.o.operatorfunc = "v:lua.__dot_repeat" -- 3.
--   --   return "g@" -- 2.
--   -- end
--   vim.o.operatorfunc = "v:lua.__dot_repeat" -- 3.
--
--   -- print("counter:", counter, "motion:", motion)
--   -- counter = counter + 1
-- end

-- vim.keymap.set("n", "gw", _G.__dot_repeat, { expr = true })
-- vim.keymap.set("x", "gt", "<ESC><CMD>lua _G.__dot_repeat(vim.fn.visualmode())<CR>") -- 1.
-- _G.my_count = 0

-- local make_callback = function(callback)
--   local mode = vim.fn.mode()
--   local is_visual = mode == "v" or mode == "V" or mode == "<C-v>"
--
--   return function(motion)
--     if is_visual then
--       local starting, ending = get_selection()
--       local count = ending[2] - starting[2]
--       vim.cmd(string.format("normal! v%dl", count))
--
--       callback()
--
--       vim.schedule(function()
--         starting, ending = get_selection()
--         vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
--         vim.fn.cursor(starting[1], starting[2])
--       end)
--     else
--       callback()
--     end
--   end
-- end

-- local repeatable = function(callback)
--   return function()
--     _G.callback = make_callback(callback)
--     vim.go.operatorfunc = "v:lua.callback"
--
--     local mode = vim.fn.mode()
--     local is_visual = mode == "v" or mode == "V" or mode == "<C-v>"
--
--     if is_visual then return "g@" end
--     return "g@l"
--   end
-- end

-- vim.keymap.set("n", "gw", repeatable(foo), { expr = true })
-- vim.keymap.set("x", "gw", repeatable(foo), { expr = true })

-- vim.keymap.set("x", "gw", "<ESC><CMD>lua _G.main_func(vim.fn.visualmode())<CR>")

-- vim.keymap.set("x", "gt", "<ESC><CMD>lua _G.__dot_repeat(vim.fn.visualmode())<CR>") -- 1.

require("../utils").hot_reload_listen("telescope.nvim")
require("../utils").hot_reload_listen("omnibar")

return M
