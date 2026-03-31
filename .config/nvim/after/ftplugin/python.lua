vim.bo.expandtab = true

pcall(dofile, vim.fn.stdpath('config') .. '/local/python.lua')
