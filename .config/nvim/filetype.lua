vim.filetype.add({
  extension = {
    php = function(path, bufnr)
      local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
      if first_line:match("^<%?hh") then
        return "hack"
      end
    end,
  },
})
