local M = {
  {
    "tpope/vim-fugitive",
    -- lazy = true,
    -- keys = {
    -- 	{ "<leader>gd", ":Gdiff<CR>" },
    -- },
    init = function()
      vim.opt.diffopt = vim.opt.diffopt + "vertical"

      vim.keymap.set("n", "<leader>gd", ":Gdiff<CR>", {})
      -- nnoremap <leader>ga :Git add %:p<CR><CR>
      -- nnoremap <leader>gs :Gstatus<CR>
      -- nnoremap <leader>gc :Gcommit -v -q<CR>
      -- nnoremap <leader>gt :Gcommit -v -q %:p<CR>
      -- nnoremap <leader>ge :Gedit<CR>
      -- "nnoremap <leader>gr :Gread<CR>
      -- nnoremap <leader>gw :Gwrite<CR><CR>
      -- nnoremap <leader>gl :silent! Glog<CR>:bot copen<CR>
      -- nnoremap <leader>gp :Ggrep<Space>
      -- "nnoremap <leader>gm :Gmove<Space>
      -- nnoremap <leader>gb :Git branch<Space>
      -- nnoremap <leader>go :Git checkout<Space>
      -- nnoremap <leader>gps :Dispatch! git push<CR>
      -- nnoremap <leader>gpl :Dispatch! git pull<CR>

      -- " 72 is the number
      -- autocmd Filetype gitcommit setlocal spell textwidth=72
      -- " auto cleanup buffers
      -- autocmd BufReadPost fugitive://* set bufhidden=delete
    end,
  },
  -- {
  --   "NeogitOrg/neogit",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim", -- required
  --     "sindrets/diffview.nvim", -- optional - Diff integration
  --
  --     -- Only one of these is needed.
  --     "nvim-telescope/telescope.nvim", -- optional
  --     -- "ibhagwan/fzf-lua",              -- optional
  --     -- "echasnovski/mini.pick",         -- optional
  --     -- "folke/snacks.nvim",             -- optional
  --   },
  --
  --   setup = function()
  --     local neogit = require("neogit")
  --     neogit.setup()
  --   end,
  -- },
  -- TODO try https://github.com/lewis6991/gitsigns.nvim
  {
    "airblade/vim-gitgutter",
    init = function()
      vim.g.gitgutter_map_keys = 0
      vim.g.gitgutter_show_msg_on_hunk_jumping = 0
      -- vim.g["gitgutter_signs"] = 0
      vim.g.gitgutter_highlight_linenrs = 1
      vim.g.gitgutter_sign_allow_clobber = 0
      vim.g.gitgutter_sign_removed = "⠀"
      vim.g.gitgutter_sign_added = "⠀"
      vim.g.gitgutter_sign_modified = "⠀"
      vim.g.gitgutter_sign_removed = "⠀"
      vim.g.gitgutter_sign_removed_first_line = "⠀"
      vim.g.gitgutter_sign_removed_above_and_below = "⠀"
      vim.g.gitgutter_sign_modified_removed = "⠀"
    end,
    config = function()
      -- nnoremap <leader>gh <Plug>(GitGutterPreviewHunk)
      vim.api.nvim_set_keymap("n", "<C-A-Z>", "<Plug>(GitGutterUndoHunk)", { silent = true })
      vim.api.nvim_set_keymap(
        "n",
        "[c",
        "<Plug>(GitGutterPrevHunk) | :let g:gitgutter_floating_window_options['border'] = 'rounded'<CR> | <Plug>(GitGutterPreviewHunk)",
        { silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "]c",
        "<Plug>(GitGutterNextHunk) | :let g:gitgutter_floating_window_options['border'] = 'rounded'<CR> | <Plug>(GitGutterPreviewHunk)",
        { silent = true }
      )
    end,
  },
}

return M
