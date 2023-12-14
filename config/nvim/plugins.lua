local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)


vim.g['coc_global_extensions'] = {
    "coc-snippets",
    "coc-json",
    "coc-vimlsp",
    "coc-tsserver",
    "coc-styled-components",
    "coc-prettier",
    "coc-eslint",
    "coc-sumneko-lua",
    "coc-pyright",
}

require("lazy").setup({
    {
        "anuvyklack/pretty-fold.nvim",
        config = function()
            require("pretty-fold").setup({
                fill_char = " ",
                sections = {
                    left = { "content" },
                    right = {
                        " ", "number_of_folded_lines",
                        function(config) return config.fill_char:rep(3) end,
                    },
                },
            })
        end,
    },
    -- chord keybinds
    {
        "kana/vim-arpeggio",
        config = function()
            -- write-quit
            vim.api.nvim_command("call arpeggio#map('n', '', 0, 'wq', ':wq<cr>')")
            -- write-quit-all
            vim.api.nvim_command("call arpeggio#map('n', '', 0, 'we', ':wqa<cr>')")
            -- write-quit
            vim.api.nvim_command("call arpeggio#map('i', '', 0, 'wq', '<ESC>:wq<CR>')")
            -- insert mode
            vim.api.nvim_command("call arpeggio#map('i', '', 0, 'fun', 'function')")
            -- save
            vim.api.nvim_command("call arpeggio#map('i', '', 0, 'jk', '<ESC>')")
            -- close buffer
            vim.api.nvim_command("call arpeggio#map('n', 's', 0, 'ap', '<ESC>:q<CR>')")
            -- only buffer
            vim.api.nvim_command("call arpeggio#map('n', 's', 0, 'ao', '<C-w>o')")
            -- Ag
            -- vim.api.nvim_command("call arpeggio#map('n', '', 0, 'ag', ':Ag<CR>')")

            -- files, surpress false warning about jk being mapped already
            vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'jk', ':Files<cr>')")
            vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'df', '<CMD>wincmd w<CR>')")
        end
    },

    -- CWD managmnent
    {
        'airblade/vim-rooter',
        config = function()
            vim.g['rooter_change_directory_for_non_project_files'] = 'current'
            vim.g['rooter_silent_chdir'] = 1
            vim.g['rooter_resolve_links'] = 1
            vim.g['rooter_patterns'] = { 'cargo.toml', '.git' }

            -- only if requested
            vim.g['rooter_manual_only'] = 1

            -- cwd to root
            -- nmap <leader>;r :Rooter<cr>
            -- cwd to current
            -- nmap <leader>;t :cd %:p:h<cr>
            -- auto change cwd to current file
            -- set autochdir
        end,
    },

    -- GIT
    {
        'tpope/vim-fugitive',
        config = function()
            vim.opt.diffopt = vim.opt.diffopt + "vertical"

            vim.keymap.set("n", "<leader>gd", ':Gdiff<CR>', {})
            -- nnoremap <leader>ga :Git add %:p<CR><CR>
            -- nnoremap <leader>gs :Gstatus<CR>
            -- nnoremap <leader>gc :Gcommit -v -q<CR>
            -- nnoremap <leader>gt :Gcommit -v -q %:p<CR>
            -- nnoremap <leader>ge :Gedit<CR>
            -- "nnoremap <leader>gr :Gread<CR>
            -- nnoremap <leader>gw :Gwrite<CR><CR>
            -- nnoremap <leader>gl :silent! Glog<CR>:bot copen<CR>
            -- nnoremap <leader>gp :Ggrep<Space>
            -- "nnoremap <leader>gm :Gmove<Space>
            -- nnoremap <leader>gb :Git branch<Space>
            -- nnoremap <leader>go :Git checkout<Space>
            -- nnoremap <leader>gps :Dispatch! git push<CR>
            -- nnoremap <leader>gpl :Dispatch! git pull<CR>

            -- " 72 is the number
            -- autocmd Filetype gitcommit setlocal spell textwidth=72
            -- " auto cleanup buffers
            -- autocmd BufReadPost fugitive://* set bufhidden=delete
        end
    },

    -- syntax highlight
    {
        "nvim-treesitter/nvim-treesitter",
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = { "typescript", "tsx", "javascript", "css", "scss", "rust", "json", "lua" },
                auto_install = true,
                highlight = { enable = true },
                incremental_selection = { enable = true },
                indent = { enable = true },
                context_commentstring = { enable = true },
            })
            -- vim.o.foldmethod = "expr"
            vim.o.foldexpr = "nvim_treesitter#foldexpr()"
        end,
    },

    -- LSP server, auto-complete
    {
        "neoclide/coc.nvim",
        branch = "master",
        build = "npm ci",
    },
    {
        "fannheyward/coc-rust-analyzer",
        branch = "master",
        build = "npm ci",
        ft = "rust",
    },
    {
        "tjdevries/coc-zsh",
        ft = "zsh",
    },
    {
        "josa42/coc-sh",
        build = "npm ci",
        ft = "sh",
    },
    'antoinemadec/coc-fzf',

    -- commnets
    {
        "numToStr/Comment.nvim",
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        lazy = false,
        init = function()
            -- avoid comment plugin warning
            vim.g.skip_ts_context_commentstring_module = true
        end,
        config = function()
            require('ts_context_commentstring').setup { enable_autocmd = false }
            require('Comment').setup({
                pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
            })

            vim.api.nvim_command("xmap <C-_> gc")
            vim.api.nvim_command("nmap <C-_> gccj")
            --vim.keymap.set("v", "<C-_>", "gc", {})
            --vim.keymap.set("n", "<C-_>", "gcc", {})
        end
    },

    -- find and replace
    {
        'nvim-pack/nvim-spectre',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            vim.keymap.set("n", "<C-S-R>", "<cmd>lua require('spectre').toggle()<CR>", { silent = true })
            vim.keymap.set("n", "<Leader>R", "<cmd>lua require('spectre').toggle()<CR>", { silent = true })
        end,
    },

    -- show color hex codes
    {
        'norcalli/nvim-colorizer.lua',
        config = function()
            require('colorizer').setup()
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-tree/nvim-web-devicons',
            'fannheyward/telescope-coc.nvim',
        },
        config = function()
            local telescope_actions = require "telescope.actions"
            require('telescope').setup({
                defaults = {
                    mappings = { i = { ["<esc>"] = telescope_actions.close } },
                    layout_config = {
                        vertical = {
                            height = 0.6,
                            -- mirror = true,
                        },
                    },
                    layout_strategy = "flex",
                },
                file_ignore_patterns = {
                    "node%_modules/.*",
                    "./target/.*",
                },
                extensions = {
                    coc = {
                        -- use for list picker
                        prefer_locations = true,
                    }
                }
            })
            require('telescope').load_extension('coc')
            local sorter = require("top-results-sorter").sorter()
            local tele_builtin = require('telescope.builtin')
            local actions = require("telescope.actions")
            function layout()
                local width = vim.fn.winwidth(0)
                local height = vim.fn.winheight(0)

                if (width / 2) > height then return "horizontal" end
                return "vertical"
            end

            function files(show_hidden)
                local find_command = nil
                if show_hidden then find_command = { 'rg', '--files', '--hidden', '-g', '!.git' } end

                require("telescopePickers").prettyFilesPicker({
                    picker = "find_files",
                    options = {
                        sorter = sorter,
                        previewer = false,
                        layout_strategy = layout(),
                        find_command = find_command,
                        attach_mappings = function(_, map)
                            map("n", "zh", function(prompt_bufnr)
                                actions.close(prompt_bufnr)
                                files(not show_hidden)
                            end)
                            return true
                        end,
                    }
                })
            end

            vim.api.nvim_create_user_command('Files', function() files() end, {})
            vim.keymap.set("n", "<leader>f", files, {})

            vim.keymap.set("n", "<leader>F", function()
                require("telescopePickers").prettyGrepPicker({
                    picker = "live_grep",
                    options = { layout_strategy = layout() }
                })
            end, {})
            vim.keymap.set("n", "<leader>s", function()
                require("telescopePickers").prettyWorkspaceSymbolsPicker({
                    sorter = sorter,
                    prompt_title = "Workspace symbols",
                    layout_strategy = layout(),
                })
            end, {})
            vim.keymap.set("n", "<leader>d", function()
                require("telescopePickers").prettyGitPicker({
                    sorter          = sorter,
                    layout_strategy = layout(),
                })
            end, {})
            vim.keymap.set("n", "<leader>h", function()
                tele_builtin.git_bcommits({
                    layout_strategy = layout(),
                })
            end, {})

            vim.api.nvim_create_user_command('Highlights', "lua require('telescope.builtin').highlights()", {})
        end,
    },

    -- git gutter to the left
    {
        'airblade/vim-gitgutter',
        init = function()
            vim.g["gitgutter_map_keys"] = 0
            vim.g["gitgutter_show_msg_on_hunk_jumping"] = 0
            -- vim.g["gitgutter_signs"] = 0
            vim.g["gitgutter_highlight_linenrs"] = 1
            vim.g["gitgutter_sign_allow_clobber"] = 0
            vim.g["gitgutter_sign_removed"] = "⠀"
            vim.g["gitgutter_sign_added"] = "⠀"
            vim.g["gitgutter_sign_modified"] = "⠀"
            vim.g["gitgutter_sign_removed"] = "⠀"
            vim.g["gitgutter_sign_removed_first_line"] = "⠀"
            vim.g["gitgutter_sign_removed_above_and_below"] = "⠀"
            vim.g["gitgutter_sign_modified_removed"] = "⠀"
        end,
        config = function()
            -- nnoremap <leader>gh <Plug>(GitGutterPreviewHunk)
            vim.api.nvim_set_keymap('n', '<C-A-Z>',
                "<Plug>(GitGutterUndoHunk)",
                { silent = true });
            vim.api.nvim_set_keymap('n', '[c',
                "<Plug>(GitGutterPrevHunk) | :let g:gitgutter_floating_window_options['border'] = 'rounded'<CR> | <Plug>(GitGutterPreviewHunk)",
                { silent = true });
            vim.api.nvim_set_keymap('n', ']c',
                "<Plug>(GitGutterNextHunk) | :let g:gitgutter_floating_window_options['border'] = 'rounded'<CR> | <Plug>(GitGutterPreviewHunk)",
                { silent = true });
        end
    },

    -- file manager {{{
    {
        'rafaqz/ranger.vim',
        dependencies = { 'rbgrouleff/bclose.vim' },
        config = function()
            vim.g['ranger_map_keys'] = 0
            vim.keymap.set("n", "<leader>l", ":RangerEdit<CR>", {})
        end,
    },
    -- {
    --     'kevinhwang91/rnvimr',
    --     init = function()
    --         vim.g["rnvimr_draw_border"] = 0
    --         vim.g["rnvimr_layout"] = {
    --             width = 140,
    --             relative = 'editor',
    --             -- width= 'float2nr(round(0.7 * &columns))',
    --             height = 60,
    --             col = 0,
    --             row = 5,
    --             style = 'minimal',
    --         }
    --     end,
    -- },
    --- }}}
    -- language-specific stuff {{{

    -- rust
    { 'rust-lang/rust.vim',       ft = 'rust' },
    { 'arzg/vim-rust-syntax-ext', ft = 'rust' },

    -- }}}
    -- misc {{{

    -- mappings to easily delete, change and add such surroundings in pairs, such as quotes, parens, etc.
    'tpope/vim-surround',

    -- convinient pair mappings
    --Plug 'tpope/vim-unimpaired'

    -- enables repeating other supported plugins with the . command
    'tpope/vim-repeat',

    -- }}}
})



