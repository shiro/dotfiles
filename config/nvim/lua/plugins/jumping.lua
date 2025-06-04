local M = {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
      local flash = require("flash")

      ---@diagnostic disable: missing-fields
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
        },
      })

      local remote_action = function(action, opts)
        opts = opts or {}
        if opts.restore == nil then opts.restore = true end

        local count = vim.v.count
        local restore = opts.restore
        local immediate = opts.immediate or false

        local view_info = vim.fn.winsaveview()

        require("flash").jump()

        -- quit if aborted (position didn't change)
        local after_view_info = vim.fn.winsaveview()
        if after_view_info.col == view_info.col and after_view_info.lnum == view_info.lnum then return end

        if count > 0 then vim.fn.feedkeys(count) end
        vim.fn.feedkeys(action)

        if not restore then return end

        if immediate then
          vim.schedule(function() vim.fn.winrestview(view_info) end)
          return
        end

        vim.schedule(function()
          vim.api.nvim_create_autocmd({ "TextChanged", "ModeChanged" }, {
            callback = function()
              local m1 = vim.v.event.old_mode
              local m2 = vim.v.event.new_mode

              if m2 == "i" then return end
              if m1 == "i" and m2 == "niI" then return end

              vim.schedule(function() vim.fn.winrestview(view_info) end)
              return true
            end,
          })
        end)
      end

      local text_objects = {
        "C",
        "D",
        "W",
        "E",
        "a(",
        "a)",
        "aa",
        "ab",
        "e",
        "s.",
        "af",
        "aq",
        "at",
        "a{",
        "a}",
        "c",
        "d",
        "f.",
        "i(",
        "i)",
        "i[",
        "i]",
        "a[",
        "a]",
        "iW",
        "ia",
        "ib",
        "if",
        "iq",
        "it",
        "iw",
        "i{",
        "i}",
        "a|",
        "i|",
        "t.",
        "w",
        "y",
        "$",
      }

      for _, tobj in ipairs(text_objects) do
        for _, prefix in ipairs({ "y", "c", "d", "v" }) do
          for _, mode in ipairs({ "r", "m" }) do
            local tobj_with_r = prefix .. mode .. tobj:gsub("%.", "")
            vim.keymap.set({ "n" }, tobj_with_r, function()
              local suffix = ""
              if tobj:sub(2, 2) == "." then
                char = vim.fn.getchar()
                if char == 27 then return end
                suffix = vim.fn.nr2char(char)
              end

              local restore = mode ~= "m"
              local immediate = prefix == "y" or prefix == "d"

              remote_action(prefix .. tobj:gsub("%.", "") .. suffix, { restore = restore, immediate = immediate })
            end)
          end
        end
      end

      vim.keymap.set({ "n" }, "grC", function() remote_action("C") end)
      vim.keymap.set({ "n" }, "grD", function() remote_action("D") end)
      vim.keymap.set({ "n" }, "grV", function() remote_action("V") end)
      vim.keymap.set({ "n" }, "gmV", function() remote_action("V", { restore = false }) end)
      vim.keymap.set({ "n" }, "grd", function() remote_action("gd") end)
      vim.keymap.set({ "n" }, "grcc", function() remote_action("gcc", { immediate = true }) end)
      vim.keymap.set({ "n" }, "gmcc", function() remote_action("gcc", { restore = false }) end)
      -- vim.keymap.set({ "n" }, "drD", function()
      --   remote_action("D", { immediate = true })
      -- end)
      -- vim.keymap.set({ "n" }, "ymD", function()
      --   remote_action("D")
      -- end)
    end,
    keys = {
      {
        "s",
        mode = { "n", "o" },
        function() require("flash").jump() end,
        desc = "Flash",
      },
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
    init = function() vim.g["incsearch#auto_nohlsearch"] = 1 end,
  },
}

return M
