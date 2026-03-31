vim.opt.listchars = 'eol:¬,tab:>-,trail:.,extends:>,precedes:<,nbsp:.'

local enabled = false
local function toggle()
  enabled = not enabled
  vim.opt_local.list = enabled
  if enabled then
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = 'inv'
    vim.cmd('syntax match LeadingSpaces /\\(^ *\\)\\@<= / containedin=ALL conceal cchar=.')
  else
    vim.opt_local.conceallevel = 0
    pcall(vim.cmd, 'syntax clear LeadingSpaces')
  end
end

vim.keymap.set('n', '<F2>', toggle)
