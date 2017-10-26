" Section General {{{

colorscheme hyrule

set encoding=utf-8 " The encoding displayed.
set fileencoding=utf-8 " The encoding written to file.
 
set nocompatible " not compatible with vi
set autoread " detect when a file is changed
 
set history=1000 " change history to 1000
set textwidth=120

set backupdir=/tmp
set directory=/tmp
set undodir=/tmp
 
set termguicolors " enable 24bit truecolor support
 
" }}}

" User Interface {{{

" switch cursor to line when in insert mode, and block when not
set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:hor10-Cursor/lCullll,r-cr:hor10-Cursor/lCursor


if &term =~ '256color'
    set t_ut= " disable background color erase
endif


set viminfo+=n~/.localbin/.viminfo          " change .viminfo location


set t_Co=256 " Explicitly tell vim that the terminal supports 256 colors"


" Tab control
set noexpandtab " insert tabs rather than spaces for <Tab>
set smarttab " tab respects 'tabstop', 'shiftwidth', and 'softtabstop'
set tabstop=4 " the visible width of tabs
" set softtabstop=4 " edit as if the tabs are 4 characters wide
set shiftwidth=4 " number of spaces to use for indent and unindent
" set shiftround " round indent to a multiple of 'shiftwidth'
" set completeopt+=longest

set ttyfast " faster redrawing
" set diffopt+=vertical
" set laststatus=2 " show the satus line all the time
" set so=7 " set 7 lines to the cursors - when moving vertical
set showcmd " show incomplete commands
set scrolloff=3 " lines of text around cursor
set shell=$SHELL
" set cmdheight=1             " command bar height
" set title                   " set terminal title
" 
" " Searching
set nolazyredraw " don't redraw while executing macros

set noshowmode " don't show mode at the bottom

" error bells
" set visualbell
" set t_vb=
" set tm=500
" 
if has('mouse')
	set mouse=a
endif



" }}}
" 
" mappings {{{

" vimdiff

" if &diff
" 	nnoremap <C-[> :diffget<cr>
" 	vnoremap <C-[> :diffget<cr>:diffu<cr>

" 	nnoremap u u:diffu<cr>
" endif
" nnoremap <C-p> :diffput<cr>
" vnoremap <C-p> :diffput<cr>:diffu<cr>

" standaed diff commands made nicer
xnoremap dp :diffput<cr>:diffu<cr>
xnoremap do :diffget<cr>:diffu<cr>


" moving up and down work as you would expect
nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> ^ g^
nnoremap <silent> $ g$


" quickly paste from default buffer
inoremap <C-r><C-r> <C-r>*
cnoremap <C-r><C-r> <C-r>*

" wipout buffer
" nmap <silent> <leader>b :bw<cr>

" shortcut to save
" nmap <leader>, :w<cr>

" " set paste toggle
" set pastetoggle=<leader>v
" 
" " toggle paste mode
" " map <leader>v :set paste!<cr>
" 
" " edit ~/.config/nvim/init.vim
" map <leader>ev :e! ~/.config/nvim/init.vim<cr>
" " edit gitconfig
" map <leader>eg :e! ~/.gitconfig<cr>
" 
" " clear highlighted search
" noremap <space> :set hlsearch! hlsearch?<cr>
" 
" " activate spell-checking alternatives
" nmap ;s :set invspell spelllang=en<cr>
" 
" " markdown to html
" nmap <leader>md :%!markdown --html4tags <cr>
" 
" " remove extra whitespace
" nmap <leader><space> :%s/\s\+$<cr>
" nmap <leader><space><space> :%s/\n\{2,}/\r\r/g<cr>
" 
" " Textmate style indentation
" vmap <leader>[ <gv
" vmap <leader>] >gv
" nmap <leader>[ <<
" nmap <leader>] >>


" map <silent> <C-h> :call functions#WinMove('h')<cr>
" map <silent> <C-j> :call functions#WinMove('j')<cr>
" map <silent> <C-k> :call functions#WinMove('k')<cr>
" map <silent> <C-l> :call functions#WinMove('l')<cr>

" map <leader>wc :wincmd q<cr>
" 
" " toggle cursor line
" nnoremap <leader>i :set cursorline!<cr>


" " inoremap <tab> <c-r>=Smart_TabComplete()<CR>
" 
" map <leader>r :call RunCustomCommand()<cr>
" " map <leader>s :call SetCustomCommand()<cr>
" let g:silent_custom_command = 0
" 
" " helpers for dealing with other people's code
" nmap \t :set ts=4 sts=4 sw=4 noet<cr>
" nmap \s :set ts=4 sts=4 sw=4 et<cr>
" 
" nnoremap <silent> <leader>u :call functions#HtmlUnEscape()<cr>
" 
" " }}}

" Section AutoGroups {{{
" file type specific settings

augroup configgroup
    autocmd!

    " automatically resize panes on resize
    autocmd VimResized * exe 'normal! \<c-w>='

"     autocmd BufWritePost .vimrc,.vimrc.local,init.vim source %
"     autocmd BufWritePost .vimrc.local source %
"
    " save all files on focus lost, ignoring warnings about untitled buffers
    autocmd FocusLost * silent! wa

    " newline on a comment won't create a comment line
    autocmd Filetype * setlocal fo-=ro

"     " make quickfix windows take all the lower section of the screen
"     " when there are multiple windows open
"     autocmd FileType qf wincmd J
" 
"     autocmd BufNewFile,BufReadPost *.md set filetype=markdown
"     let g:markdown_fenced_languages = ['css', 'javascript', 'js=javascript', 'json=javascript', 'stylus', 'html']
" 
"     " autocmd! BufEnter * call functions#ApplyLocalSettings(expand('<afile>:p:h'))
" 
"     autocmd BufNewFile,BufRead,BufWrite *.md syntax match Comment /\%^---\_.\{-}---$/
" 
"     autocmd! BufWritePost * Neomake
augroup END

augroup AutoSaveFolds
    autocmd!
    autocmd BufWinLeave * mkview
    autocmd BufWinEnter *.* silent! loadview
augroup END

" }}}

" " make the highlighting of tabs and other non-text less annoying
" highlight SpecialKey ctermbg=none ctermfg=8
" highlight NonText ctermbg=none ctermfg=8
" 
" " make comments and HTML attributes italic
" highlight Comment cterm=italic
" highlight htmlArg cterm=italic

" set linebreak               " set soft wrapping
" set showbreak=[             " show ellipsis at breaking

" toggle invisible characters
" set list
" set listchars=tab:→\ ,eol:¬,trail:⋅,extends:❯,precedes:❮
" set showbreak=↪
" 
" " highlight conflicts
" match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'
" 
" " make backspace behave in a sane manner
" set backspace=indent,eol,start



" let g:python_host_prog = '/usr/local/bin/python'
" let g:python3_host_prog = '/usr/local/bin/python3'
 
" if (has('nvim'))
" 	" show results of substition as they're happening
" 	" but don't open a split
" 	set inccommand=nosplit
" endif



" " enable 24 bit color support if supported
" if (has('mac') && empty($TMUX) && has("termguicolors"))
"     set termguicolors
" endif

" let g:onedark_termcolors=16
" let g:onedark_terminal_italics=1
