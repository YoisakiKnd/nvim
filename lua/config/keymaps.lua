-- 通用按键；插件相关的按键写在各自的插件文件里，按需加载
local map = vim.keymap.set

-- 类似 VS Code
map({ "n", "i", "x", "s" }, "<C-s>", "<cmd>write<cr><esc>", { desc = "保存" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "清除搜索高亮" })

-- 窗口
map("n", "<C-h>", "<C-w>h", { desc = "左侧窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "下方窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "上方窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "右侧窗口" })
map("n", "<leader>|", "<C-w>v", { desc = "左右分屏" })
map("n", "<leader>-", "<C-w>s", { desc = "上下分屏" })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "增加高度" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "减少高度" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "减少宽度" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "增加宽度" })

-- 标签页式缓冲区切换
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "上一个文件" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "下一个文件" })

-- 移动行（同 VS Code 的 Alt+↑/↓）
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "下移行" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "上移行" })
map("i", "<A-j>", "<esc><cmd>move .+1<cr>==gi", { desc = "下移行" })
map("i", "<A-k>", "<esc><cmd>move .-2<cr>==gi", { desc = "上移行" })
map("x", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "下移选中行" })
map("x", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "上移选中行" })

-- 缩进后保持选中
map("x", "<", "<gv")
map("x", ">", ">gv")

-- 诊断
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "下一个诊断" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "上一个诊断" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "当前行诊断" })

-- 开关
map("n", "<leader>uf", function()
  vim.g.autoformat = not vim.g.autoformat
  vim.notify("保存时格式化：" .. (vim.g.autoformat and "开" or "关"))
end, { desc = "切换保存时格式化" })
map("n", "<leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = "切换自动换行" })
map("n", "<leader>uh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "切换类型提示" })

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "退出" })
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "插件管理" })
