-- ╔══════════════════════════════════════════════════════════════╗
-- ║                       快捷键映射                            ║
-- ╚══════════════════════════════════════════════════════════════╝

local map = vim.keymap.set

-- ── 通用 ─────────────────────────────────────────────────────
map("n", "<Esc>", "<cmd>nohlsearch<CR>",        { desc = "清除搜索高亮" })
map("n", "<leader>w", "<cmd>w<CR>",              { desc = "保存文件" })
map("n", "<leader>q", "<cmd>q<CR>",              { desc = "退出" })
map("n", "<leader>Q", "<cmd>qa!<CR>",            { desc = "强制退出全部" })

-- ── 窗口导航 ─────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h",                      { desc = "← 左窗口" })
map("n", "<C-j>", "<C-w>j",                      { desc = "↓ 下窗口" })
map("n", "<C-k>", "<C-w>k",                      { desc = "↑ 上窗口" })
map("n", "<C-l>", "<C-w>l",                      { desc = "→ 右窗口" })

-- ── 窗口大小调整 ─────────────────────────────────────────────
map("n", "<C-Up>",    "<cmd>resize +2<CR>",       { desc = "增加窗口高度" })
map("n", "<C-Down>",  "<cmd>resize -2<CR>",       { desc = "减少窗口高度" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<CR>", { desc = "减少窗口宽度" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "增加窗口宽度" })

-- ── Buffer 导航 ──────────────────────────────────────────────
map("n", "<S-h>", "<cmd>bprevious<CR>",           { desc = "上一个 Buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>",               { desc = "下一个 Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>",        { desc = "关闭 Buffer" })

-- ── 行移动 ───────────────────────────────────────────────────
map("v", "J", ":m '>+1<CR>gv=gv",                { desc = "下移选中行" })
map("v", "K", ":m '<-2<CR>gv=gv",                { desc = "上移选中行" })

-- ── 缩进后保持选中 ───────────────────────────────────────────
map("v", "<", "<gv",                              { desc = "左缩进" })
map("v", ">", ">gv",                              { desc = "右缩进" })

-- ── 粘贴不覆盖寄存器 ─────────────────────────────────────────
map("x", "<leader>p", [["_dP]],                   { desc = "粘贴(不覆盖)" })

-- ── LSP 快捷键 (在 lsp.lua on_attach 中也有定义) ─────────────
map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, { desc = "格式化" })
map("n", "<leader>li", "<cmd>LspInfo<CR>",        { desc = "LSP 信息" })
map("n", "<leader>lm", "<cmd>Mason<CR>",          { desc = "Mason 面板" })

-- ── 诊断 ─────────────────────────────────────────────────────
map("n", "[d", vim.diagnostic.goto_prev,           { desc = "上一个诊断" })
map("n", "]d", vim.diagnostic.goto_next,           { desc = "下一个诊断" })
map("n", "<leader>e", vim.diagnostic.open_float,   { desc = "浮窗显示诊断" })
