local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.api.nvim_create_augroup("default", { clear = true })

require("lazy").setup({
	-- additional motion targets {{{
	{
		"https://github.com/wellle/targets.vim",
	},
	-- }}}
	-- pretty folds {{{
	{
		"anuvyklack/pretty-fold.nvim",
		config = function()
			require("pretty-fold").setup({
				fill_char = " ",
				sections = {
					left = { "content" },
					right = {
						" ",
						"number_of_folded_lines",
						function(config)
							return config.fill_char:rep(3)
						end,
					},
				},
				process_comment_signs = false,
			})
		end,
	},
	-- }}}
	-- highlight symbol under cursor {{{
	{
		"RRethy/vim-illuminate",
		event = "VeryLazy",
		config = function()
			require("illuminate").configure({
				providers = {
					"lsp",
					"treesitter",
				},
				delay = 200,
			})
		end,
	},
	-- }}}
	-- better quickfix window {{{
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		config = function()
			require("bqf").setup({ preview = { winblend = 0 } })
		end,
	},
	-- }}}
	-- chord keybinds {{{
	{
		"kana/vim-arpeggio",
		init = function()
			-- vim.g.arpeggio_timeoutlen = 40
		end,
		config = function()
			-- write
			vim.api.nvim_command("silent call arpeggio#map('n', '', 0, 'we', ':FormatAndSave<cr>')")
			-- write-quit
			vim.api.nvim_command("silent call arpeggio#map('n', '', 0, 'wq', ':wq<cr>')")
			-- write-quit-all
			vim.api.nvim_command("silent call arpeggio#map('n', '', 0, 'wr', ':wqa<cr>')")
			-- write-quit
			vim.api.nvim_command("silent call arpeggio#map('i', '', 0, 'wq', '<ESC>:wq<CR>')")
			-- insert mode
			vim.api.nvim_command("silent call arpeggio#map('i', '', 0, 'fun', 'function')")
			-- save
			vim.api.nvim_command("silent call arpeggio#map('i', '', 0, 'jk', '<ESC>')")
			-- close buffer
			vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'ap', '<ESC>:q<CR>')")
			-- only buffer
			vim.api.nvim_command("call arpeggio#map('n', 's', 0, 'ao', '<C-w>o')")
			-- Ag
			-- vim.api.nvim_command("call arpeggio#map('n', '', 0, 'ag', ':Ag<CR>')")

			-- files, surpress false warning about jk being mapped already
			vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'jk', ':Files<cr>')")
			-- vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'di', '<CMD>wincmd w<CR>')")

			-- common movement shortcuts

			-- vim.api.nvim_create_user_command("ArpeggioReplaceWord", function()
			-- 	vim.fn.feedkeys("cimw")
			-- end, {})
			-- vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'mw', '<cmd>silent ArpeggioReplaceWord<cr>')")
			--
			-- vim.api.nvim_create_user_command("ArpeggioReplaceTag", function()
			-- 	vim.fn.feedkeys("cimt")
			-- end, {})
			-- vim.api.nvim_command("silent call arpeggio#map('n', 's', 0, 'mt', '<cmd>silent ArpeggioReplaceTag<cr>')")

			registerMapping = function(name, mapping, target)
				vim.api.nvim_create_user_command("ArpeggioLeap" .. name, function()
					vim.fn.feedkeys("cim" .. target)
				end, {})
				vim.api.nvim_command(
					"silent call arpeggio#map('n', 's', 0, '"
						.. mapping
						.. "', '<cmd>silent ArpeggioLeap"
						.. name
						.. "<cr>')"
				)
			end

			registerMapping("Word", "mw", "w")
			registerMapping("Tag", "mt", "t")
			registerMapping("DQuote", "mq", '"')
			registerMapping("SQuote", "ma", "'")
			registerMapping("Backtick", "md", "`")
			registerMapping("Brace", "mb", "{")
			registerMapping("Bracket", "mv", "[")
			registerMapping("Parenthesis", "mf", "(")
		end,
	},
	-- }}}
	-- CWD managmnent {{{
	{
		"airblade/vim-rooter",
		event = "VeryLazy",
		init = function()
			vim.g.rooter_change_directory_for_non_project_files = "current"
			vim.g.rooter_silent_chdir = 1
			vim.g.rooter_resolve_links = 1
			vim.g.rooter_patterns = { "cargo.toml", ".git" }

			-- only if requested
			vim.g.rooter_manual_only = 1

			-- cwd to root
			-- nmap <leader>;r :Rooter<cr>
			-- cwd to current
			-- nmap <leader>;t :cd %:p:h<cr>
			-- auto change cwd to current file
			-- set autochdir
		end,
	},
	-- }}}
	-- GIT {{{
	{
		"tpope/vim-fugitive",
		lazy = true,
		keys = {
			{ "<leader>gd", ":Gdiff<CR>" },
		},
		init = function()
			vim.opt.diffopt = vim.opt.diffopt + "vertical"

			-- vim.keymap.set("n", "<leader>gd", ":Gdiff<CR>", {})
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
		end,
	},
	-- }}}
	-- syntax highlight {{{
	{
		"nvim-treesitter/nvim-treesitter",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"typescript",
					"tsx",
					"javascript",
					"css",
					"scss",
					"styled",
					"rust",
					"json",
					"lua",
					"sql",
				},
				auto_install = true,
				highlight = { enable = true },
				incremental_selection = { enable = true },
				indent = { enable = true },
				context_commentstring = { enable = true },
			})
			-- vim.o.foldmethod = "expr"
			-- vim.o.foldexpr = "nvim_treesitter#foldexpr()"
		end,
	},
	-- }}}
	-- movement {{{
	{
		"ggandor/leap.nvim",
		init = function() end,
		config = function()
			local leap = require("leap")
			-- leap.opts.case_sensitive = true
			leap.opts.safe_labels = "sfnut"
			leap.opts.labels = "abcdefghijklmnopqrstuvwxyz"

			vim.keymap.set("n", "s", "<Plug>(leap-forward-to)")
			vim.keymap.set("n", "S", "<Plug>(leap-backward-to)")
		end,
	},
	{
		"ggandor/leap-spooky.nvim",
		config = function()
			require("leap-spooky").setup({})

			-- remove all insert mode binds we don't like
			for _, value in ipairs(vim.api.nvim_get_keymap("x")) do
				if value.lhs:sub(1, 1) == "i" or value.lhs:sub(1, 1) == "x" then
					vim.keymap.del("x", value.lhs, {})
				end
			end
		end,
	},
	{
		"haya14busa/incsearch.vim",
		dependencies = { "haya14busa/incsearch-fuzzy.vim" },
		keys = {
			{ "<leader>/", "<Plug>(incsearch-fuzzy-/)" },
			{ "<leader>?", "<Plug>(incsearch-fuzzy-?)" },
		},
		init = function()
			vim.g["incsearch#auto_nohlsearch"] = 1
		end,
	},
	-- }}}
	-- LSP server, auto-complete {{{
	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvimtools/none-ls-extras.nvim" },
		event = "VeryLazy",
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					require("none-ls.code_actions.eslint"),
					-- null_ls.builtins.completion.spell,
				},
			})
		end,
	},
	-- lua VIM documentation
	{
		"folke/neodev.nvim",
		ft = "lua",
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			require("neodev").setup({})
			local lspconfig = require("lspconfig")
			lspconfig["lua_ls"].setup({})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		event = "VeryLazy",
		init = function()
			local signs = {
				Error = "☢️",
				Warn = "⚠",
				Hint = "❓",
				Info = "ℹ",
			}

			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl })
			end

			vim.diagnostic.config({
				virtual_text = false,
				update_in_insert = true,
				float = { border = "rounded" },
				signs = { priority = 200 },
			})
			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = "rounded",
				close_events = { "BufHidden", "InsertLeave" },
			})
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
		end,
		config = function()
			local lspconfig = require("lspconfig")
			require("mason").setup()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"stylua",
					"prettierd",
					"typescript-language-server",
					"lua-language-server",
					"rust-analyzer",
					"tailwindcss-language-server",
					"emmet-language-server",
					"taplo",
					"eslint-lsp",
					"json-lsp",
				},
			})
			local servers = { "jsonls", "tailwindcss", "eslint", "rust_analyzer", "emmet_language_server", "taplo" }

			for _, lsp in ipairs(servers) do
				lspconfig[lsp].setup({})
			end
		end,
	},
	-- }}}
	-- refactoring {{{
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim",
		},
		lazy = true,
		config = function()
			require("telescope").load_extension("refactoring")
			require("refactoring").setup()
		end,
	},
	-- }}}
	-- autoamtically close/rename JSX tags {{{
	{
		"windwp/nvim-ts-autotag",
		event = "VeryLazy",
		opts = {},
		ft = { "typescriptreact", "javascriptreact" },
	},
	-- }}}
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
		config = function()
			require("typescript-tools").setup({
				settings = {
					publish_diagnostic_on = "change",
					tsserver_file_preferences = { importModuleSpecifierPreference = "non-relative" },
					tsserver_plugins = {
						"@styled/typescript-styled-plugin",
						-- "typescript-styled-plugin",
					},
				},
			})
		end,
	},
	-- hide tailwind strings when not in focus
	{
		dir = "~/.dotfiles/config/nvim/lua/tw-conceal",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {},
		ft = { "html", "typescriptreact" },
	},
	-- NPM package versions
	{
		"vuki656/package-info.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		ft = { "json" },
		opts = {
			hide_up_to_date = true,
			icons = { enable = false },
		},
	},
	-- formatting
	{
		"stevearc/conform.nvim",
		-- event = { "BufReadPre", "BufNewFile" },
		event = "VeryLazy",
		cmd = { "ConformInfo" },
		config = function()
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					lua = { "stylua" },
					svelte = { { "prettierd" } },
					javascript = { { "prettierd" } },
					typescript = { { "prettierd" } },
					javascriptreact = { { "prettierd" } },
					typescriptreact = { { "prettierd" } },
					json = { { "prettierd" } },
					graphql = { { "prettierd" } },
					java = { "google-java-format" },
					kotlin = { "ktlint" },
					ruby = { "standardrb" },
					markdown = { { "prettierd" } },
					erb = { "htmlbeautifier" },
					html = { "htmlbeautifier" },
					bash = { "beautysh" },
					proto = { "buf" },
					rust = { "rustfmt" },
					yaml = { "yamlfix" },
					toml = { "taplo" },
					css = { { "prettierd" } },
					scss = { { "prettierd" } },
				},
			})

			-- vim.keymap.set({ "n", "v" }, "gl", function()
			-- 	conform.format({
			-- 		lsp_fallback = true,
			-- 		async = false,
			-- 		timeout_ms = 500,
			-- 	})
			-- end, { desc = "Format file or range (in visual mode)" })
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		config = function()
			local ls = require("luasnip")
			local s = ls.snippet
			local sn = ls.snippet_node
			local t = ls.text_node
			local i = ls.insert_node
			local f = ls.function_node
			local c = ls.choice_node
			local d = ls.dynamic_node
			local r = ls.restore_node
			local fmt = require("luasnip.extras.fmt").fmt

			ls.add_snippets("typescriptreact", {
				s("comp", {
					t("const "),
					i(1, "Component"),
					t({
						": Component<any> = (props: any) => {",
						"  const {children} = $destructure(props);",
						"  return <div>{children}</div>;",
						"};",
					}),
					i(0),
				}),
				s(
					"For",
					fmt(
						[[
						<For each={{{}}}>
						{{({}) => <>
							{}
						</>}}
						</For>
						]],
						{
							i(1, "[]"),
							i(2, "x"),
							i(0),
						}
					)
				),
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		event = "InsertEnter",
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			vim.opt.completeopt = { "menu", "menuone", "noselect" }

			local has_words_before = function()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				completion = {
					completeopt = "menu,menuone,noinsert",
					-- autocomplete = {
					-- 	cmp.TriggerEvent.TextChanged,
					-- 	cmp.TriggerEvent.InsertEnter,
					-- },
					-- keyword_length = 0,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					-- ["<CR>"] = cmp.mapping.confirm({ select = true }),
					-- ["<Tab>"] = cmp.mapping(function(fallback)
					["<CR>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							-- cmp.select_next_item()
							cmp.confirm({ select = true })
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
							-- elseif has_words_before() then
							-- cmp.complete()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "luasnip" },
					{ name = "nvim_lsp" },
					{ name = "nvim_lsp_signature_help" },
					{ name = "nvim_lua" },
					-- { name = "orgmode" },
				}, {
					{ name = "buffer" },
					{ name = "path" },
				}),
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},
	-- comments {{{
	{
		"numToStr/Comment.nvim",
		dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
		lazy = true,
		init = function()
			-- avoid comment plugin warning
			vim.g.skip_ts_context_commentstring_module = true
		end,
		keys = {
			{ "<C-_>", "", mode = "n" },
			{ "<C-_>", "", mode = "x" },
		},
		config = function()
			require("ts_context_commentstring").setup({ enable_autocmd = false })
			require("Comment").setup({
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})

			vim.api.nvim_command("xmap <C-_> gc")
			vim.api.nvim_command("nmap <C-_> gccj")
		end,
	},
	-- }}}

	-- find and replace {{{
	{
		"nvim-pack/nvim-spectre",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<C-S-R>", "<cmd>lua require('spectre').toggle()<CR>", mode = "n", silent = true },
			{ "<Leader>R", "<cmd>lua require('spectre').toggle()<CR>", mode = "n", silent = true },
		},
	},
	-- }}}
	-- find files, changes and more {{{
	{
		"nvim-telescope/telescope.nvim",
		-- tag = "0.1.5",
		branch = "master",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			-- "fannheyward/telescope-coc.nvim",
			"natecraddock/telescope-zf-native.nvim",
		},
		config = function()
			local telescope_actions = require("telescope.actions")
			require("telescope").setup({
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
			})

			require("telescope").load_extension("zf-native")

			local sorter = require("top-results-sorter").sorter()
			local tele_builtin = require("telescope.builtin")
			local actions = require("telescope.actions")
			function layout()
				local width = vim.fn.winwidth(0)
				local height = vim.fn.winheight(0)

				if (width / 2) > height then
					return "horizontal"
				end
				return "vertical"
			end

			function files(show_hidden)
				-- local find_command = nil
				-- if show_hidden then
				-- find_command = { "rg", "--files", "--hidden", "-g", "!.git" }
				-- end

				require("telescopePickers").prettyFilesPicker({
					picker = "find_files",

					options = {
						sorter = sorter,
						previewer = false,
						layout_strategy = layout(),
						find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
						-- attach_mappings = function(_, map)
						--   map("n", "zh", function(prompt_bufnr)
						--   	actions.close(prompt_bufnr)
						--   	files(not show_hidden)
						--   end)
						--   return true
						-- end,
					},
				})
			end

			vim.api.nvim_create_user_command("Files", function()
				files()
			end, {})
			vim.keymap.set("n", "<leader>f", function()
				tele_builtin.resume()
			end, {})

			vim.keymap.set("n", "<leader>F", function()
				require("telescopePickers").prettyGrepPicker({
					picker = "live_grep",
					options = { layout_strategy = layout() },
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
					sorter = sorter,
					layout_strategy = layout(),
				})
			end, {})
			vim.keymap.set("n", "<leader>h", function()
				tele_builtin.git_bcommits({
					layout_strategy = layout(),
				})
			end, {})

			vim.keymap.set("x", "<leader>h", function()
				tele_builtin.git_bcommits_range({
					layout_strategy = layout(),
				})
			end, {})

			vim.keymap.set("n", "gr", function()
				vim.api.nvim_command("m'")
				require("telescope.builtin").lsp_references({
					layout_strategy = layout(),
					-- on_complete = {
					--     function(picker)
					--         -- remove this on_complete callback
					--         picker:clear_completion_callbacks()
					--         -- if we have exactly one match, select it
					--         if picker.manager.linked_states.size == 1 then
					--             require("telescope.actions").select_default(picker.prompt_bufnr)
					--         end
					--     end,
					-- }
				})
			end)

			vim.api.nvim_create_user_command("Highlights", "lua require('telescope.builtin').highlights()", {})
		end,
	},
	-- }}}

	-- git gutter {{{
	{
		"airblade/vim-gitgutter",
		init = function()
			vim.g.gitgutter_map_keys = 0
			vim.g.gitgutter_show_msg_on_hunk_jumping = 0
			-- vim.g["gitgutter_signs"] = 0
			vim.g.gitgutter_highlight_linenrs = 1
			vim.g.gitgutter_sign_allow_clobber = 0
			vim.g.gitgutter_sign_removed = "⠀"
			vim.g.gitgutter_sign_added = "⠀"
			vim.g.gitgutter_sign_modified = "⠀"
			vim.g.gitgutter_sign_removed = "⠀"
			vim.g.gitgutter_sign_removed_first_line = "⠀"
			vim.g.gitgutter_sign_removed_above_and_below = "⠀"
			vim.g.gitgutter_sign_modified_removed = "⠀"
		end,
		config = function()
			-- nnoremap <leader>gh <Plug>(GitGutterPreviewHunk)
			vim.api.nvim_set_keymap("n", "<C-A-Z>", "<Plug>(GitGutterUndoHunk)", { silent = true })
			vim.api.nvim_set_keymap(
				"n",
				"[c",
				"<Plug>(GitGutterPrevHunk) | :let g:gitgutter_floating_window_options['border'] = 'rounded'<CR> | <Plug>(GitGutterPreviewHunk)",
				{ silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"]c",
				"<Plug>(GitGutterNextHunk) | :let g:gitgutter_floating_window_options['border'] = 'rounded'<CR> | <Plug>(GitGutterPreviewHunk)",
				{ silent = true }
			)
		end,
	},
	-- }}}

	-- file manager {{{
	{
		"kevinhwang91/rnvimr",
		keys = { { "<leader>l", "" } },
		init = function()
			vim.g.rnvimr_enable_ex = 1
			vim.g.rnvimr_enable_picker = 1
			vim.g.rnvimr_draw_border = 0
			vim.g.rnvimr_layout = {
				relative = "editor",
				width = vim.fn.winwidth(0),
				height = vim.fn.winheight(0) / 2,
				col = 0,
				row = vim.fn.winheight(0) / 4,
				style = "minimal",
			}
			-- vim.g.rnvimr_ranger_views = {
			-- 	-- { minwidth = 50, maxwidth = 89, ratio = { 1, 1 } },
			-- 	{ ratio = { 1, 1 } },
			-- }
			vim.g.rnvimr_ranger_cmd = {
				"ranger",
				"--cmd=set preview_directories false",
				"--cmd=set column_ratios 2,5,0",
				"--cmd=set preview_files false",
				"--cmd=set preview_images truefalse",
				"--cmd=set padding_right false",
				"--cmd=set collapse_preview true",
			}
		end,
		config = function()
			vim.keymap.set("n", "<leader>l", function()
				vim.api.nvim_command("RnvimrToggle")
			end, {})
		end,
	},
	--- }}}

	-- language-specific stuff {{{

	-- rust
	{ "rust-lang/rust.vim", ft = "rust" },
	{ "arzg/vim-rust-syntax-ext", ft = "rust" },
	-- {
	-- 	"mrcjkb/rustaceanvim",
	-- 	version = "^4", -- Recommended
	-- 	ft = { "rust" },
	-- },
	{
		"saecki/crates.nvim",
		ft = "toml",
		tag = "stable",
		config = function()
			require("crates").setup()
		end,
	},
	-- }}}

	-- misc {{{

	-- detect file shiftwidth, tab mode
	"tpope/vim-sleuth",

	-- mappings to easily delete, change and add such surroundings in pairs, such as quotes, parens, etc.
	{
		"tpope/vim-surround",
		event = "VeryLazy",
	},

	-- convinient pair mappings
	--Plug "tpope/vim-unimpaired"

	-- enables repeating other supported plugins with the . command
	"tpope/vim-repeat",
	-- }}}
	-- pretty UI {{{
	{
		"stevearc/dressing.nvim",
		opts = {},
		event = "VeryLazy",
	},
	-- }}}
	-- show color hex codes {{{
	{
		"NvChad/nvim-colorizer.lua",
		event = "VeryLazy",
		config = function()
			require("colorizer").setup({ user_default_options = { mode = "virtualtext", names = false } })
			-- require("colorizer").attach_to_buffer(0, { mode = "virtualtext", names = false })
			--
			-- vim.api.nvim_create_autocmd("BufEnter", {
			-- 	group = "default",
			-- 	callback = function()
			-- 		require("colorizer").attach_to_buffer(0, { mode = "virtualtext", names = false })
			-- 	end,
			-- })
		end,
	},
	-- }}}
})

