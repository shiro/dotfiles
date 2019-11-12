runtime plug/plug.vim

call plug#begin('~/.config/nvim/plugged')


" NERDTree [disabled] {{{
" Plug 'scrooloose/nerdtree', "{ 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
" Plug 'Xuyuanp/nerdtree-git-plugin'

" nmap <silent> <leader>u :NERDTreeToggle<cr>

" " " expand to the path of the file in the current buffer
" " nmap <silent> <leader>y :NERDTreeFind<cr>

" " close vim if only window remaining
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" autocmd bufenter * if (winnr("$") == 1) | q | endif

" let NERDTreeMinimalUI=1 " hide help
" let NERDTreeShowHidden=1 " show hidden files
" let NERDTreeDirArrowExpandable = '▷'
" let NERDTreeDirArrowCollapsible = '▼'

" let g:NERDTreeIndicatorMapCustom = {
"     \ "Modified"  : "✹",
"     \ "Staged"    : "✚",
"     \ "Untracked" : "✭",
"     \ "Renamed"   : "➜",
"     \ "Unmerged"  : "═",
"     \ "Deleted"   : "✖",
"     \ "Dirty"     : "✗",
"     \ "Clean"     : "✔︎",
"     \ 'Ignored'   : '☒',
"     \ "Unknown"   : "?"
"     \ }

" }}}

" ranger {{{

Plug 'rbgrouleff/bclose.vim'
Plug 'francoiscabrol/ranger.vim'

let g:ranger_replace_netrw = 1
let g:ranger_map_keys = 0 " use own keymaps

map <C-M-r> :Ranger<CR>.
map <C-M-t> :RangerWorkingDirectory<CR>.

" }}}

" Plug 'benmills/vimux' " tmux integration for vim

Plug 'tpope/vim-commentary' " comment stuff out

" fugitive {{{

Plug 'tpope/vim-fugitive' " amazing git wrapper for vim

set diffopt+=vertical " vertical splits on diff

" keymaps
nnoremap <leader>ga :Git add %:p<CR><CR>
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gc :Gcommit -v -q<CR>
nnoremap <leader>gt :Gcommit -v -q %:p<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>ge :Gedit<CR>
nnoremap <leader>gr :Gread<CR>
nnoremap <leader>gw :Gwrite<CR><CR>
nnoremap <leader>gl :silent! Glog<CR>:bot copen<CR>
nnoremap <leader>gp :Ggrep<Space>
nnoremap <leader>gm :Gmove<Space>
nnoremap <leader>gb :Git branch<Space>
nnoremap <leader>go :Git checkout<Space>
nnoremap <leader>gps :Dispatch! git push<CR>
nnoremap <leader>gpl :Dispatch! git pull<CR>

" 72 is the number
autocmd Filetype gitcommit setlocal spell textwidth=72
" auto cleanup buffers
autocmd BufReadPost fugitive://* set bufhidden=delete

" }}}

" git gutter {{{

Plug 'airblade/vim-gitgutter' " git gutter to the left

nnoremap <leader>gg :GitGutterLineHighlightsToggle<CR>

" }}}

Plug 'tpope/vim-repeat' " enables repeating other supported plugins with the . command
Plug 'tpope/vim-surround' " mappings to easily delete, change and add such surroundings in pairs, such as quotes, parens, etc.
Plug 'tpope/vim-unimpaired' " convinient pair mappings

Plug 'ntpeters/vim-better-whitespace' " show trailing whitespace

" yank ring [DISABLED](slows down nvim a LOT) {{{

" Plug 'vim-scripts/YankRing.vim' " yank ring

let g:yankring_history_file = '.local/share/misc/yankring_history.txt' " history file location

" }}}

" ConflictMotions {{{

Plug 'vim-scripts/ConflictMotions' " motions on diff hunks

" dependencies
Plug 'vim-scripts/CountJump'
Plug 'vim-scripts/visualrepeat'
Plug 'vim-scripts/ingo-library'

" }}}

" syntax {{{

Plug 'cakebaker/scss-syntax.vim' " sass

Plug 'chr4/nginx.vim' " nginx.conf

" }}}

Plug 'kana/vim-arpeggio' " chord keybinds

" deoplete.nvim {{{

" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" let g:deoplete#enable_at_startup = 1

" }}}

Plug 'rhysd/vim-grammarous' " grammar

" vim-easymotion {{{

Plug 'easymotion/vim-easymotion' " improved motions

let g:EasyMotion_smartcase = 1 " case insensitive

" map <Leader>f <Plug>(easymotion-bd-f)
" vmap <Leader>f <Plug>(easymotion-bd-f)
" map <Leader>e <Plug>(easymotion-bd-w)
" vmap <Leader>e <Plug>(easymotion-bd-w)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

" }}}

" incsearch {{{

Plug 'haya14busa/incsearch.vim' " incremental search
Plug 'haya14busa/incsearch-fuzzy.vim' " fuzzy
Plug 'haya14busa/incsearch-easymotion.vim' " easymotion integration

map <leader>/ <Plug>(incsearch-fuzzy-/)
map <leader>? <Plug>(incsearch-fuzzy-?)
" map g/ <Plug>(incsearch-fuzzy-staym

" map <silent> z/ <Plug>(incsearch-easymotion-/)
" map <silent> z? <Plug>(incsearch-easymotion-?)
" map <silent> zg/ <Plug>(incsearch-easymotion-stay)

let g:incsearch#auto_nohlsearch = 1 " auto-hide search highlighting
map <silent> n  <Plug>(incsearch-nohl-n)
map N  <Plug>(incsearch-nohl-N)
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
map g* <Plug>(incsearch-nohl-g*)
map g# <Plug>(incsearch-nohl-g#)

" }}}

" tmux navigator {{{

Plug 'fogine/vim-i3wm-tmux-navigator' " navigate vim/tmux/i3 splits
" Plug 'christoomey/vim-tmux-navigator' " navigate vim/tmux splits

" Disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed = 1

" disble default mappings
let g:tmux_navigator_no_mappings = 1

" make navigation work in all modes
nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :TmuxNavigateRight<cr>

inoremap <silent> <C-h> <Esc>:TmuxNavigateLeft<cr>
inoremap <silent> <C-j> <Esc>:TmuxNavigateDown<cr>
inoremap <silent> <C-k> <Esc>:TmuxNavigateUp<cr>
inoremap <silent> <C-l> <Esc>:TmuxNavigateRight<cr>

vnoremap <silent> <c-h> :<C-U>TmuxNavigateLeft()<cr>
vnoremap <silent> <c-j> :<C-U>TmuxNavigateDown()<cr>
vnoremap <silent> <c-k> :<C-U>TmuxNavigateUp()<cr>
vnoremap <silent> <c-l> :<C-U>TmuxNavigateRight()<cr>

" handle term mode
tmap <C-h> <C-\><C-n><C-h>i
tmap <C-j> <C-\><C-n><C-j>i
tmap <C-k> <C-\><C-n><C-k>i
tmap <C-l> <C-\><C-n><C-l>i

" }}}

" FZF {{{

Plug 'junegunn/fzf' " fzf fuzzy-find wrapper
Plug 'junegunn/fzf.vim'

let g:fzf_layout = { 'down': '~25%' }
imap z= <plug>(fzf-complete-word)
nnoremap <leader>b :Buffers<CR> 
nnoremap <leader>m :Files<CR> 

" }}}

" pandoc {{{

Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'

" enter opens current link
" au FileType pandoc nmap <CR> <Plug>(pandoc-keyboard-links-open)

let g:pandoc#folding#fold_yaml = 1
let g:pandoc#folding#fold_fenced_codeblocks = 1
let g:pandoc#filetypes#handled = ["pandoc", "markdown"]
let g:pandoc#filetypes#pandoc_markdown = 0
let g:pandoc#folding#mode = ["syntax"]
let g:pandoc#modules#enabled = ["formatting", "folding", "toc"]
let g:pandoc#formatting#mode = "h"

" }}}

" vimwiki {{{

Plug 'vimwiki/vimwiki'

" load wiki list from ENV
if expand("$VIMWIKI_LIST") != "$VIMWIKI_LIST"
	execute 'let g:vimwiki_list = ' . expand("$VIMWIKI_LIST")
endif

" change leader mappings
let g:vimwiki_map_prefix = '<Leader>e'

" enable global highlighting
let g:vimwiki_ext2syntax = {'.md': 'markdown'}
let g:vimwiki_folding='expr'

au FileType vimwiki set filetype=vimwiki.markdown


" remove annoying keybinds
" let g:vimwiki_table_mappings = 0
:nmap <C-M-F12> <Plug>VimwikiNextLink

" }}}

" vim rooter {{{

Plug 'airblade/vim-rooter' " start in the right place

let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_silent_chdir = 1
let g:rooter_resolve_links = 1

" only if requested
let g:rooter_manual_only = 1

" go to root
nmap <leader>;r :Rooter<cr>

" }}}

" goyo {{{

Plug 'junegunn/goyo.vim' " distraction-free writing in vim

" let g:goyo_height = 100
" let g:goyo_width = 100

" }}}

" wal {{{

Plug 'dylanaraps/wal.vim' " color scheme

" }}}


" lightline.vim (todo) {{{

" Plug 'itchyny/lightline.vim' " a light, fancy status bar

" let g:lightline = {
"       \ 'colorscheme': 'jellybeans',
"       \ 'active': {
"       \   'left': [ [ 'paste' ],
"       \             [ 'readonly', 'filename', 'modified', 'helloworld' ] ]
"       \ },
"       \ 'component': {
"       \   'helloworld': 'Hello, world!'
"       \ },
"       \ }

" }}}

Plug 'deviantfero/wpgtk.vim'

call plug#end()

" chords {{{

" general
call arpeggio#map('n', '', 0, 'wq', ':wq<cr>') " write-quit
call arpeggio#map('n', '', 0, 'we', ':wqa<cr>') " write-quit-all
call arpeggio#map('i', '', 0, 'wq', '<esc>:wq<cr>') " write-quit

" insert mode
call arpeggio#map('i', '', 0, 'fun', 'function')

call arpeggio#map('i', '', 0, 'jk', '<esc>:w<cr>') " save

call arpeggio#map('n', '', 0, 'ag', ':Ag<cr>') " Ag


" }}}


" todo add this
"" if isdirectory(".git")
""     " if in a git project, use :GFiles
""     nmap <silent> <leader>t :GFiles<cr>
"" else
""     " otherwise, use :FZF
""     nmap <silent> <leader>t :FZF<cr>
"" endif
