-- 外观：VS Code 配色、顶部文件标签、底部状态栏、按键提示
return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("vscode").setup({
        italic_comments = true,
        disable_nvimtree_bg = true,
      })
      vim.cmd.colorscheme("vscode")
    end,
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "固定标签" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "关闭其他标签" },
      { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "关闭右侧标签" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "关闭左侧标签" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "上一个标签" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "下一个标签" },
    },
    opts = {
      options = {
        close_command = function(n) Snacks.bufdelete(n) end,
        right_mouse_command = function(n) Snacks.bufdelete(n) end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        separator_style = "thin",
        offsets = {
          { filetype = "snacks_layout_box", text = "资源管理器", highlight = "Directory", text_align = "left" },
          { filetype = "codecompanion", text = "AI", highlight = "Directory", text_align = "left" },
        },
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    init = function()
      -- 加载前先留出空白状态栏，避免启动时闪一下
      vim.o.statusline = " "
    end,
    opts = {
      options = {
        theme = "vscode",
        globalstatus = true,
        component_separators = "",
        section_separators = "",
        disabled_filetypes = { statusline = { "snacks_dashboard" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1 }, "diagnostics" },
        lualine_x = {
          {
            function()
              local names = {}
              for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                names[#names + 1] = client.name
              end
              return table.concat(names, " ")
            end,
            icon = " ",
          },
          "encoding",
          "fileformat",
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      extensions = { "lazy", "man", "quickfix" },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300,
      spec = {
        { "<leader>a", group = "AI", mode = { "n", "x" } },
        { "<leader>b", group = "标签" },
        { "<leader>c", group = "代码" },
        { "<leader>f", group = "查找" },
        { "<leader>g", group = "Git" },
        { "<leader>m", group = "Markdown" },
        { "<leader>q", group = "退出" },
        { "<leader>s", group = "搜索" },
        { "<leader>t", group = "终端" },
        { "<leader>u", group = "开关" },
        { "<leader>x", group = "诊断" },
        { "[", group = "上一个" },
        { "]", group = "下一个" },
        { "g", group = "跳转" },
      },
    },
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "当前文件的按键" },
    },
  },
}
