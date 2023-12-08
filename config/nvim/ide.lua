-- vim.cmd('source ' '~/.config/nvim/plugins.vim')


local call = vim.call
local cmd = vim.cmd
local Plug = vim.fn['plug#']
local PATH = "~/.config/nvim/plugged"


vim.g['fzf_layout'] = { window = { width = 0.9, height = 1.0 } }
--vim.g['fzf_vim.preview_window'] = { 'right,50%', 'ctrl-/' }
--vim.g['coc_fzf_opts'] = { '--layout=reverse' }



vim.g['coc_global_extensions'] = {
  'coc-json',
  'coc-vimlsp',
  'coc-rust-analyzer',
  'coc-tsserver',
  'coc-styled-components',
  'coc-prettier',
  'coc-eslint',
}

call('plug#begin', PATH)
  --Plug('junegunn/fzf', {dir = '~/.fzf', run = './install --all'})
  --Plug('junegunn/fzf.vim')

  -- Plug 'cespare/vim-toml'
  Plug('rust-lang/rust.vim')
  -- Plug('neoclide/coc.nvim', {branch = 'release'})

  Plug('neoclide/coc.nvim', {branch = 'master', ['do'] = 'npm ci'})
  Plug 'antoinemadec/coc-fzf'
  --Plug('iamcco/vim-language-server', {['do'] = 'yarn install --frozen-lockfile'})

  -- Plug 'dense-analysis/ale'
  Plug 'ray-x/guihua.lua'
  Plug 'ray-x/forgit.nvim'

call'plug#end'

require'forgit'.setup({
  debug = false, -- enable debug logging default path is ~/.cache/nvim/forgit.log
  diff_pager = 'diff-so-fancy', -- you can use `diff`, `diff-so-fancy`
  diff_cmd = '', -- you can use `DiffviewOpen`, `Gvdiffsplit` or `!git diff`, auto if not set
  fugitive = false, -- git fugitive installed?
  abbreviate = false, -- abvreviate some of the commands e.g. gps -> git push
  git_alias = true,  -- git command extensions see: Git command alias
  show_result = 'quickfix', -- show cmd result in quickfix or notify

  shell_mode = true, -- set to true if you using zsh/bash and can not run forgit commands
  height_ratio = 0.6, -- height ratio of floating window when split horizontally
  width_ratio = 0.6, -- width ratio of floating window when split vertically
  cmds_list = {} -- additional commands to show in Forgit command list
})


vim.api.nvim_set_keymap('n', 'gd', "<Plug>(coc-definition)", { silent = true });
vim.api.nvim_set_keymap('n', 'gy', "<Plug>(coc-type-definition)", { silent = true });
vim.api.nvim_set_keymap('n', 'gi', "<Plug>(coc-implementation)", { silent = true });
vim.api.nvim_set_keymap('n', 'gr', "<Plug>(coc-references)", { silent = true });
vim.api.nvim_set_keymap('n', ']e', "<Plug>(coc-diagnostic-next)", { silent = true });
vim.api.nvim_set_keymap('n', '[e', "<Plug>(coc-diagnostic-prev)", { silent = true });
vim.api.nvim_set_keymap('n', '<A-S-e>', "<Plug>(coc-rename)", { silent = true });
vim.api.nvim_set_keymap('n', '<A-S-r>', "<Plug>(coc-refactor)", { silent = true });
vim.api.nvim_set_keymap('v', '<A-S-r>', "<Plug>(coc-refactor-selected)", { silent = true });
vim.api.nvim_set_keymap('i', '<C-S-p>', "CocActionAsync('showSignatureHelp')", { silent = true, expr = true });

-- show outline (hierarchy)
vim.api.nvim_set_keymap('n', 'go', ":CocFzfList outline<CR>", { silent = true });
-- diagnostics
vim.api.nvim_set_keymap('n', 'ge', ":CocFzfList diagnostics<CR>", { silent = true });

