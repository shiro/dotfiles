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

local notify = function(message)
  if type(message) == "string" then
    require("notify")(message)
  else
    require("notify")(vim.inspect(message))
  end
end

function set_timeout(timeout, callback)
  local uv = vim.loop
  local timer = uv.new_timer()
  local function ontimeout()
    uv.timer_stop(timer)
    uv.close(timer)
    vim.schedule(function() callback(timer) end)
  end
  uv.timer_start(timer, timeout, 0, ontimeout)
  return timer
end

require("lazy").setup({
  require("plugins.targets"),
  require("plugins.notifications"),
  require("plugins.chords"),
  require("plugins.git"),

  require("plugins.outline"),
  require("plugins.jumping"),

  require("plugins.quickfix"),
  require("plugins.environment"),
  require("plugins.folds"),
  require("plugins.highlight"),
  require("plugins.lsp"),
  require("plugins.completion"),

  require("plugins.language-typescript"),
  require("plugins.language-markdown"),
  require("plugins.language-go"),

  require("plugins.copy-imports"),
  require("plugins.formatting"),
  require("plugins.comments"),
  require("plugins.refactor"),
  require("plugins.telescope"),
  require("plugins.file-manager"),
  require("plugins.fancy"),
  require("plugins.diff"),

  require("plugins.github"),
  require("plugins.obsidian"),
}, { rocks = { enabled = false } })

-- vim.api.nvim_set_keymap("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
-- vim.api.nvim_set_keymap("n", "gi", "<Plug>(coc-implementation)", { silent = true })
vim.keymap.set("n", "<leader>[e", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<leader>]e", vim.diagnostic.goto_next)
vim.keymap.set("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end)
vim.keymap.set("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end)

-- vim.keymap.set("n", "<A-S-e>", vim.lsp.buf.rename, {})
vim.keymap.set("n", "<leader>e", vim.lsp.buf.rename, {})
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
-- function _G.show_docs()
-- 	local cw = vim.fn.expand("<cword>")
-- 	--if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
-- 	--    vim.api.nvim_command('h ' .. cw)
-- 	if vim.api.nvim_eval("coc#rpc#ready()") then
-- 		-- vim.fn.CocActionAsync("doHover")
-- 	else
-- 		vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
-- 	end
-- end

vim.keymap.set(
  "n",
  "<C-P>",
  function() vim.lsp.buf.hover({ border = "rounded" }) end,
  { noremap = true, silent = true }
)
-- vim.keymap.set("n", "<C-S-p>", "<CMD>lua _G.show_docs()<CR>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<F12>", "<CMD>lua _G.show_docs()<CR>", { noremap = true, silent = true })
-- vim.keymap.set("i", "<C-P>", "<CMD>lua _G.show_docs()<CR>", { noremap = true, silent = true })

-- tab/S-tab completion menu
function _G.check_back_space()
  local col = vim.fn.col(".") - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
end

-- code actions
vim.keymap.set({ "n", "v" }, "<space>a", vim.lsp.buf.code_action, { silent = true })
vim.keymap.set(
  { "n", "v" },
  "<space>k",
  function() require("telescope").extensions.omnibar.omnibar() end,
  { silent = true }
)
-- refactor
vim.keymap.set(
  { "n", "x" },
  "<leader>r",
  function() require("telescope").extensions.refactoring.refactors() end,
  { silent = true }
)
vim.api.nvim_create_user_command("RenameFile", "silent CocCommand workspace.renameCurrentFile", {})

local function quickfix()
  vim.lsp.buf.code_action({
    filter = function(a) return a.isPreferred end,
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
  pattern = { "javascript", "typescript", "typescriptreact" },
  callback = function()
    -- vim.api.nvim_command("call arpeggio#map('n', '', 0, 'al', 'aconsole.log();<left><left>')")
    -- make import lazy
    -- vim.keymap.set(
    --   "n",
    --   ";1",
    --   '0ciwconst<esc>/from<cr>ciw= lazy(() => import(<esc>lxf"a))<esc>0',
    --   { silent = true, noremap = true }
    -- )
    -- create component
    -- vim.keymap.set(
    --   "n",
    --   ";1",
    --   '0ciwconst<esc>/from<cr>ciw= lazy(() => import(<esc>lxf"a))<esc>0',
    --   { silent = true, noremap = true }
    -- )
  end,
})

vim.keymap.set("n", "<leader>n", function()
  local qf_exists = false
  local info = vim.fn.getwininfo()
  if info == nil then return end
  for _, win in pairs(info) do
    if win["quickfix"] == 1 then qf_exists = true end
  end
  if qf_exists == true then return vim.cmd("cclose") end
  local info = vim.fn.getwininfo()
  if info == nil then return end
  if not vim.tbl_isempty(info) then return vim.cmd("copen") end
end, {})

-- }}}

function format(opts)
  opts = opts or {}
  -- only for files
  if vim.bo.buftype ~= "" then return end

  -- pcall(function()
  require("conform").format({
    async = true,
    lsp_fallback = true,
    timeout_ms = 500,
  }, opts.callback)
  -- end)
end
vim.g.format = format

vim.api.nvim_create_user_command("Format", format, {})
vim.api.nvim_create_user_command("FormatAndSave", function() format({ callback = save }) end, {})

function organize_imports()
  if
    vim.bo.filetype == "typescript"
    or vim.bo.filetype == "typescriptreact"
    or vim.bo.filetype == "javascript"
    or vim.bo.filetype == "javascriptreact"
  then
    pcall(function()
      require("typescript-tools.api").add_missing_imports(true)
      -- requireTSToolsRemoveUnusedImports("typescript-tools.api").organize_imports(true)
      require("typescript-tools.api").remove_unused_imports(true)
    end)
  end
end

function save()
  -- only for files
  if vim.bo.buftype ~= "" then return end
  local filename = vim.api.nvim_buf_get_name(0)
  if filename == "" then return end
  if not vim.opt.modified:get() then return end
  if vim.fn.filereadable(filename) ~= 1 then return end
  vim.cmd.write({ mods = { silent = true } })
end

-- format on explicit save
vim.keymap.set("n", "<leader>w", save, {})
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
  if view_info == nil then return end

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

vim.keymap.set("n", "<C-u>", function() Jump(math.max(vim.v.count, 1) * -18, true) end, {})
vim.keymap.set("n", "<C-d>", function() Jump(math.max(vim.v.count, 1) * 18, true) end, {})
vim.keymap.set("n", "<C-b>", function() Jump(math.max(vim.v.count, 1) * -32, true) end, {})
vim.keymap.set("n", "<C-f>", function() Jump(math.max(vim.v.count, 1) * 32, true) end, {})

vim.keymap.set("n", "<C-y>", function() Jump(math.max(vim.v.count, 1) * -3) end, {})
vim.keymap.set("n", "<C-e>", function() Jump(math.max(vim.v.count, 1) * 3) end, {})

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

require("keybinds.general")
require("keybinds.jsx")
