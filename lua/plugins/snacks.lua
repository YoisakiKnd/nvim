-- snacks.nvim 一个插件提供：启动页、资源管理器、文件/文本搜索、终端、通知、缩进线、大文件保护
return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 900,
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = " ", key = "f", desc = "查找文件", action = ":lua Snacks.picker.files()" },
          { icon = " ", key = "n", desc = "新建文件", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "搜索文本", action = ":lua Snacks.picker.grep()" },
          { icon = " ", key = "r", desc = "最近文件", action = ":lua Snacks.picker.recent()" },
          { icon = " ", key = "c", desc = "编辑配置", action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })" },
          { icon = "󰒲 ", key = "l", desc = "插件管理", action = ":Lazy" },
          { icon = " ", key = "q", desc = "退出", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    explorer = { enabled = true, replace_netrw = true },
    picker = {
      enabled = true,
      sources = {
        explorer = {
          layout = { layout = { position = "left", width = 32 } },
        },
      },
    },
    input = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    indent = { enabled = true, animate = { enabled = false } },
    scope = { enabled = true },
    words = { enabled = true },
    terminal = { win = { position = "bottom", height = 0.3 } },
    styles = { notification = { wo = { wrap = true } } },
  },
  keys = {
    -- 资源管理器 / 查找（对应 VS Code 的 Ctrl+B、Ctrl+P、Ctrl+Shift+F）
    { "<leader>e", function() Snacks.explorer() end, desc = "资源管理器" },
    { "<C-p>", function() Snacks.picker.files() end, desc = "查找文件" },
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "智能查找文件" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "查找文件" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "最近文件" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "已打开的文件" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "配置文件" },
    { "<leader>fp", function() Snacks.picker.projects() end, desc = "项目" },
    { "<leader>/", function() Snacks.picker.grep() end, desc = "全局搜索文本" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "全局搜索文本" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "搜索光标处单词", mode = { "n", "x" } },
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "搜索当前文件" },
    { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "文件内符号" },
    { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "项目内符号" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "按键列表" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "帮助文档" },
    { "<leader>sr", function() Snacks.picker.resume() end, desc = "恢复上次搜索" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "命令历史" },
    { "<leader>xx", function() Snacks.picker.diagnostics_buffer() end, desc = "当前文件诊断" },
    { "<leader>xX", function() Snacks.picker.diagnostics() end, desc = "项目诊断" },
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "通知历史" },

    -- 文件标签
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "关闭当前标签" },

    -- 终端（对应 VS Code 的 Ctrl+`；终端里一般收不到 Ctrl+`，所以用 Ctrl+/）
    { "<C-/>", function() Snacks.terminal() end, desc = "终端", mode = { "n", "t" } },
    { "<C-_>", function() Snacks.terminal() end, desc = "which_key_ignore", mode = { "n", "t" } },
    { "<leader>tt", function() Snacks.terminal() end, desc = "终端" },

    -- Git
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "提交记录" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "改动的文件" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "在浏览器打开", mode = { "n", "x" } },

    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "下一个同名引用" },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "上一个同名引用" },
  },
}
