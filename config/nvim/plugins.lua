-- local utils = require "utils"

local call = vim.call
local cmd = vim.cmd
local Plug = vim.fn['plug#']

--local PATH = "~/.config/nvim/plugged"
--call('plug#begin', PATH)


vim.g['fzf_layout'] = { window = { width = 0.9, height = 1.0 } }
--vim.g['fzf_vim.preview_window'] = { 'right,50%', 'ctrl-/' }
--vim.g['coc_fzf_opts'] = { '--layout=reverse' }


-- syntax highlight
Plug 'nvim-treesitter/nvim-treesitter'

-- LSP server, auto-complete
vim.g['coc_global_extensions'] = {
    'coc-json',
    'coc-vimlsp',
    'coc-rust-analyzer',
    'coc-tsserver',
    'coc-styled-components',
    'coc-prettier',
    'coc-eslint',
    -- 'coc-lua',
    'coc-sumneko-lua',
    'coc-pyright',
}
Plug('neoclide/coc.nvim', { branch = 'master', ['do'] = 'npm ci' })
Plug 'antoinemadec/coc-fzf'

-- Plug 'ray-x/guihua.lua'
-- Plug 'ray-x/forgit.nvim'

-- language-specific stuff {{{

-- rust
Plug('rust-lang/rust.vim', { ['for'] = 'rust' })
Plug('arzg/vim-rust-syntax-ext', { ['for'] = 'rust' })

-- }}}

-- misc {{{

-- enables repeating other supported plugins with the . command
Plug 'tpope/vim-repeat'

-- mappings to easily delete, change and add such surroundings in pairs, such as quotes, parens, etc.
Plug 'tpope/vim-surround'

-- convinient pair mappings
--Plug 'tpope/vim-unimpaired'

-- show color hex codes
Plug 'norcalli/nvim-colorizer.lua'

-- fix tmux not reporting fo
-- Plug 'tmux-plugins/vim-tmux-focus-events'

--- }}}

Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', { tag = '0.1.5' })
Plug 'fannheyward/telescope-coc.nvim'

call 'plug#end'

local telescope_actions = require "telescope.actions"
require('telescope').setup {
    defaults = { mappings = { i = { ["<esc>"] = telescope_actions.close } } },
    file_ignore_patterns = {
        "node%_modules/.*",
        "./target/.*",
    },
    extensions = {
        coc = {
            theme = 'ivy',
            prefer_locations = true, -- use for list picker
        }
    }
}
local sorter = require("top-results-sorter").sorter()
local tele_builtin = require('telescope.builtin')
local tele_theme_dropdown = require "telescope.themes".get_dropdown()
local tele_theme_cursor = require "telescope.themes".get_cursor()
local tele_theme_default = {}
function dynamic_theme()
    local width = vim.api.nvim_win_get_width(0)
    local height = vim.api.nvim_win_get_height(0)

    if width / 2 > height then
        return tele_theme_default
    else
        return tele_theme_dropdown
    end
end

local theme = dynamic_theme
--require("dressing").setup { select = { telescope = tele_theme_cursor } }
--vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>lua require("telescope.builtin").find_files({sort_lastused= 1})<CR>', {})
function _G.foo()
    tele_builtin.find_files({
        sorter = sorter,
        previewer = false,
        --find_command = { "bash", "-c",
        --    "PATH=$PATH:~/.cargo/bin rg --files --one-file-system --color never --sort modified" }
    })
end

vim.keymap.set("n", "<leader>f", '<CMD>lua _G.foo()<CR>', {})

--vim.api.nvim_set_keymap('n', "<leader>ff",
--    function()
--        tele_builtin.find_files(utils.spread(theme()) {
--            sorter = require("top-result-sorter").sorter(),
--            --find_command = { "bash", "-c",
--            --    "PATH=$PATH:~/.cargo/bin rg --files --one-file-system --color never --sort modified" }
--        })
--    end, {})

--require'forgit'.setup({
--  debug = false,
--  diff_pager = 'diff-so-fancy',
--  diff_cmd = '',
--  fugitive = false,
--  abbreviate = false,
--  git_alias = true,
--  show_result = 'quickfix',
--
--  shell_mode = true,
--  height_ratio = 0.6,
--  width_ratio = 0.6,
--  cmds_list = {}
--})

require 'colorizer'.setup()

-- tree-sitter {{{
require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "typescript", "tsx", "javascript", "css", "scss", "rust", "json", "lua" },
    auto_install = true,
    highlight = { enable = true },
    incremental_selection = { enable = true },
    indent = { enable = true },
    context_commentstring = { enable = true },
}
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
--- }}}