local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }


vim.api.nvim_set_keymap('n', 'gd', "<Plug>(coc-definition)", { silent = true });
vim.api.nvim_set_keymap('n', 'gy', "<Plug>(coc-type-definition)", { silent = true });
vim.api.nvim_set_keymap('n', 'gi', "<Plug>(coc-implementation)", { silent = true });
-- vim.api.nvim_set_keymap('n', 'gr', ":Telescope coc references<CR>", { silent = true });

vim.keymap.set('n', 'gr', function()
    require('telescope._extensions').manager.coc.references_used({
        layout_strategy = "vertical",
        on_complete = {
            function(picker)
                -- remove this on_complete callback
                picker:clear_completion_callbacks()
                -- if we have exactly one match, select it
                if picker.manager.linked_states.size == 1 then
                    require("telescope.actions").select_default(picker.prompt_bufnr)
                end
            end,
        }
    })
end)

vim.api.nvim_set_keymap('n', ']e', "<Plug>(coc-diagnostic-next)", { silent = true });
vim.api.nvim_set_keymap('n', '[e', "<Plug>(coc-diagnostic-prev)", { silent = true });
vim.api.nvim_set_keymap('n', '<A-S-e>', "<Plug>(coc-rename)", { silent = true });
vim.api.nvim_set_keymap('n', '<A-S-r>', "<Plug>(coc-refactor)", { silent = true });
vim.api.nvim_set_keymap('v', '<A-S-r>', "<Plug>(coc-refactor-selected)", { silent = true });
-- show outline (hierarchy)

