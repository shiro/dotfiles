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
  spec = {
    { import = "plugins.theme" },

    { import = "plugins.targets" },
    { import = "plugins.notifications" },
    { import = "plugins.chords" },
    { import = "plugins.git" },

    { import = "plugins.outline" },
    { import = "plugins.jumping" },

    { import = "plugins.quickfix" },
    { import = "plugins.environment" },
    { import = "plugins.folds" },
    { import = "plugins.highlight" },
    { import = "plugins.lsp" },
    { import = "plugins.completion" },

    { import = "plugins.language-typescript" },
    { import = "plugins.language-markdown" },
    { import = "plugins.language-go" },
    { import = "plugins.language-rust" },

    { import = "plugins.copy-imports" },
    { import = "plugins.formatting" },
    { import = "plugins.comments" },
    { import = "plugins.refactor" },
    { import = "plugins.telescope" },
    { import = "plugins.file-manager" },
    { import = "plugins.fancy" },
    { import = "plugins.diff" },

    { import = "plugins.ai" },

    { import = "plugins.github" },
    -- { import = "plugins.obsidian"},

    { import = "plugins.experimental.react-graph" },
  },
  rocks = {
    enabled = false,
    hererocks = true,
  }, -- recommended if you do not have global installation of Lua 5.1.
  change_detection = {
    enabled = true,
    notify = false,
    reload = true,
  },
})

vim.cmd.colorscheme("catppuccin-nvim")

vim.keymap.set({ "n", "v" }, "gq", function()
  local mode = vim.fn.mode()
  local selection_start, selection_end
  if mode == "v" or mode == "V" or mode == "<C-v>" then
    selection_start, selection_end = vim.fn.getpos("v"), vim.fn.getpos(".")
  else
    selection_start, selection_end = vim.api.nvim_buf_get_mark(0, "<"), vim.fn.getpos("'>")
  end

  selection_start, selection_end = { selection_start[2], selection_start[3] }, { selection_end[2], selection_end[3] }

  print(vim.inspect({ selection_start, selection_end }))
end, {})

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

-- scroll plugin
require("scroll").setup()

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