local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }


vim.api.nvim_set_keymap('n', 'gd', "<Plug>(coc-definition)", { silent = true });
vim.api.nvim_set_keymap('n', 'gy', "<Plug>(coc-type-definition)", { silent = true });
vim.api.nvim_set_keymap('n', 'gi', "<Plug>(coc-implementation)", { silent = true });
vim.api.nvim_set_keymap('n', 'gr', ":Telescope coc references<CR>", { silent = true });
vim.api.nvim_set_keymap('n', ']e', "<Plug>(coc-diagnostic-next)", { silent = true });
vim.api.nvim_set_keymap('n', '[e', "<Plug>(coc-diagnostic-prev)", { silent = true });
vim.api.nvim_set_keymap('n', '<A-S-e>', "<Plug>(coc-rename)", { silent = true });
vim.api.nvim_set_keymap('n', '<A-S-r>', "<Plug>(coc-refactor)", { silent = true });
vim.api.nvim_set_keymap('v', '<A-S-r>', "<Plug>(coc-refactor-selected)", { silent = true });
-- TODO go to symbol
-- :Telescope coc workspace_symbols

-- show outline (hierarchy)
vim.api.nvim_set_keymap('n', 'go', ":CocFzfList outline<CR>", { silent = true });
-- vim.api.nvim_set_keymap("n", "go", ":CocList outline<CR>", opts)
-- list warnings/errors
-- vim.api.nvim_set_keymap('n', 'ge', ":CocFzfList diagnostics<CR>", { silent = true });
-- list all local changes
vim.api.nvim_set_keymap('n', 'gD', ":GF?<CR>", { silent = true });

vim.keymap.set('i', '<C-Space>', 'coc#refresh()', { expr = true, silent = true })

-- highlight the symbol under cursor
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


-- show docs
function _G.show_docs()
    local cw = vim.fn.expand('<cword>')
    --if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
    --    vim.api.nvim_command('h ' .. cw)
    if vim.api.nvim_eval('coc#rpc#ready()') then
        vim.fn.CocActionAsync('doHover')
    else
        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
end

vim.keymap.set("n", "<C-S-p>", '<CMD>lua _G.show_docs()<CR>', { noremap = true, silent = true })
vim.keymap.set("n", "<F12>", '<CMD>lua _G.show_docs()<CR>', { noremap = true, silent = true })
vim.keymap.set('i', '<C-S-p>', "CocActionAsync('showSignatureHelp')", { silent = true, expr = true });
vim.keymap.set('i', '<F12>', "CocActionAsync('showSignatureHelp')", { silent = true, expr = true });


vim.keymap.set("n", "<A-S-i>", ':Files<CR>', { noremap = true, silent = true })

-- tab/S-tab completion menu
function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

vim.keymap.set("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()',
    opts)
vim.keymap.set("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
-- code lens
vim.keymap.set("n", "ga", "<Plug>(coc-codelens-action)", opts)
-- make <CR> accept selected completion item or notify coc.nvim to format
vim.keymap.set("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
-- reformat code
function _G.format()
    if vim.bo.filetype == 'rust' then
        vim.cmd('RustFmt')
    elseif vim.bo.filetype == 'typescriptreact' then
        vim.cmd('CocCommand prettier.forceFormatDocument')
    end
end

-- vim.keymap.set('n', 'gl', '<CMD>lua _G.format()<CR>', {silent = true})
vim.keymap.set("x", "gl", "<Plug>(coc-format-selected)", { silent = true })
vim.keymap.set("n", "gl", "<Plug>(coc-format-selected)j", { silent = true })

vim.api.nvim_create_autocmd("FileType", {
    group = "CocGroup",
    pattern = "lua",
    command = "setl formatexpr=CocAction('formatSelected')",
    desc = "Setup formatexpr specified filetype(s)."
})
-- vim.api.nvim_create_autocmd("FileType", {
--     group = "CocGroup",
--     pattern = "rust",
--     command = "setl formatexpr=RustFmt",
--     desc = "Setup formatexpr specified filetype(s)."
-- })


-- auto-format on save
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   pattern = {'*.rs', '*.tsx'},
--   callback = _G.format
-- })

-- auto-save on focus lost/buffer change
vim.o.autowriteall = true
vim.api.nvim_create_autocmd("FocusLost", {
    pattern = '*.*',
    callback = function()
        _G.format()
        vim.cmd.write({ mods = { silent = true } })
    end
})
