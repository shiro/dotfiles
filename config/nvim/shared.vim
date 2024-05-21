" mappings {{{

" todo double leader map
" noremap <Leader><Leader> V

" colemak
" nnoremap n j
" nnoremap e k
" nnoremap m h
" nnoremap i l
" nnoremap u i
" nnoremap l u

" nnoremap r s
" nnoremap p r
" nnoremap z b
" nnoremap m h
" nnoremap i l
" nnoremap ; p
" nnoremap j y

noremap <Leader>' :set relativenumber!<CR>
noremap <Leader>" :set number!<CR>

" scroll faster
nnoremap <C-y> 3k
nnoremap <C-e> 3j

" keep visual selection when indenting
vnoremap < <gv
vnoremap > >gv

" jump to last insert position
nnoremap g; `^

vmap u :s/<C-r><C-r>//g<left><left>

" search / replace for word under the cursor
" nnoremap <leader>/ "fyiw :/<c-r>f<cr>
" nnoremap <leader>? "fyiw :/<c-r>F<cr>

nmap <silent> <ESC> :noh \| :echo<CR>

" replace all under cursor
" nnoremap <Leader>% :%s/\<<C-r><C-w>\>/

" create line bellow
" nnoremap <C-J> a<CR><Esc>k$

" back/forward naviation
nnoremap gs <C-o>
nnoremap <C-n> <C-o>
nnoremap <C-m> <C-i>

" save active buffer
nnoremap <silent> <leader>w :w<cr>
nnoremap <silent> <leader>W :wa<cr>

" window navigation
nnoremap <C-]> <C-w>s
nnoremap <C-\> <C-w>v
nnoremap <C-q> :qa!<CR>
inoremap <C-q> <C-o>:qa!<CR>
nnoremap <silent> <C-o> :only<cr>
nnoremap <leader>= <C-w>=

" tab navigation
nnoremap <leader>i :tabp<CR>
nnoremap <leader>o :tabn<CR>

" copy path to current buffer
nmap <silent> <leader>yy :let @+ = expand("%")<cr>

" not working because of ideavim bugs in diff window
" nnoremap <c-w>i :action Diff.FocusOppositePane<CR>
" nnoremap [c :action NextDiff<CR>
" nnoremap ]c :action PrevDiff<CR>

" resize splits
" todo

" buffer managment
nnoremap <leader>q :q!<cr>

" swap active buffers
nnoremap <C-i> <C-^>

" increment/decrement number
nnoremap <C-x> <C-a>
nnoremap <S-x> <C-x>

" toggle raw formatting view
nmap <leader>; :set list!<cr>

" enable . command in visual mode
vnoremap . :normal .<cr>

" }}}

" set options {{{

set mat=2                   " how many tenths of a second to blink

set nonumber                " disable line numbers by default

set wrap                    " turn on line wrapping
set wrapmargin=8            " wrap lines when coming within n characters from side

set autoindent              " automatically set indent of new line
set smartindent

set clipboard=unnamedplus    " use Windows clipboard
set go+=a

set ignorecase              " case insensitive searching
set smartcase               " case-sensitive if expression contains a capital letter

set magic                   " Set magic on, for regex

set splitbelow              " more natural splits
set splitright

set showmatch               " show matching braces

set noerrorbells

set foldmethod=indent       " default fold method
set foldnestmax=99          " deepest fold level
set nofoldenable            " don't fold by default
set foldlevel=999           " all folds open

set wildmode=list:longest   " complete files like a shell

set ignorecase              " case insensitive searching
set smartcase               " case-sensitive if expression contains a capital letter
set hlsearch                " highlight search results
set incsearch               " set incremental search, like modern browsers

set wildmenu                " enhanced command line completion
set hidden                  " current buffer can be put into background

filetype plugin indent on   " enable ftplugin with indenting
syntax on                   " enable syntax highlighting

" }}}

