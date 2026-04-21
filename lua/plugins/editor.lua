-- ╔══════════════════════════════════════════════════════════════╗
-- ║                    编辑器工具插件                            ║
-- ╚══════════════════════════════════════════════════════════════╝

return {
  -- Telescope 模糊搜索
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",  desc = "全局搜索" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>",    desc = "切换 Buffer" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>",  desc = "帮助文档" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>",   desc = "最近文件" },
      { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "诊断列表" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "文档符号" },
    },
    opts = {
      defaults = {
        prompt_prefix   = "   ",
        selection_caret = "  ",
        entry_prefix    = "  ",
        sorting_strategy  = "ascending",
        layout_strategy   = "horizontal",
        layout_config = {
          horizontal = { prompt_position = "top", preview_width = 0.55 },
          width  = 0.87,
          height = 0.80,
        },
        file_ignore_patterns = {
          "node_modules", ".git/", "dist/", "build/",
          "%.lock", "__pycache__",
        },
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<Esc>"] = "close",
          },
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- Neo-tree 文件浏览器
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>fe", "<cmd>Neotree toggle<CR>", desc = "文件浏览器" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style   = "rounded",
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          hide_dotfiles   = false,
          hide_gitignored = false,
          hide_by_name    = { "node_modules", "__pycache__" },
        },
      },
      window = {
        width = 30,
        mappings = { ["<space>"] = "none" },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded  = "",
        },
        icon = {
          folder_closed = "",
          folder_open   = "",
          folder_empty  = "󰜌",
        },
        git_status = {
          symbols = {
            added     = "✚",
            modified  = "",
            deleted   = "✖",
            renamed   = "󰁕",
            untracked = "",
            ignored   = "",
            unstaged  = "󰄱",
            staged    = "",
            conflict  = "",
          },
        },
      },
    },
  },

  -- Autopairs 自动括号
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({ check_ts = true })
      -- 与 cmp 集成
      local ok, cmp = pcall(require, "cmp")
      if ok then
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },

  -- Comment 快捷注释
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- Todo Comments 高亮 TODO/FIXME
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "查找 TODO" },
    },
  },

  -- Surround 包围操作
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },
}
