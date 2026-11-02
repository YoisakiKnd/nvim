vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 保存时自动格式化，<leader>uf 切换
vim.g.autoformat = true

local opt = vim.opt

opt.number = true
opt.relativenumber = false
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.mouse = "a"
opt.showmode = false -- 状态栏已显示模式
opt.laststatus = 3 -- 全局状态栏，类似 VS Code 底栏
opt.cmdheight = 1
opt.winborder = "rounded"
opt.pumheight = 12
opt.scrolloff = 6
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldclose = "", foldsep = " " }
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.wrap = false
opt.linebreak = true
opt.breakindent = true

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftround = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.grepprg = "rg --vimgrep --smart-case"
opt.grepformat = "%f:%l:%c:%m"

opt.undofile = true
opt.swapfile = false
opt.confirm = true
opt.updatetime = 200
opt.timeoutlen = 400
opt.virtualedit = "block"
opt.completeopt = "menu,menuone,noselect"
opt.shortmess:append({ W = true, I = true, c = true, C = true })

-- 默认按缩进折叠；有 Tree-sitter 解析器的文件改为按语法结构（见 plugins/treesitter.lua）
-- 打开文件时全部展开
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmethod = "indent"
opt.foldtext = ""

-- 系统剪贴板放到启动之后再接入，避免拖慢启动（SSH 下走 OSC 52）
vim.schedule(function()
  opt.clipboard = "unnamedplus"
end)

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = { spacing = 2, source = "if_many", prefix = "●" },
  float = { source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
})
