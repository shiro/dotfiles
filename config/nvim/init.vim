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


source ~/.config/nvim/plugins.vim
source ~/.config/nvim/shared.vim
source ~/.config/nvim/shell.vim
