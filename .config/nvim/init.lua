-- Space for leader
vim.g.mapleader = " "

-- Absolute (current line only) and relative (all other lines) line numbers
vim.opt.number = true
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
vim.opt.termguicolors = true

-- Line length indicators
vim.opt.colorcolumn = "80,120"

-- Sign column
vim.opt.signcolumn = "yes"

vim.keymap.set("n", "<Leader>sc", "<cmd>luafile $MYVIMRC<CR>", { desc = "Source Config" })
vim.keymap.set("n", "<Leader>tp", "<cmd>tabprev<CR>", { desc = "Previous tab", silent = true })
vim.keymap.set("n", "<Leader>tn", "<cmd>tabnext<CR>", { desc = "Next tab", silent = true })
vim.keymap.set("n", "<Leader>tN", "<cmd>tabnew<CR>", { desc = "New tab", silent = true })

require("config.lazy")
require("config.ftplugin")
