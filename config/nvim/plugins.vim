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
Plug 'rafaqz/ranger.vim'

let g:ranger_map_keys = 0 " use own keymaps


" nnoremap <leader>m :set nosplitright<CR>:RangerVSplit<CR>:set splitright<CR>
nnoremap <leader>m :RangerEdit<CR>
" nnoremap <leader>m :RangerWorkingDirectory<CR>
" map <C-M-t> :RangerWorkingDirectory<CR>.

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

" vim-easy-align {{{

Plug 'junegunn/vim-easy-align' " align everything

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" }}}

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

Plug 'elzr/vim-json' " JSON

" }}}

" quick score {{{
Plug 'unblevable/quick-scope' " quickly highlight first word characters

" trigger a highlight in the appropriate direction when pressing these keys
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

" trigger a highlight only when pressing f and F
let g:qs_highlight_on_keys = ['f', 'F']

" }}}

Plug '~/project/autojump.vim'

Plug 'kana/vim-arpeggio' " chord keybinds

" deoplete.nvim {{{

" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" let g:deoplete#enable_at_startup = 1

" }}}

" vim-grammarous {{{

Plug 'rhysd/vim-grammarous' " grammar
let g:grammarous#show_first_error = 1

" }}}

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
nnoremap <leader>n :Files<CR>
nnoremap <leader>v :History<CR>

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

" cwd to root
nmap <leader>;r :Rooter<cr>
" cwd to current
nmap <leader>;t :cd %:p:h<cr>
" auto change cwd to current file
set autochdir

" }}}

" goyo {{{

Plug 'junegunn/goyo.vim' " distraction-free writing in vim

" let g:goyo_height = 100
" let g:goyo_width = 100

" }}}

Plug 'ChristianChiarulli/codi.vim'

" vim  pandoc markdown preview {{{

"let g:md_args = "--template eisvogel --listings --latex-engine=xelatex"

Plug 'skywind3000/asyncrun.vim'
Plug 'conornewton/vim-pandoc-markdown-preview'

let g:md_pdf_viewer="zathura"

" }}}

" vim-localvimrc {{{
Plug 'embear/vim-localvimrc' 

let g:localvimrc_whitelist='/home/shiro/.local/.*'
let g:localvimrc_sandbox=0

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


Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'liuchengxu/graphviz.vim'
" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" NeoVim-only mapping for visual mode scroll
" Useful on signatureHelp after jump placeholder of snippet expansion
if has('nvim')
  vnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#nvim_scroll(1, 1) : "\<C-f>"
  vnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#nvim_scroll(0, 1) : "\<C-b>"
endif

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
