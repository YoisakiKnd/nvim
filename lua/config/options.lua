-- ╔══════════════════════════════════════════════════════════════╗
-- ║                     Neovim 基础选项                         ║
-- ╚══════════════════════════════════════════════════════════════╝

local opt = vim.opt

-- ── Leader 键 ────────────────────────────────────────────────
vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"

-- ── 界面 ─────────────────────────────────────────────────────
opt.number         = true          -- 行号
opt.relativenumber = true          -- 相对行号
opt.cursorline     = true          -- 高亮当前行
opt.signcolumn     = "yes"         -- 始终显示标记列
opt.termguicolors  = true          -- 真彩色
opt.showmode       = false         -- 状态栏已有模式信息
opt.pumheight      = 10            -- 补全菜单最大高度
opt.cmdheight      = 1
opt.laststatus     = 3             -- 全局状态栏
opt.scrolloff      = 8             -- 光标上下保留行数
opt.sidescrolloff  = 8

-- ── 缩进 ─────────────────────────────────────────────────────
opt.expandtab   = true             -- 用空格替代 Tab
opt.shiftwidth  = 2                -- 自动缩进宽度
opt.tabstop     = 2                -- Tab 显示宽度
opt.softtabstop = 2
opt.smartindent = true

-- ── 搜索 ─────────────────────────────────────────────────────
opt.ignorecase = true              -- 搜索忽略大小写
opt.smartcase  = true              -- 含大写时区分大小写
opt.hlsearch   = true              -- 高亮搜索结果
opt.incsearch  = true              -- 增量搜索

-- ── 文件 ─────────────────────────────────────────────────────
opt.backup      = false
opt.writebackup = false
opt.swapfile    = false
opt.undofile    = true             -- 持久化撤销历史
opt.fileencoding = "utf-8"

-- ── 分屏 ─────────────────────────────────────────────────────
opt.splitbelow = true              -- 水平分屏在下方
opt.splitright = true              -- 垂直分屏在右方

-- ── 杂项 ─────────────────────────────────────────────────────
opt.mouse       = "a"              -- 启用鼠标
opt.clipboard   = "unnamedplus"    -- 系统剪贴板
opt.updatetime  = 250              -- 更快的 CursorHold
opt.timeoutlen  = 300              -- 按键序列超时
opt.completeopt = "menu,menuone,noselect"
opt.wrap        = false            -- 不自动换行
opt.fillchars   = { eob = " " }   -- 隐藏空行波浪号

-- ── Neovide GUI 专属设置 ─────────────────────────────────────
if vim.g.neovide then
  vim.g.neovide_opacity = 0.65 -- 设置不透明度 (0.0 完全透明 - 1.0 完全不透明)
  vim.g.neovide_window_blurred = true -- 启用毛玻璃模糊效果
end
