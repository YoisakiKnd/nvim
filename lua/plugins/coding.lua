-- 补全（blink.cmp）和格式化（conform.nvim）
return {
  {
    "saghen/blink.cmp",
    version = "1.*", -- 使用预编译的模糊匹配库，不需要 Rust
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      -- Tab 接受补全（同 VS Code），Ctrl+Space 手动呼出，Ctrl+N/P 或 ↑/↓ 选择
      keymap = { preset = "super-tab" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 300 },
        menu = { draw = { treesitter = { "lsp" } } },
      },
      signature = { enabled = true },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      cmdline = { keymap = { preset = "inherit" }, completion = { menu = { auto_show = true } } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true }) end,
        mode = { "n", "x" },
        desc = "格式化",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_organize_imports", "ruff_format" },
        go = { "goimports", "gofumpt" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        -- Java 没有列出时使用 jdtls 自带的格式化
      },
      default_format_opts = { lsp_format = "fallback" },
      format_on_save = function(buf)
        -- Markdown 只在手动 <leader>cf 时格式化，避免改动博客正文的排版
        if not vim.g.autoformat or vim.bo[buf].filetype == "markdown" then return end
        return { timeout_ms = 1500 }
      end,
    },
  },
}
