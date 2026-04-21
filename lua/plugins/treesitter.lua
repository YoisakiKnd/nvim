-- ╔══════════════════════════════════════════════════════════════╗
-- ║                   Treesitter 语法高亮                       ║
-- ╚══════════════════════════════════════════════════════════════╝

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd   = { "TSInstall", "TSUpdate", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
      ensure_installed = {
        -- 常用语言
        "lua", "vim", "vimdoc", "query",
        "python", "javascript", "typescript", "tsx",
        "html", "css", "json", "jsonc", "yaml", "toml",
        "bash", "fish", "regex", "markdown", "markdown_inline",
        "c", "cpp", "rust", "go", "java",
        "dockerfile", "gitignore", "git_config",
      },
      auto_install = true,  -- 打开文件时自动安装缺少的 parser
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection    = "<C-space>",
          node_incremental  = "<C-space>",
          scope_incremental = false,
          node_decremental  = "<bs>",
        },
      },
      textobjects = {
        select = {
          enable    = true,
          lookahead = true,
          keymaps   = {
            ["af"] = { query = "@function.outer", desc = "选中函数(外)" },
            ["if"] = { query = "@function.inner", desc = "选中函数(内)" },
            ["ac"] = { query = "@class.outer",    desc = "选中类(外)" },
            ["ic"] = { query = "@class.inner",    desc = "选中类(内)" },
            ["aa"] = { query = "@parameter.outer", desc = "选中参数(外)" },
            ["ia"] = { query = "@parameter.inner", desc = "选中参数(内)" },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = { query = "@function.outer", desc = "下一个函数" },
            ["]c"] = { query = "@class.outer",    desc = "下一个类" },
          },
          goto_previous_start = {
            ["[f"] = { query = "@function.outer", desc = "上一个函数" },
            ["[c"] = { query = "@class.outer",    desc = "上一个类" },
          },
        },
        swap = {
          enable = true,
          swap_next     = { ["<leader>a"] = "@parameter.inner" },
          swap_previous = { ["<leader>A"] = "@parameter.inner" },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
