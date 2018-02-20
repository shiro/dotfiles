runtime plug/plug.vim 

call plug#begin('~/.config/nvim/plugged')


" NERDTree {{{
" Plug 'scrooloose/nerdtree', "{ 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
" Plug 'Xuyuanp/nerdtree-git-plugin'

" nmap <silent> <leader>u :NERDTreeToggle<cr>

" " " expand to the path of the file in the current buffer
" " nmap <silent> <leader>y :NERDTreeFind<cr>

" " close vim if only window remaining
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

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


Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim'

let g:ranger_replace_netrw = 1
let g:ranger_map_keys = 0 " use own keymaps


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

let g:gitgutter_enabled = 0

nnoremap <leader>gg :GitGutterToggle<CR>

" }}}

Plug 'tpope/vim-repeat' " enables repeating other supported plugins with the . command
Plug 'tpope/vim-surround' " mappings to easily delete, change and add such surroundings in pairs, such as quotes, parens, etc.

Plug 'vim-scripts/YankRing.vim' " yank ring

Plug 'kchmck/vim-coffee-script' " coffee-scirpt syntax

Plug 'cakebaker/scss-syntax.vim' " sass syntax

Plug 'kana/vim-arpeggio' " chord keybinds

" Plug 'Valloric/YouCompleteMe' " completion

" vim-easymotion {{{

Plug 'easymotion/vim-easymotion' " improved motions

map <Leader>f <Plug>(easymotion-bd-f)
map <Leader>e <Plug>(easymotion-bd-w)

" }}}

" tmux navigator {{{

Plug 'christoomey/vim-tmux-navigator' " navigate vim/tmux splits

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

" }}}

" FZF {{{

Plug 'junegunn/fzf', { 'dir': '~/.local/share/fzf', 'do': './install --all' } " fzf fuzzy-find wrapper
Plug 'junegunn/fzf.vim'

let g:fzf_layout = { 'down': '~25%' }
imap z= <plug>(fzf-complete-word)
nnoremap <leader>b :Buffers<CR> 
nnoremap <leader>m :Files<CR> 

" }}}

" pandoc {{{

" Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'

let g:pandoc#folding#mode = 'syntax'
let g:pandoc#folding#fold_yaml = 1
" let g:pandoc#folding#fold_fenced_codeblocks = 1

" }}}

" vim rooter {{{

Plug 'airblade/vim-rooter' " start in the right place

let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_silent_chdir = 1
let g:rooter_resolve_links = 1

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

call plug#end()

" chords {{{

" general
call arpeggio#map('n', '', 0, 'wq', ':wq<cr>') " write-quit
call arpeggio#map('i', '', 0, 'wq', '<esc>:wq<cr>') " write-quit

" insert mode
call arpeggio#map('i', '', 0, 'fun', 'function')

" }}}


" if isdirectory(".git")
"     " if in a git project, use :GFiles
"     nmap <silent> <leader>t :GFiles<cr>
" else
"     " otherwise, use :FZF
"     nmap <silent> <leader>t :FZF<cr>
" endif

" nmap <silent> <leader>r :Buffers<cr>
" nmap <silent> <leader>e :FZF<cr>
" nmap <leader><tab> <plug>(fzf-maps-n)
" xmap <leader><tab> <plug>(fzf-maps-x)
" omap <leader><tab> <plug>(fzf-maps-o)

" " Insert mode completion
" imap <c-x><c-k> <plug>(fzf-complete-word)
" imap <c-x><c-f> <plug>(fzf-complete-path)
" imap <c-x><c-j> <plug>(fzf-complete-file-ag)
" imap <c-x><c-l> <plug>(fzf-complete-line)

" nnoremap <silent> <leader>c :call fzf#run({
" \   'source':
" \     map(split(globpath(&rtp, "colors/*.vim"), "\n"),
" \         "substitute(fnamemodify(v:val, ':t'), '\\..\\{-}$', '', '')"),
" \   'sink':    'colo',
" \   'options': '+m',
" \   'left':    30
" \ })<cr>
" 
" command! fzfmru call fzf#run({
" \  'source':  v:oldfiles,
" \  'sink':    'e',
" \  'options': '-m -x +s',
" \  'down':    '40%'})
" 
" command! -bang -nargs=* find call fzf#vim#grep(
" 	\ 'rg --column --line-number --no-heading --follow --color=always '.<q-args>, 1,
" 	\ <bang>0 ? fzf#vim#with_preview('up:60%') : fzf#vim#with_preview('right:50%:hidden', '?'), <bang>0)


" fugitive
" --------
" nmap <silent> <leader>gs :gstatus<cr>
" nmap <leader>ge :gedit<cr>
" nmap <silent><leader>gr :gread<cr>
" nmap <silent><leader>gb :gblame<cr>
" 
" nmap <leader>m :markedopen!<cr>
" nmap <leader>mq :markedquit<cr>
" nmap <leader>* *<c-o>:%s///gn<cr>
" 
" let g:neomake_javascript_jshint_maker = {
"     \ 'args': ['--verbose'],
"     \ 'errorformat': '%a%f: line %l\, col %v\, %m \(%t%*\d\)',
" \ }
" 
" 
" " airline options
" let g:airline_powerline_fonts=1
" let g:airline_left_sep=''
" let g:airline_right_sep=''
" let g:airline_theme='onedark'
" let g:airline#extensions#tabline#enabled = 1 " enable airline tabline
" let g:airline#extensions#tabline#tab_min_count = 2 " only show tabline if tabs are being used (more than 1 tab open)
" let g:airline#extensions#tabline#show_buffers = 0 " do not show open buffers in tabline
" let g:airline#extensions#tabline#show_splits = 0
" 
" " don't hide quotes in json files
" let g:vim_json_syntax_conceal = 0
" 
" let g:SuperTabCrMapping = 0
