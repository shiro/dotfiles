local M = {
  {
    "stevearc/aerial.nvim",
    opts = {
      highlight_on_hover = true,
      autojump = true,
      close_on_select = true,
      disable_max_lines = 200000000,
      disable_max_size = 200000000,
      backends = {
        octo = { "octo" },
        _ = { "treesitter", "lsp", "markdown", "asciidoc", "man" },
      },
      -- Override highlight for resolved threads to use grey (comment color)
      get_highlight = function(symbol, is_icon, is_collapsed)
        -- Check if this symbol or any of its parents is resolved
        local current = symbol
        while current do
          if current._is_resolved then
            return is_icon and "AerialResolvedIcon" or "AerialResolved"
          end
          current = current.parent
        end
      end,
    },
    config = function(_, opts)
      require("aerial").setup(opts)
      
      -- Define custom highlight groups for resolved threads using comment color
      local comment_hl = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
      vim.api.nvim_set_hl(0, "AerialResolved", {
        fg = comment_hl.fg,
        ctermfg = comment_hl.cterm and comment_hl.cterm.ctermfg,
        blend = comment_hl.blend,
      })
      vim.api.nvim_set_hl(0, "AerialResolvedIcon", { link = "AerialResolved" })
      
      local backends = require("aerial.backends")
      local original_get = backends.get_backend_by_name
      backends.get_backend_by_name = function(name)
        if name == "octo" then
          return require("aerial-backends.octo")
        end
        return original_get(name)
      end
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
}

return M
