-- Space for leader
vim.g.mapleader = " "

-- Relative line numbers
vim.opt.relativenumber = true

-- Default tab spacing (should be overridden per file extension)
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Search casing
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Persistent undo file
vim.opt.undofile = true

-- Cursor column/line
vim.opt.cursorcolumn = true
vim.opt.cursorline = true

-- Line length indicators
vim.opt.colorcolumn = "80,120"

-- Sign column
vim.opt.signcolumn = "yes"

vim.keymap.set("n", "<Leader>sc", ":luafile $MYVIMRC<CR>", { desc = "Source Config" })

require("config.lazy")
require("config.ftplugin")
