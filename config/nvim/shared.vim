" mappings {{{

imap jj <Esc>

" todo double leader map
" noremap <Leader><Leader> V

noremap <Leader>n :noh<CR>
noremap <Leader>' :set relativenumber!<CR>
noremap <Leader>" :set number!<CR>

" scroll faster
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" search / replace for word under the cursor
" nnoremap <leader>/ "fyiw :/<c-r>f<cr>
" nnoremap <leader>? "fyiw :/<c-r>F<cr>

" replace all under cursor
" nnoremap <Leader>% :%s/\<<C-r><C-w>\>/

" create line bellow
" nnoremap <C-J> a<CR><Esc>k$

" new line without insert
nmap <S-Enter> O<Esc>
nmap <A-o> o<Esc>

" save active buffer
nnoremap <leader>w :w<cr>
nnoremap <leader>W :wa<cr>

" window navigation
nnoremap <C-]> <C-w>s
nnoremap <C-\> <C-w>v
nnoremap <C-q> :q!<CR>
nnoremap <C-o> :only<cr>
nnoremap <leader>= <C-w>=

" resize splits
" todo

" clear search highlighting
nnoremap <silent> <esc> :noh<cr><esc>

" buffer managment
nnoremap <C-w> :wq<cr>
" nnoremap <C-W> :wqa<cr>
nnoremap <leader>q :qa!<cr>

" swap active buffers
nnoremap <C-i> <C-^>

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

set clipboard=unnamed       " use Windows clipboard
set go+=a

set ignorecase              " case insensitive searching
set smartcase               " case-sensitive if expression contains a capital letter

set magic                   " Set magic on, for regex

set splitbelow              " more natural splits
set splitright

set showmatch               " show matching braces

set noerrorbells

set foldmethod=marker       " fold based on indent
set foldnestmax=10          " deepest fold is 10 levels
set nofoldenable            " don't fold by default
set foldlevel=0             " all folds closed

set wildmode=list:longest   " complete files like a shell

set ignorecase              " case insensitive searching
set smartcase               " case-sensitive if expression contains a capital letter
set hlsearch                " highlight search results
set incsearch               " set incremental search, like modern browsers

set wildmenu                " enhanced command line completion
set hidden                  " current buffer can be put into background

syntax on                   " enable syntax highlighting


" }}}

