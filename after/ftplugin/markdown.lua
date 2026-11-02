-- 博客正文：软换行、按显示行移动、中文不做拼写检查
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.spell = false
vim.opt_local.conceallevel = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2

local map = function(lhs, rhs) vim.keymap.set({ "n", "x" }, lhs, rhs, { buffer = true, expr = true }) end
map("j", "v:count == 0 ? 'gj' : 'j'")
map("k", "v:count == 0 ? 'gk' : 'k'")
