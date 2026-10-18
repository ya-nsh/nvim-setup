local group = vim.api.nvim_create_augroup("user_config", { clear = true })

local function au(event, opts)
  opts.group = group
  vim.api.nvim_create_autocmd(event, opts)
end

-- Briefly highlight what you just copied
au("TextYankPost", {
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Reload files that changed on disk (git checkout, codegen, ...), like VS Code
au({ "FocusGained", "TermClose", "TermLeave" }, {
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd.checktime()
    end
  end,
})

-- Reopen files where you left the cursor
au("BufReadPost", {
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "gitcommit" then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close help-style windows with q
au("FileType", {
  pattern = { "help", "qf", "checkhealth", "man", "lspinfo" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true, desc = "Close window" })
  end,
})

-- Keep splits even when the terminal is resized
au("VimResized", { command = "tabdo wincmd =" })
