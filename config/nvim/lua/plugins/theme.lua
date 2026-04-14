local M = {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    init = function()
      require("catppuccin").setup({
        flavour = "macchiato",
        transparent_background = true,
        auto_integrations = true,
        custom_highlights = function(colors)
          return {
            NormalFloat = { bg = colors.base },
            Pmenu = { bg = colors.base },
            Float = { bg = colors.base },
            FloatBorder = { bg = colors.base },
            TelescopePromptBorder = { bg = colors.base },
            TelescopeBorder = { bg = colors.base },
            TelescopeTitle = { bg = "NONE" },
            -- Ensure other popup titles have no background
            FloatTitle = { bg = "NONE" },

            String = { fg = colors.flamingo },
            -- ["@lsp.type.enumMember"] = { fg = colors.yellow },
            -- ["@function.macro"] = { fg = colors.yellow },
            -- ["@property"] = { fg = colors.pink },
            -- ["@variable"] = { fg = colors.maroon },
            -- ["@variable"] = { fg = colors.maroon },
            -- ["@module"] = { fg = colors.flamingo },
            -- Type = { fg = colors.mauve },
            -- Function = { fg = colors.green },
            -- Number = { fg = colors.yellow },
            -- Keyword = { fg = colors.rosewater },
            -- Number = { link = "String" },

            -- ["@lsp.type.variable.readonly.local"] = { fg = colors.sapphire },
            -- ["@lsp.type.variable.declaration.readonly.local"] = { fg = colors.sapphire },
            -- ["@variable.parameter"] = { fg = colors.red },

            Function = { fg = colors.peach },

            -- typescriptVariableDeclaration = { fg = colors.red },
            ["@tag"] = { fg = colors.blue },
            ["@tag.attribute"] = { fg = colors.sky },
            ["@tag.builtin"] = { link = "@tag" },
            ["@tag.delimiter"] = { link = "@tag" },

            -- status bar
            WinSeparator = { fg = colors.overlay0 },
            StatusLine = { fg = colors.overlay0 },
            StatusLineNC = { fg = colors.overlay0 },

            -- gutter
            DiagnosticSignError = { fg = colors.overlay0 },
            DiagnosticSignHint = { fg = colors.overlay0 },
            DiagnosticSignWarn = { fg = colors.overlay0 },
            DiagnosticSignInfo = { fg = colors.overlay0 },

            DiagnosticUnderlineWarn = { fg = colors.overlay2 },
            DiagnosticUnderlineError = { fg = colors.red },
          }
        end,
      })

      vim.cmd.colorscheme("catppuccin-nvim")
    end,
  },
}

require("../utils").hot_reload_listen("catppuccin")

return M
