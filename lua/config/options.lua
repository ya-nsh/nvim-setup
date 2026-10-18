local opt = vim.opt

-- Look and feel
opt.number = true
opt.relativenumber = true -- makes counts like 5j easy to read; toggle with <leader>ul
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.showmode = false -- lualine already shows the mode
opt.laststatus = 3 -- one statusline for the whole window, like VS Code
opt.winborder = "rounded"
opt.fillchars = { eob = " " }
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.smoothscroll = true
opt.pumheight = 12

-- Folding with treesitter, everything open by default
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.foldlevel = 99
opt.foldlevelstart = 99

-- Editing
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split" -- live preview for :%s/foo/bar
opt.undofile = true -- undo history survives restarts
opt.confirm = true -- ask to save instead of failing on :q
opt.autoread = true
opt.updatetime = 200 -- faster hover highlights and inline blame
opt.timeoutlen = 400
opt.ttimeoutlen = 10 -- Esc and Alt keys register instantly
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.virtualedit = "block"

-- VS Code habits
opt.mouse = "a"
opt.mousemoveevent = true -- hover close buttons on tabs
opt.keymodel = "startsel,stopsel" -- Shift+arrows start a selection, plain arrows end it
opt.whichwrap:append("<,>,[,]") -- left/right arrows wrap onto the previous/next line
opt.jumpoptions = { "stack", "view", "clean" } -- back/forward work like a browser and keep the scroll position

-- Share the macOS clipboard (y copies, p pastes). Deferred because it slows startup.
vim.schedule(function()
  opt.clipboard = "unnamedplus"
end)
