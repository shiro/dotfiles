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
        lsp_styles = {
          enabled = true,
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
        },
        custom_highlights = function(colors)
          return {
            NormalFloat = { bg = "NONE" },
            Pmenu = { bg = "NONE" },
            Float = { bg = "NONE" },
            FloatBorder = { bg = "NONE" },
            TelescopePromptBorder = { bg = "NONE" },
            TelescopeBorder = { bg = "NONE" },
            TelescopeTitle = { bg = "NONE" },
            -- Ensure other popup titles have no background
            FloatTitle = { bg = "NONE" },

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
            -- ["@tag.delimiter"] = { link = "@tag" },

            String = { fg = colors.lavender },
            Delimiter = { link = "Normal" },
            Operator = { link = "Keyword" },
            Special = { link = "Keyword" },
            Constant = { fg = colors.rosewater },
            ["@variable"] = { fg = colors.flamingo },
            ["@variable.parameter"] = { fg = colors.pink },
            ["@punctuation.bracket"] = { link = "Normal" },
            ["@property"] = { fg = colors.pink },

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
            DiagnosticUnnecessary = { italic = true },
          }
        end,
      })

      vim.cmd.colorscheme("catppuccin-nvim")
    end,
  },
}

require("../utils").hot_reload_listen("catppuccin")

return M
