runtime plug/plug.vim

call plug#begin('~/.config/nvim/plugged')


" ranger {{{

Plug 'rbgrouleff/bclose.vim'
Plug 'rafaqz/ranger.vim'

let g:ranger_map_keys = 0 " use own keymaps


" nnoremap <leader>m :set nosplitright<CR>:RangerVSplit<CR>:set splitright<CR>
nnoremap <leader>l :RangerEdit<CR>
" nnoremap <leader>m :RangerWorkingDirectory<CR>
" map <C-M-t> :RangerWorkingDirectory<CR>.

" }}}

Plug 'tpope/vim-commentary' " comment stuff out
vmap <C-_> gc
nmap <C-_> gclj

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
"nnoremap <leader>gr :Gread<CR>
nnoremap <leader>gw :Gwrite<CR><CR>
nnoremap <leader>gl :silent! Glog<CR>:bot copen<CR>
nnoremap <leader>gp :Ggrep<Space>
"nnoremap <leader>gm :Gmove<Space>
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

let g:gitgutter_map_keys = 0

nnoremap <leader>gg :GitGutterLineHighlightsToggle<CR>
nnoremap <leader>gh <Plug>(GitGutterPreviewHunk)

nnoremap <C-A-Z> <Plug>(GitGutterUndoHunk)
nnoremap [c <Plug>(GitGutterPrevHunk) \| :let g:gitgutter_floating_window_options['border'] = 'rounded'<CR> \| <Plug>(GitGutterPreviewHunk)
nnoremap ]c <Plug>(GitGutterNextHunk) \| :let g:gitgutter_floating_window_options['border'] = 'rounded'<CR> \| <Plug>(GitGutterPreviewHunk)

" }}}

" vim-easy-align {{{

Plug 'junegunn/vim-easy-align' " align everything

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" }}}

" Plug 'ntpeters/vim-better-whitespace' " show trailing whitespace


Plug 'nvim-treesitter/nvim-treesitter'
" for arg highlight see
" https://github.com/m-demare/hlargs.nvim/#supported-languages

" ConflictMotions {{{

"Plug 'vim-scripts/ConflictMotions' " motions on diff hunks
"
"" dependencies
"Plug 'vim-scripts/CountJump'
"Plug 'vim-scripts/visualrepeat'
"Plug 'vim-scripts/ingo-library'

" }}}

" quick score {{{
"Plug 'unblevable/quick-scope' " quickly highlight first word characters
"
"" trigger a highlight in the appropriate direction when pressing these keys
"let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
"
"" trigger a highlight only when pressing f and F
"let g:qs_highlight_on_keys = ['f', 'F']

" }}}

Plug 'kana/vim-arpeggio' " chord keybinds

" vim-grammarous {{{

"Plug 'rhysd/vim-grammarous' " grammar
"let g:grammarous#show_first_error = 1

" }}}

" vim-easymotion {{{

"Plug 'easymotion/vim-easymotion' " improved motions
"
"let g:EasyMotion_smartcase = 1 " case insensitive
"
"" map <Leader>f <Plug>(easymotion-bd-f)
"" vmap <Leader>f <Plug>(easymotion-bd-f)
"" map <Leader>e <Plug>(easymotion-bd-w)
"" vmap <Leader>e <Plug>(easymotion-bd-w)
"map <Leader>j <Plug>(easymotion-j)
"map <Leader>k <Plug>(easymotion-k)

" }}}

" incsearch {{{

