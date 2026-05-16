-- ╔══════════════════════════════════════════════════════════════╗
-- ║                      UI 增强插件                            ║
-- ╚══════════════════════════════════════════════════════════════╝

return {
  -- Lualine 状态栏
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators   = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Bufferline 标签页
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
    config = function()
      local highlights = {}
      local ok, catppuccin_bl = pcall(require, "catppuccin.groups.integrations.bufferline")
      if ok then
        highlights = catppuccin_bl.get()
      end
      require("bufferline").setup({
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          offsets = {
            { filetype = "neo-tree", text = " 文件浏览器", separator = true },
          },
          separator_style = "slant",
          always_show_bufferline = true,
        },
        highlights = highlights,
      })
    end,
  },

  -- Indent Blankline 缩进线
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope  = { show_start = false, show_end = false },
    },
  },

  -- Which-key 快捷键提示
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>f", group = "查找/文件" },
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "LSP" },
        { "<leader>q", group = "退出/会话" },
        { "<leader>t", group = "TODO" },
        { "<leader>w", group = "保存" },
      },
    },
  },

  -- Gitsigns Git 标记
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add    = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
      },
      current_line_blame = true,
    },
  },

  -- 文件图标
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Noice 美化通知
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      cmdline = {
        enabled = false, -- 禁用 Noice 的命令行
      },
      messages = {
        enabled = false, -- 禁用 Noice 的消息拦截，否则它会把 cmdheight 强制设为 0
      },
      popupmenu = {
        enabled = false, -- 禁用 Noice 的弹窗菜单，使用原生的 cmp-cmdline
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"]                = true,
          ["cmp.entry.get_documentation"]                  = true,
        },
      },
      presets = {
        bottom_search         = false,
        command_palette       = false,
        long_message_to_split = true,
        lsp_doc_border        = true,
      },
    },
    init = function()
      -- 强制恢复原生的命令行高度，确保底部留有输入空间
      vim.opt.cmdheight = 1
    end,
  },
}
