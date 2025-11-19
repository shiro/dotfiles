local get_selection = function()
  local mode = vim.fn.mode()
  local selection_start, selection_end
  if mode == "v" or mode == "V" or mode == "<C-v>" then
    selection_start, selection_end = vim.fn.getpos("v"), vim.fn.getpos(".")
  else
    selection_start, selection_end = vim.fn.getpos("'<"), vim.fn.getpos("'>")
  end
  selection_start, selection_end = { selection_start[2], selection_start[3] }, { selection_end[2], selection_end[3] }
  return selection_start, selection_end
end

local foo = function()
  local from, to = get_selection()

  local text = vim.fn.getregion({ 0, from[1], from[2], 0 }, { 0, to[1], to[2], 0 })
  if text == nil or #text ~= 1 then return end
  text = text[1]

  local hex = text:match("^#%x%x%x%x%x%x$")
  if hex == nil then hex = text:match("^#%x%x%x$") end

  local r, g, b
  if #hex == 7 then
    r, g, b = tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
  elseif #hex == 4 then
    r, g, b = tonumber(hex:sub(2, 2), 16) * 17, tonumber(hex:sub(3, 3), 16) * 17, tonumber(hex:sub(4, 4), 16) * 17
  else
    return
  end

  vim.api.nvim_buf_set_text(
    0,
    from[1] - 1,
    from[2] - 1,
    to[1] - 1,
    to[2],
    { string.format("rgb(%d, %d, %d)", r, g, b) }
  )

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end

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
              command = function() vim.cmd("AvanteChatNew") end,
              keymaps = { { "n", "<leader>i" } },
            },
            ["Toggle outline"] = { command = function() require("aerial").toggle() end },
            ["Convert selection color to rgb"] = {
              -- condition = function()
              -- local sel = get_selection()
              -- return #sel == 1 and (sel[1]:match("^#%x%x%x%x%x%x$") ~= nil or sel[1]:match("^#%x%x%x$") ~= nil)
              -- end,
              command = foo,
            },
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
            ["Review PR"] = { command = function() vim.cmd("Octo review") end },
            ["Open PR"] = { command = function() vim.cmd("Octo pr") end },
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
            },
            ["Rename directory"] = {
              command = function() require("utils.typescript").rename_directory() end,
            },
            ["Rename file"] = {
              ft = { "typescriptreact", "typescript" },
              command = function() require("typescript-tools.api").rename_file(true) end,
            },
            ["Open file explorer"] = {
              -- condition = function()
              --   return true
              -- end,
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
      vim.api.nvim_create_user_command("Omnibar", function()
        -- require("telescope.Omnibar").load_command()
        telescope.extensions.omnibar.omnibar()
      end, {})
      vim.keymap.set("n", "<leader>f", function() builtin.resume() end, {})

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
          builtin.git_bcommits({
            layout_strategy = layout(),
          })
        end,
        {}
      )

      vim.keymap.set(
        "x",
        "<leader>h",
        function()
          builtin.git_bcommits_range({
            layout_strategy = layout(),
          })
        end,
        {}
      )

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

      vim.api.nvim_create_user_command("Highlights", "lua require('telescope.builtin').highlights()", {})

      -- open last file if called using `v` and no arguments were passed
      if vim.env.OPEN_LAST == "1" and vim.fn.argv(0) == "" then
        vim.schedule(function()
          require("top-results-sorter").load_history("file")
          local path = require("top-results-sorter").Recent["file"].latest
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

local push_current_path = function()
  -- use relative path to save disc space
  local path = vim.fn.expand("%:.")
  -- local path = vim.api.nvim_buf_get_name(0)
  -- print("push " .. path)
  if path ~= "" then require("top-results-sorter").PushRecent("file", path) end
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

local first_run = true

vim.api.nvim_create_autocmd("BufEnter", {
  callback = vim.schedule_wrap(function()
    if first_run then
      first_run = false
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

local make_callback = function(callback)
  local mode = vim.fn.mode()
  local is_visual = mode == "v" or mode == "V" or mode == "<C-v>"

  return function(motion)
    if is_visual then
      local starting, ending = get_selection()
      local count = ending[2] - starting[2]
      vim.cmd(string.format("normal! v%dl", count))

      callback()

      vim.schedule(function()
        starting, ending = get_selection()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
        vim.fn.cursor(starting[1], starting[2])
      end)
    else
      callback()
    end
  end
end

local repeatable = function(callback)
  return function()
    _G.callback = make_callback(callback)
    vim.go.operatorfunc = "v:lua.callback"

    local mode = vim.fn.mode()
    local is_visual = mode == "v" or mode == "V" or mode == "<C-v>"

    if is_visual then return "g@" end
    return "g@l"
  end
end

vim.keymap.set("n", "gw", repeatable(foo), { expr = true })
vim.keymap.set("x", "gw", repeatable(foo), { expr = true })

-- vim.keymap.set("x", "gw", "<ESC><CMD>lua _G.main_func(vim.fn.visualmode())<CR>")

-- vim.keymap.set("x", "gt", "<ESC><CMD>lua _G.__dot_repeat(vim.fn.visualmode())<CR>") -- 1.

return M
