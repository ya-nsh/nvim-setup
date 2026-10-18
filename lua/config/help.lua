-- The help modal: press ? anywhere to see every shortcut, explained.
-- It shows CHEATSHEET.md, with tables and headings drawn by render-markdown.nvim.
local M = {}

local path = vim.fn.stdpath("config") .. "/CHEATSHEET.md"
local win ---@type snacks.win?

-- Its own filetype, so render-markdown only draws this window and normal
-- markdown files stay plain text
local filetype = "cheatsheet"
vim.treesitter.language.register("markdown", filetype)

--- Move to the next (dir = 1) or previous (dir = -1) "## " section, wrapping around
local function jump_section(dir)
  return function(self)
    local lines = vim.api.nvim_buf_get_lines(self.buf, 0, -1, false)
    local count = #lines
    local current = vim.api.nvim_win_get_cursor(self.win)[1]
    for step = 1, count do
      local line = (current - 1 + dir * step) % count + 1
      if lines[line]:match("^## ") then
        vim.api.nvim_win_set_cursor(self.win, { line, 0 })
        vim.cmd("normal! zt")
        return
      end
    end
  end
end

function M.toggle()
  if win and win:valid() then
    win:close()
    return
  end
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    vim.notify("Can't read " .. path, vim.log.levels.ERROR)
    return
  end
  win = Snacks.win({
    text = lines,
    width = 0.8,
    height = 0.85,
    border = "rounded",
    title = " Help: every shortcut ",
    title_pos = "center",
    footer = " Tab / Shift+Tab  next / previous section    /  search    q, Esc or ?  close ",
    footer_pos = "center",
    bo = { filetype = filetype, modifiable = false, buftype = "nofile", bufhidden = "wipe" },
    wo = {
      wrap = true,
      linebreak = true,
      conceallevel = 2,
      spell = false,
      number = false,
      relativenumber = false,
      signcolumn = "no",
      statuscolumn = "",
      cursorline = true,
    },
    keys = {
      q = "close",
      ["<Esc>"] = "close",
      ["?"] = "close",
      ["<Tab>"] = jump_section(1),
      ["<S-Tab>"] = jump_section(-1),
    },
  })
end

return M
