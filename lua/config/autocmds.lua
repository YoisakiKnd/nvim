local group = vim.api.nvim_create_augroup("user_config", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
  group = group,
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- 重新打开文件时回到上次的位置
autocmd("BufReadPost", {
  group = group,
  callback = function(event)
    local buf = event.buf
    if vim.bo[buf].filetype == "gitcommit" or vim.b[buf].restored_cursor then return end
    vim.b[buf].restored_cursor = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- 窗口大小变化时均分分屏
autocmd("VimResized", {
  group = group,
  callback = function() vim.cmd("tabdo wincmd =") end,
})

-- 辅助窗口按 q 关闭
autocmd("FileType", {
  group = group,
  pattern = { "help", "qf", "checkhealth", "lspinfo", "notify", "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- 前端、配置类文件用 2 空格缩进；Go 用 Tab
autocmd("FileType", {
  group = group,
  pattern = {
    "lua", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue",
    "json", "jsonc", "yaml", "html", "css", "scss",
  },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
  end,
})
autocmd("FileType", {
  group = group,
  pattern = "go",
  callback = function()
    vim.bo.expandtab = false
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 0
  end,
})

-- 保存时自动创建不存在的目录（写博客新建文章时常用）
autocmd("BufWritePre", {
  group = group,
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