vim.api.nvim_set_keymap('n', 'gD', ":GF?<CR>", { silent = true });

--vim.api.nvim_set_keymap('n', 'C-<space>', "<Plug>(coc-diagnostic-next)", { silent = true });
--vim.api.nvim_set_keymap('i', 'C-<space>', "coc#refresh()", {});
vim.keymap.set('i', '<C-Space>', 'coc#refresh()', { expr = true, silent = true})

-- Highlight the symbol and its references on a CursorHold event(cursor is idle)
vim.api.nvim_create_augroup("CocGroup", {})
vim.api.nvim_create_autocmd("CursorHold", {
    group = "CocGroup",
    command = "silent call CocActionAsync('highlight')",
    desc = "Highlight symbol under cursor on CursorHold"
})

vim.api.nvim_create_autocmd("User", {
    group = "CocGroup",
    pattern = "CocJumpPlaceholder",
    command = "call CocActionAsync('showSignatureHelp')",
    desc = "Update signature help on jump placeholder"
})

function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use K to show documentation in preview window
function _G.show_docs()
    --local cw = vim.fn.expand('<cword>')
    --if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
    --    vim.api.nvim_command('h ' .. cw)
    if vim.api.nvim_eval('coc#rpc#ready()') then
        vim.fn.CocActionAsync('doHover')
    else
        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
end
vim.keymap.set("n", "<C-S-p>", '<CMD>lua _G.show_docs()<CR>', {noremap = true, silent = true})


vim.keymap.set("n", "<A-S-i>", ':Files<CR>', {noremap = true, silent = true})

local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
vim.keymap.set("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
vim.keymap.set("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
-- code lens
vim.keymap.set("n", "ga", "<Plug>(coc-codelens-action)", opts)

-- make <CR> accept selected completion item or notify coc.nvim to format
vim.keymap.set("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

-- format
--vim.keymap.set("n", "gl", "<Plug>(coc-format-selected)", {silent = true})
--xmap <leader>f  <Plug>(coc-format-selected)
--nmap <leader>f  <Plug>(coc-format-selected)

-- prettier
--command! -nargs=0 Prettier :CocCommand prettier.forceFormatDocument
--vim.keymap.set('n', 'gl', ':CocCommand prettier.forceFormatDocument<CR>', {silent = true})

function _G.format()
  if vim.bo.filetype == 'rust' then
     vim.cmd('RustFmt')
  elseif vim.bo.filetype == 'typescriptreact' then
    vim.cmd('CocCommand prettier.forceFormatDocument')
  --vim.keymap.set('n', 'gl', ':CocCommand prettier.forceFormatDocument<CR>', {silent = true})
  end
end

--map("", "<Leader>f", "<cmd>:lua require('utils').format<CR>")

vim.keymap.set('n', 'gl', '<CMD>lua _G.format()<CR>', {silent = true})
vim.api.nvim_create_autocmd('BufWritePre', {
 pattern = {'*.rs', '*.tsx'},
 callback = _G.format
})

--inoremap <expr> <TAB> pumvisible() ? "\<C-y>" : "\<CR>"
--inoremap <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
--inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<Down>"
--inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<Up>"

--inoremap <silent><expr> <c-space> coc#refresh()


--nmap <silent> <YOUR PREFERRED KEY HERE> :ALEGoToDefinition<CR>
--nmap <silent> <YOUR PREFERRED KEY HERE> :ALEFindReferences<CR>
--vim.api.nvim_set_keymap('n', 'gd', ":ALEGoToDefinition<CR>", { silent = true });


--vim.api.nvim_create_autocmd("FocusLost", {                                                 
--  command = ":silent wa"                                                                   
--})                                                                                         

vim.o.autowriteall = true -- automatically :write before running commands and changing files
vim.api.nvim_create_autocmd("FocusLost", {
  callback = function()
    _G.format()
    vim.cmd.write()
  end
})