local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		-- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	end,
})
-- vim.api.nvim_set_keymap("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
-- vim.api.nvim_set_keymap("n", "gi", "<Plug>(coc-implementation)", { silent = true })
vim.keymap.set("n", "<leader>[e", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<leader>]e", vim.diagnostic.goto_next)
vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end)

vim.keymap.set("n", "<A-S-e>", vim.lsp.buf.rename, { silent = true })
-- vim.api.nvim_set_keymap("n", "<A-S-r>", "<Plug>(coc-refactor)", { silent = true })
-- vim.api.nvim_set_keymap("v", "<A-S-r>", "<Plug>(coc-refactor-selected)", { silent = true })
-- show outline (hierarchy)

-- function set_timeout(timeout, callback)
-- 	local uv = vim.loop
-- 	local timer = uv.new_timer()
-- 	local function ontimeout()
-- 		uv.timer_stop(timer)
-- 		uv.close(timer)
-- 		callback(timer)
-- 	end
-- 	uv.timer_start(timer, timeout, 0, ontimeout)
-- 	return timer
-- end

-- function toggleOutline()
-- 	local win_id = vim.api.nvim_eval("coc#window#find('cocViewId', 'OUTLINE')")
-- 	if win_id == -1 then
-- 		vim.fn.CocAction("showOutline", 1)
--
-- 		-- local foo = vim.api.nvim_eval("coc#float#get_float_by_kind('outline-preview')")
-- 		-- print(foo)
--
-- 		set_timeout(300, function()
-- 			vim.schedule(function()
-- 				win_id = vim.api.nvim_eval("coc#window#find('cocViewId', 'OUTLINE')")
-- 				if win_id == -1 then
-- 					return
-- 				end
-- 				vim.api.nvim_set_current_win(win_id)
-- 			end)
-- 		end)
-- 	else
-- 		vim.api.nvim_command("call coc#window#close(" .. win_id .. ")")
-- 	end
-- end
--
-- vim.keymap.set("n", "go", toggleOutline, { silent = true })
-- list warnings/errors in telescope
-- TODO

