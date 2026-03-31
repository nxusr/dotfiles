vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.shiftwidth = 2
vim.bo.expandtab = true

pcall(dofile, vim.fn.stdpath('config') .. '/local/cpp.lua')
