local M = {

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
      local registerMapping = function(mapping, target)
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
}
return M
