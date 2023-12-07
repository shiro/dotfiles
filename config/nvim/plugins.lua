local call = vim.call
local cmd = vim.cmd
local Plug = vim.fn['plug#']
local PATH = "~/.config/nvim/plugged"



call('plug#begin', PATH)
  Plug 'nvim-lua/plenary.nvim'
  Plug('ipod825/libp.nvim')
  Plug('ipod825/ranger.nvim', {branch = 'main'})
call'plug#end'

require("libp").setup()
require("ranger").setup()