function set_timeout(timeout, callback)
    local uv = vim.loop
    local timer = uv.new_timer()
    local function ontimeout()
        uv.timer_stop(timer)
        uv.close(timer)
        callback(timer)
    end
    uv.timer_start(timer, timeout, 0, ontimeout)
    return timer
end

function toggleOutline()
    local win_id = vim.api.nvim_eval("coc#window#find('cocViewId', 'OUTLINE')")
    if win_id == -1 then
        vim.fn.CocAction("showOutline", 1)

        -- local foo = vim.api.nvim_eval("coc#float#get_float_by_kind('outline-preview')")
        -- print(foo)

        set_timeout(300, function()
            vim.schedule(function()
                win_id = vim.api.nvim_eval("coc#window#find('cocViewId', 'OUTLINE')")
                if win_id == -1 then return end
                vim.api.nvim_set_current_win(win_id)
            end)
        end);
    else
        vim.api.nvim_command("call coc#window#close(" .. win_id .. ")")
    end
end

vim.keymap.set('n', 'go', toggleOutline, { silent = true });
-- list warnings/errors
-- vim.api.nvim_set_keymap('n', 'ge', ":CocFzfList diagnostics<CR>", { silent = true });
-- list all local changes
vim.api.nvim_set_keymap("n", 'gD', ":GF?<CR>", { silent = true });

