-- ╔══════════════════════════════════════════════════════════════╗
-- ║              Mason + LSP + 自动补全 配置                    ║
-- ╚══════════════════════════════════════════════════════════════╝

return {
  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  -- Mason: LSP / DAP / Linter / Formatter 管理器
  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  {
    "williamboman/mason.nvim",
    cmd  = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons  = {
          package_installed   = "✓",
          package_pending     = "➜",
          package_uninstalled = "✗",
        },
        height = 0.8,
      },
    },
  },

  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  -- mason-lspconfig: Mason 与 lspconfig 的桥梁
  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "lua_ls",           -- Lua
        "pyright",          -- Python
        "ts_ls",            -- TypeScript / JavaScript
        "html",             -- HTML
        "cssls",            -- CSS
        "jsonls",           -- JSON
        "yamlls",           -- YAML
        "bashls",           -- Bash
        "clangd",           -- C / C++
        "rust_analyzer",    -- Rust
      },
      automatic_installation = true,
    },
  },

  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  -- nvim-lspconfig: LSP 客户端配置
  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")
      local cmp_lsp = require("cmp_nvim_lsp")

      -- 增强补全能力
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_lsp.default_capabilities()
      )

      -- 诊断图标
      local signs = {
        Error = " ",
        Warn  = " ",
        Hint  = "󰌵 ",
        Info  = " ",
      }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- 诊断全局配置
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          spacing = 4,
        },
        signs          = true,
        underline      = true,
        update_in_insert = false,
        severity_sort  = true,
        float = {
          focusable = false,
          style     = "minimal",
          border    = "rounded",
          source    = true,
          header    = "",
          prefix    = "",
        },
      })

      -- 悬浮窗口圆角边框
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, { border = "rounded" }
      )
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, { border = "rounded" }
      )

      -- ── on_attach: 每个 LSP 连接时绑定快捷键 ──────────────
      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        map("gd",         vim.lsp.buf.definition,      "跳转定义")
        map("gD",         vim.lsp.buf.declaration,      "跳转声明")
        map("gi",         vim.lsp.buf.implementation,   "跳转实现")
        map("gr",         vim.lsp.buf.references,       "查看引用")
        map("K",          vim.lsp.buf.hover,            "悬浮文档")
        map("<leader>ca", vim.lsp.buf.code_action,      "代码操作")
        map("<leader>rn", vim.lsp.buf.rename,           "重命名")
        map("<leader>D",  vim.lsp.buf.type_definition,  "类型定义")
        map("<C-k>",      vim.lsp.buf.signature_help,   "签名帮助")
      end

      -- ── 针对各 LSP 的特殊配置 ─────────────────────────────
      local server_settings = {
        lua_ls = {
          settings = {
            Lua = {
              runtime    = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace  = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry  = { enable = false },
              completion = { callSnippet = "Replace" },
            },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths  = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        jsonls = {
          settings = {
            json = {
              validate = { enable = true },
            },
          },
        },
      }

      -- ── 统一注册所有 Mason 安装的 LSP ─────────────────────
      mason_lspconfig.setup_handlers({
        -- 默认处理
        function(server_name)
          local server_opts = server_settings[server_name] or {}
          server_opts.capabilities = capabilities
          server_opts.on_attach    = on_attach
          lspconfig[server_name].setup(server_opts)
        end,
      })
    end,
  },

  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  -- nvim-cmp: 自动补全引擎
  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",     -- LSP 补全源
      "hrsh7th/cmp-buffer",       -- Buffer 补全源
      "hrsh7th/cmp-path",         -- 路径补全源
      "hrsh7th/cmp-cmdline",      -- 命令行补全
      "saadparwaiz1/cmp_luasnip", -- Snippet 补全源
      "L3MON4D3/LuaSnip",        -- Snippet 引擎
      "rafamadriz/friendly-snippets", -- 预置代码片段
      "onsails/lspkind.nvim",     -- 补全图标
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      -- 加载 friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          { name = "buffer",   priority = 500 },
          { name = "path",     priority = 250 },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode      = "symbol_text",
            maxwidth  = 50,
            ellipsis_char = "...",
            menu = {
              nvim_lsp = "[LSP]",
              luasnip  = "[Snip]",
              buffer   = "[Buf]",
              path     = "[Path]",
            },
          }),
        },
        experimental = {
          ghost_text = true,
        },
      })

      -- 命令行 `/` 搜索补全
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      -- 命令行 `:` 补全
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = "path" } },
          { { name = "cmdline" } }
        ),
      })
    end,
  },
}
