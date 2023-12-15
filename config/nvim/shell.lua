-- wrap lines if the exceed the width
vim.opt.wrap           = true

-- enable line numbers
vim.opt.number         = true
vim.opt.relativenumber = true

-- draw command bar over status bar when used
vim.opt.cmdheight      = 0

-- use histogram as the diff algo
-- vim.opt.diffopt:append({ "algorithm:histogram" })
vim.opt.diffopt:append({ "algorithm:patience" })

-- don't force nowrap for diffs
vim.opt.diffopt:append({ "followwrap" })

-- disable status line
vim.opt.laststatus = 3

-- don't show diff fill chars
vim.opt.fillchars = { diff = " " }

-- jump to next split
vim.keymap.set("n", "<M-i>", "<CMD>wincmd w<CR>", { noremap = true, silent = true })

-- show message history
vim.keymap.set("n", "<leader>m", ":messages<cr>", { silent = true })

-- arrow key window navigation
vim.keymap.set("n", "<up>", "<CMD>wincmd k<CR>", { silent = true })
vim.keymap.set("n", "<down>", "<CMD>wincmd j<CR>", { silent = true })
vim.keymap.set("n", "<left>", "<CMD>wincmd h<CR>", { silent = true })
vim.keymap.set("n", "<right>", "<CMD>wincmd l<CR>", { silent = true })

-- M-i window switch
vim.keymap.set("n", "<M-i>", "<CMD>wincmd w<CR>", { silent = true })

-- auto indent on insert if line is empty
vim.keymap.set("n", "i", function()
    return string.match(vim.api.nvim_get_current_line(), "%g") == nil
        and "cc" or "i"
end, { expr = true, noremap = true })

-- save/restore undo history to a temporary file
local data_dir = os.getenv("XDG_DATA_HOME")
if data_dir ~= nil then
    local undo_dir = data_dir .. "/nvim/undo"
    if vim.fn.isdirectory(undo_dir) == 0 then
        os.execute("mkdir -p \"" .. undo_dir .. "\"")
    end
    vim.opt.undodir  = undo_dir
    vim.opt.undofile = true
end
