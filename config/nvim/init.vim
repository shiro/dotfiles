" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible


let &t_te.="\e[0 q"
let &t_SI.="\e[1 q"
let &t_EI.="\e[1 q"

" space is leader
nnoremap <Space> <Nop>
let mapleader = " "

" reload .vimrc
noremap <Leader><F1> :so $MYVIMRC<CR>
noremap <Leader><F2> :so ~/.config/nvim/ide.lua<CR>


source ~/.config/nvim/shared.vim
source ~/.config/nvim/shell.vim
source ~/.config/nvim/plugins.vim

if exists('g:vscode')
  source ~/.config/nvim/vscode.vim
endif