vim.keymap.set("i", "<C-Space>", "coc#refresh()", { expr = true, silent = true })

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

-- _G.CloseAllFloatingWindows = function()
--     local closed_windows = {}
--     for _, win in ipairs(vim.api.nvim_list_wins()) do
--         local config = vim.api.nvim_win_get_config(win)
--         if config.relative ~= "" then          -- is_floating_window?
--             vim.api.nvim_win_close(win, false) -- do not force
--             table.insert(closed_windows, win)
--         end
--     end
--     print(string.format('Closed %d windows: %s', #closed_windows, vim.inspect(closed_windows)))
-- end
-- vim.keymap.set('i', '<ESC>', "coc#util#has_float() ? <CMD>lua _G.show_docs()<CR> : <ESC>", { expr = true });

-- show docs
function _G.show_docs()
    local cw = vim.fn.expand("<cword>")
    --if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
    --    vim.api.nvim_command('h ' .. cw)
    if vim.api.nvim_eval("coc#rpc#ready()") then
        vim.fn.CocActionAsync("doHover")
    else
        vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
    end
end

vim.keymap.set("n", "<C-P>", "<CMD>lua _G.show_docs()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-S-p>", "<CMD>lua _G.show_docs()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<F12>", "<CMD>lua _G.show_docs()<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-P>", "<CMD>lua _G.show_docs()<CR>", { noremap = true, silent = true })
vim.keymap.set('i', '<C-S-p>', "CocActionAsync('showSignatureHelp')", { silent = true, expr = true });
vim.keymap.set('i', '<F12>', "CocActionAsync('showSignatureHelp')", { silent = true, expr = true });


vim.keymap.set("n", "<A-S-i>", '  :Files<CR>', { noremap = true, silent = true })

-- tab/S-tab completion menu
function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- make <CR> accept selected completion item or notify coc.nvim to format
vim.keymap.set("i", "<TAB>",
    "coc#pum#visible() ? coc#_select_confirm() :" ..
    [[coc#expandableOrJumpable() ? "<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])<CR>" :]] ..
    "v:lua.check_back_space() ? '<TAB>' :" ..
    "coc#refresh()"
    , opts)

vim.keymap.set("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
vim.keymap.set("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
-- code actions
vim.keymap.set("n", "ga", "<Plug>(coc-codeaction-cursor)", { silent = true })
-- refactor
vim.keymap.set("n", "<leader>r", "<Plug>(coc-codeaction-refactor)", { silent = true })

-- reformat code
vim.keymap.set("x", "gl", "<Plug>(coc-format-selected)", { silent = true })
vim.keymap.set("n", "gl", "<Plug>(coc-format)", { silent = true })

vim.api.nvim_create_autocmd("FileType", {
    group = "CocGroup",
    pattern = "lua",
    command = "setl formatexpr=CocAction('formatSelected')",
})

-- language specific {{{

vim.api.nvim_create_autocmd("FileType", {
    group = "CocGroup",
    pattern = "rust",
    callback = function()
        vim.api.nvim_command("call arpeggio#map('i', '', 0, 'al', 'println!(\"\");<left><left><left>')")
    end
})

vim.api.nvim_create_autocmd("FileType", {
    group = "CocGroup",
    pattern = "typescriptreact",
    callback = function()
        vim.api.nvim_command("call arpeggio#map('i', '', 0, 'al', 'console.log();<left><left>')")
    end
})

-- }}}

-- auto-save on focus lost/buffer change
vim.o.autowriteall = true
vim.api.nvim_create_autocmd("FocusLost", {
    group = "CocGroup",
    -- pattern = {
    --     '*.js',
    --     '*.json',
    --     '*.jsx',
    --     '*.py',
    --     '*.rs',
    --     '*.ts',
    --     '*.tsx',
    -- },
    callback = function()
        -- only for files
        if vim.bo.buftype ~= "" then return end
        if not vim.api.nvim_eval("coc#rpc#ready()") then return end
        if not vim.fn.CocAction("hasProvider", "format") then return end
        vim.fn.CocAction("format")
    end
})
vim.api.nvim_create_autocmd("FocusLost", {
    group = "CocGroup",
    callback = function()
        -- only for files
        if vim.bo.buftype ~= "" then return end
        vim.cmd.write({ mods = { silent = true } })
    end
})

-- disable wraps for coc preview buffers
vim.api.nvim_create_autocmd("User", {
    pattern = "CocOpenFloat",
    group = "CocGroup",
    callback = function()
        win_id = vim.g['coc_last_float_win']
        vim.api.nvim_command("call win_execute(" .. win_id .. ", 'set nowrap')")
    end
})
