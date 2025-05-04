local M = {
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
  -- detect file shiftwidth, tab mode
  "tpope/vim-sleuth",
}
return M