"Plug 'haya14busa/incsearch.vim' " incremental search
"Plug 'haya14busa/incsearch-fuzzy.vim' " fuzzy
"Plug 'haya14busa/incsearch-easymotion.vim' " easymotion integration
"
"map <leader>/ <Plug>(incsearch-fuzzy-/)
"map <leader>? <Plug>(incsearch-fuzzy-?)
"" map g/ <Plug>(incsearch-fuzzy-staym
"
"" map <silent> z/ <Plug>(incsearch-easymotion-/)
"" map <silent> z? <Plug>(incsearch-easymotion-?)
"" map <silent> zg/ <Plug>(incsearch-easymotion-stay)
"
"let g:incsearch#auto_nohlsearch = 1 " auto-hide search highlighting
"map <silent> n  <Plug>(incsearch-nohl-n)
"map N  <Plug>(incsearch-nohl-N)
"map *  <Plug>(incsearch-nohl-*)
"map #  <Plug>(incsearch-nohl-#)
"map g* <Plug>(incsearch-nohl-g*)
"map g# <Plug>(incsearch-nohl-g#)

" }}}

" tmux navigator {{{

"Plug 'fogine/vim-i3wm-tmux-navigator' " navigate vim/tmux/i3 splits
"" Plug 'christoomey/vim-tmux-navigator' " navigate vim/tmux splits
"
"" Disable tmux navigator when zooming the Vim pane
"let g:tmux_navigator_disable_when_zoomed = 1
"
"" disble default mappings
"let g:tmux_navigator_no_mappings = 1
"
"" make navigation work in all modes
"nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
"nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
"nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
"nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
"
"inoremap <silent> <C-h> <Esc>:TmuxNavigateLeft<cr>
"inoremap <silent> <C-j> <Esc>:TmuxNavigateDown<cr>
"inoremap <silent> <C-k> <Esc>:TmuxNavigateUp<cr>
"inoremap <silent> <C-l> <Esc>:TmuxNavigateRight<cr>
"
"vnoremap <silent> <c-h> :<C-U>TmuxNavigateLeft()<cr>
"vnoremap <silent> <c-j> :<C-U>TmuxNavigateDown()<cr>
"vnoremap <silent> <c-k> :<C-U>TmuxNavigateUp()<cr>
"vnoremap <silent> <c-l> :<C-U>TmuxNavigateRight()<cr>
"
"" handle term mode
"tmap <C-h> <C-\><C-n><C-h>i
"tmap <C-j> <C-\><C-n><C-j>i
"tmap <C-k> <C-\><C-n><C-k>i
"tmap <C-l> <C-\><C-n><C-l>i

" }}}

" FZF {{{

let g:fzf_vim = {}
"let g:fzf_vim.preview_window = ['hidden,right,50%,<70(up,40%)', 'ctrl-/']
let g:fzf_preview_window = ['right:hidden', 'ctrl-/']

" override 'show changes'
command! -bang -nargs=? GF call fzf#vim#gitfiles(<q-args> == "?" ? '?' : {}, {'options': ['--layout=default', '--preview-window=down,50%']}, <bang>0)


Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

"let g:fzf_layout = { 'down': '~25%' }
"imap z= <plug>(fzf-complete-word)
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>m :Files<CR>
nnoremap <leader>n :History<CR>
nnoremap <C-Tab> :History<CR>


" }}}


" pandoc {{{

"Plug 'vim-pandoc/vim-pandoc'
"Plug 'vim-pandoc/vim-pandoc-syntax'
"
"" enter opens current link
"" au FileType pandoc nmap <CR> <Plug>(pandoc-keyboard-links-open)
"
"let g:pandoc#folding#fold_yaml = 1
"let g:pandoc#folding#fold_fenced_codeblocks = 1
"let g:pandoc#filetypes#handled = ["pandoc", "markdown"]
"let g:pandoc#filetypes#pandoc_markdown = 0
"let g:pandoc#folding#mode = ["syntax"]
"let g:pandoc#modules#enabled = ["formatting", "folding", "toc"]
"let g:pandoc#formatting#mode = "h"

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
let g:rooter_patterns = ['cargo.toml', '.git']

" only if requested
"let g:rooter_manual_only = 1

" cwd to root
nmap <leader>;r :Rooter<cr>
" cwd to current
nmap <leader>;t :cd %:p:h<cr>
" auto change cwd to current file
set autochdir

" }}}

" goyo {{{

"Plug 'junegunn/goyo.vim' " distraction-free writing in vim

" let g:goyo_height = 100
" let g:goyo_width = 100

" }}}

" vim  pandoc markdown preview {{{

"let g:md_args = "--template eisvogel --listings --latex-engine=xelatex"

"Plug 'skywind3000/asyncrun.vim'
"Plug 'conornewton/vim-pandoc-markdown-preview'

"let g:md_pdf_viewer="zathura"

" }}}

" vim-localvimrc {{{
Plug 'embear/vim-localvimrc'

let g:localvimrc_whitelist='/home/shiro/.local/.*'
let g:localvimrc_sandbox=0

" }}}



source ~/.config/nvim/plugins.lua
"call plug#end()


" chords {{{

" general
call arpeggio#map('n', '', 0, 'wq', ':wq<cr>') " write-quit
call arpeggio#map('n', '', 0, 'we', ':wqa<cr>') " write-quit-all
call arpeggio#map('i', '', 0, 'wq', '<esc>:wq<cr>') " write-quit

" insert mode
call arpeggio#map('i', '', 0, 'fun', 'function')

call arpeggio#map('i', '', 0, 'jk', '<esc>:w<cr>') " save

call arpeggio#map('n', '', 0, 'ag', ':Ag<cr>') " Ag


lua require'colorizer'.setup()
" }}}




lua << EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
  },
  indent = {
    enable = true
  },
}
EOF

" show syntax groups
map gm :Inspect<CR>

" copy path to current buffer
nmap <leader>yy :let @+ = expand("%")<cr>

" init cwd
" Rooter