-- vim.keymap.set("i", "<C-Space>", "coc#refresh()", { expr = true, silent = true })

-- highlight the symbol under cursor
-- vim.api.nvim_create_autocmd("CursorHold", {
--     group = "CocGroup",
--     command = "silent call CocActionAsync('highlight')",
--     desc = "Highlight symbol under cursor on CursorHold"
-- })
--
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

vim.keymap.set("n", "<C-P>", vim.lsp.buf.hover, { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-S-p>", "<CMD>lua _G.show_docs()<CR>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<F12>", "<CMD>lua _G.show_docs()<CR>", { noremap = true, silent = true })
-- vim.keymap.set("i", "<C-P>", "<CMD>lua _G.show_docs()<CR>", { noremap = true, silent = true })
-- vim.keymap.set("i", "<C-S-p>", "CocActionAsync('showSignatureHelp')", { silent = true, expr = true })
-- vim.keymap.set("i", "<F12>", "CocActionAsync('showSignatureHelp')", { silent = true, expr = true })
-- undo/redo
-- vim.keymap.set("n", "<leader>u", "<cmd>CocCommand workspace.undo<cr>')", { silent = true })
-- vim.keymap.set("n", "<leader><S-u>", "<cmd>CocCommand workspace.redo<cr>')", { silent = true })

-- tab/S-tab completion menu
function _G.check_back_space()
	local col = vim.fn.col(".") - 1
	return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
end

-- code actions
vim.keymap.set({ "n", "v" }, "<space>a", vim.lsp.buf.code_action, { silent = true })
-- refactor
vim.keymap.set({ "n", "x" }, "<leader>r", function()
	require("telescope").extensions.refactoring.refactors()
end, { silent = true })
vim.api.nvim_create_user_command("RenameFile", "silent CocCommand workspace.renameCurrentFile", {})

local function quickfix()
	vim.lsp.buf.code_action({
		filter = function(a)
			return a.isPreferred
		end,
		apply = true,
	})
end
vim.keymap.set("n", "<leader>qf", quickfix, { silent = true })

-- reformat code
-- vim.keymap.set("n", "gl", function()
-- 	-- organize_imports()
-- 	format({
-- 		callback = save,
-- 	})
-- end, opts)

vim.keymap.set("n", "gl", function()
	organize_imports()
	format({ callback = save })
end, {})

vim.api.nvim_create_autocmd("FileType", {
	group = "default",
	pattern = "lua",
	command = "setl formatexpr=CocAction('formatSelected')",
})

-- language specific {{{

vim.api.nvim_create_autocmd("FileType", {
	group = "default",
	pattern = "rust",
	callback = function()
		vim.api.nvim_command("call arpeggio#map('i', '', 0, 'al', 'println!(\"\");<left><left><left>')")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = "default",
	pattern = { "javascript", "typescript", "typescriptreact" },
	callback = function()
		vim.api.nvim_command("call arpeggio#map('n', '', 0, 'al', 'aconsole.log();<left><left>')")
		-- make import lazy
		vim.keymap.set(
			"n",
			";1",
			'0ciwconst<esc>/from<cr>ciw= lazy(() => import(<esc>lxf"a))<esc>0',
			{ silent = true, noremap = true }
		)
		-- create component
		vim.keymap.set(
			"n",
			";1",
			'0ciwconst<esc>/from<cr>ciw= lazy(() => import(<esc>lxf"a))<esc>0',
			{ silent = true, noremap = true }
		)
	end,
})

-- quickfix
vim.api.nvim_create_autocmd("FileType", {
	group = "default",
	pattern = "qf",
	callback = function()
		print(99)
		vim.keymap.set("n", "dd", function()
			local curqfidx = vim.fn.line(".")
			local entries = vim.fn.getqflist()
			if entries == nil then
				return
			end
			if #entries == 0 then
				return
			end
			-- remove the item from the quickfix list
			table.remove(entries, curqfidx)
			vim.fn.setqflist(entries, "r")
			-- reopen quickfix window to refresh the list
			vim.cmd("copen")
			local new_idx = curqfidx < #entries and curqfidx or math.max(curqfidx - 1, 1)
			local winid = vim.fn.win_getid()
			if winid == nil then
				return
			end
			vim.api.nvim_win_set_cursor(winid, { new_idx, 0 })
		end, { silent = true, noremap = true, buffer = 0 })
	end,
})

vim.keymap.set("n", "<leader>n", function()
	local qf_exists = false
	local info = vim.fn.getwininfo()
	if info == nil then
		return
	end
	for _, win in pairs(info) do
		if win["quickfix"] == 1 then
			qf_exists = true
		end
	end
	if qf_exists == true then
		return vim.cmd("cclose")
	end
	local info = vim.fn.getwininfo()
	if info == nil then
		return
	end
	if not vim.tbl_isempty(info) then
		return vim.cmd("copen")
	end
end, {})

-- }}}

function format(opts)
	opts = opts or {}
	-- only for files
	if vim.bo.buftype ~= "" then
		return
	end

	-- pcall(function()
	require("conform").format({
		async = true,
		lsp_fallback = true,
		timeout_ms = 500,
	}, opts.callback)
	-- end)
end

vim.api.nvim_create_user_command("Format", format, {})
vim.api.nvim_create_user_command("FormatAndSave", function()
	format({
		callback = function()
			save()
		end,
	})
end, {})

function organize_imports()
	if
		vim.bo.filetype == "typescript"
		or vim.bo.filetype == "typescriptreact"
		or vim.bo.filetype == "javascript"
		or vim.bo.filetype == "javascriptreact"
	then
		require("typescript-tools.api").add_missing_imports(true)
		require("typescript-tools.api").organize_imports(true)
	end
end

function save()
	-- only for files
	if vim.bo.buftype ~= "" then
		return
	end
	local filename = vim.api.nvim_buf_get_name(0)
	if filename == "" then
		return
	end
	if not vim.opt.modified:get() then
		return
	end
	if vim.fn.filereadable(filename) ~= 1 then
		return
	end
	vim.cmd.write({ mods = { silent = true } })
end

-- format on explicit save
vim.keymap.set("n", "<leader>w", function()
	format({ callback = save })
end, {})
-- auto-save on focus lost/buffer change
vim.o.autowriteall = true
vim.api.nvim_create_autocmd("FocusLost", {
	group = "default",
	callback = save,
})

-- show command bar message when recording macros
-- https://github.com/neovim/neovim/issues/19193
vim.api.nvim_create_autocmd("RecordingEnter", { group = "default", command = "set cmdheight=1" })
vim.api.nvim_create_autocmd("RecordingLeave", { group = "default", command = "set cmdheight=0" })

-- move cursor and scroll by a fixed distance, with center support
function Jump(distance, center)
	local view_info = vim.fn.winsaveview()
	if view_info == nil then
		return
	end

	local height = vim.fn.winheight(0)
	local cursor_row = view_info.lnum
	local buffer_lines = vim.fn.line("$")

	local target_row = math.min(cursor_row + distance, buffer_lines)
	if center then
		-- scroll center cursor
		view_info.topline = target_row - math.floor(height / 2)
	else
		-- scroll by distance
		view_info.topline = math.max(view_info.topline + distance, 1)
	end
	-- avoid scrolling past last line
	view_info.topline = math.min(view_info.topline, math.max(buffer_lines - height - 6, 1))
	view_info.lnum = target_row

	vim.fn.winrestview(view_info)
end

vim.keymap.set("n", "<C-u>", function()
	Jump(math.max(vim.v.count, 1) * -18, true)
end, {})
vim.keymap.set("n", "<C-d>", function()
	Jump(math.max(vim.v.count, 1) * 18, true)
end, {})
vim.keymap.set("n", "<C-b>", function()
	Jump(math.max(vim.v.count, 1) * -32, true)
end, {})
vim.keymap.set("n", "<C-f>", function()
	Jump(math.max(vim.v.count, 1) * 32, true)
end, {})

vim.keymap.set("n", "<C-y>", function()
	Jump(math.max(vim.v.count, 1) * -3)
end, {})
vim.keymap.set("n", "<C-e>", function()
	Jump(math.max(vim.v.count, 1) * 3)
end, {})

-- paste with indent by default, this needs to be after plugins
vim.keymap.set("n", "p", "]p=`]", { silent = true, noremap = true })
vim.keymap.set("n", "<S-p>", "]P=`]", { silent = true, noremap = true })

-- restore substitute functionality
vim.keymap.set("x", "z", "s", { noremap = true })

-- set foldmethod since its being overriden by plugins
vim.opt.foldmethod = "indent"

-- TODO more plugins!
-- https://neovimcraft.com/plugin/jackMort/ChatGPT.nvim
-- https://neovimcraft.com/plugin/folke/noice.nvim
-- rust
-- https://github.com/Saecki/crates.nvim
-- https://neovimcraft.com/plugin/simrat39/rust-tools.nvim

-- vim.api.nvim_create_autocmd("User", {
-- 	pattern = "SuperLazy",
-- 	group = "default",
-- 	callback = function()
-- 		print("hello")
-- 	end,
-- })

-- vim.api.nvim_create_autocmd("BufEnter", {
-- 	group = "default",
-- 	callback = function()
-- 		local uv = vim.loop
-- 		local timer = uv.new_timer()
-- 		timer:start(
-- 			1000,
-- 			0,
-- 			vim.schedule_wrap(function()
-- 				print("?")
-- 				-- vim.api.nvim_exec_autocmds("User", { pattern = "SuperLazy" })
-- 				-- vim.api.nvim_exec
-- 				vim.api.nvim_command("LazyLoad")
-- 			end)
-- 		)
-- 	end,
-- })
