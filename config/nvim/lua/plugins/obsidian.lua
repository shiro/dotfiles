vim.keymap.set("n", "gd", function()
  if require("obsidian").util.cursor_on_markdown_link() then
    return "<cmd>ObsidianFollowLink<CR>"
  else
    return "gd"
  end
end, { noremap = false, expr = true })

return {
  "obsidian-nvim/obsidian.nvim",
  lazy = true,
  ft = "markdown",
  cond = function() return vim.fn.getcwd() == vim.fn.expand("~/wiki") end,
  event = {
    "BufReadPre " .. vim.fn.expand("~") .. "/wiki/*.md",
    "BufNewFile " .. vim.fn.expand("~") .. "/wiki/*.md",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- TODO cmp
  },
  config = function()
    require("obsidian").setup({
      workspaces = { { name = "wiki", path = "~/wiki" } },
      ui = { enable = false },
      note_id_func = function(title) return title end,
      legacy_commands = false,
    })
  end,
}
