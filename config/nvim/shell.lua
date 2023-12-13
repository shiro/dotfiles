-- wrap lines if the exceed the width
vim.opt.wrap           = true

vim.opt.number         = true
vim.opt.relativenumber = true

-- use histogram as the diff algo
-- vim.opt.diffopt:append({ "algorithm:histogram" })
vim.opt.diffopt:append({ "algorithm:patience" })

-- don't force nowrap for diffs
vim.opt.diffopt:append({ "followwrap" })

-- disable status line
vim.opt.laststatus = 3

-- jump to next split
vim.keymap.set("n", "<M-i>", "<CMD>wincmd w<CR>", { noremap = true, silent = true })





-- vim.api.nvim_create_augroup("default", { clear = true })
