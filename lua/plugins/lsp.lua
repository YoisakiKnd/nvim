-- 语言服务：mason 负责安装，nvim-lspconfig 提供各服务器的默认配置，Neovim 自带的 vim.lsp 负责启动

-- mason 包名，以及安装它需要的外部命令（满足其一即可）。缺少时跳过，不报安装失败
local tools = {
  { "lua-language-server" },
  { "stylua" },
  { "marksman" }, -- Markdown：标题跳转、链接补全
  { "lemminx" }, -- XML：pom.xml
  { "jdtls", needs = { "java" } }, -- Java / Spring Boot，需要 JDK 21+
  { "basedpyright", needs = { "python3", "python" }, probe = true },
  { "ruff", needs = { "python3", "python" }, probe = true },
  { "gopls", needs = { "go" } },
  { "goimports", needs = { "go" } },
  { "gofumpt", needs = { "go" } },
  { "vtsls", needs = { "npm" } }, -- JavaScript / TypeScript
  { "json-lsp", needs = { "npm" } },
  { "yaml-language-server", needs = { "npm" } }, -- application.yml 等
  { "html-lsp", needs = { "npm" } },
  { "css-lsp", needs = { "npm" } },
  { "prettier", needs = { "npm" } },
}

local function installable(tool)
  if not tool.needs then return true end
  for _, cmd in ipairs(tool.needs) do
    if vim.fn.executable(cmd) == 1 then
      -- Windows 自带的 python/python3 别名只会打开应用商店，要实际运行一次确认
      if not tool.probe or vim.system({ cmd, "--version" }):wait().code == 0 then return true end
    end
  end
  return false
end

-- 本机可以安装、但还没装的 mason 包
local function missing_tools()
  local registry = require("mason-registry")
  local names = {}
  for _, tool in ipairs(tools) do
    local ok, pkg = pcall(registry.get_package, tool[1])
    if ok and not pkg:is_installed() and not pkg:is_installing() and installable(tool) then
      names[#names + 1] = tool[1]
    end
  end
  return names
end

local function ensure_tools()
  require("mason-registry").refresh(function()
    for _, name in ipairs(missing_tools()) do
      vim.notify("mason：正在安装 " .. name)
      require("mason-registry").get_package(name):install()
    end
  end)
end

-- 各语言服务器在默认配置之上的设置
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
        diagnostics = { globals = { "vim", "Snacks" } },
        completion = { callSnippet = "Replace" },
        hint = { enable = true },
      },
    },
  },
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
        usePlaceholders = true,
        staticcheck = true,
        hints = { parameterNames = true, assignVariableTypes = true, compositeLiteralFields = true },
      },
    },
  },
  basedpyright = {
    settings = { basedpyright = { analysis = { typeCheckingMode = "standard" } } },
  },
  vtsls = {
    settings = {
      typescript = { inlayHints = { parameterNames = { enabled = "literals" } } },
    },
  },
}

local function on_attach(event)
  local buf = event.buf
  local function map(lhs, rhs, desc, mode)
    vim.keymap.set(mode or "n", lhs, rhs, { buffer = buf, desc = desc, nowait = true })
  end
  map("gd", function() Snacks.picker.lsp_definitions() end, "跳到定义")
  map("gD", vim.lsp.buf.declaration, "跳到声明")
  map("gr", function() Snacks.picker.lsp_references() end, "查找引用")
  map("gI", function() Snacks.picker.lsp_implementations() end, "跳到实现")
  map("gy", function() Snacks.picker.lsp_type_definitions() end, "跳到类型定义")
  map("K", function() vim.lsp.buf.hover() end, "悬停说明")
  map("<F2>", vim.lsp.buf.rename, "重命名")
  map("<leader>cr", vim.lsp.buf.rename, "重命名")
  map("<leader>ca", vim.lsp.buf.code_action, "代码操作", { "n", "x" })
  map("<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "语言服务状态")
end

return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason 工具管理" } },
    opts = { ui = { border = "rounded" } },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      -- 一次装好全部语言服务；无界面模式（安装脚本）下会等到装完
      vim.api.nvim_create_user_command("MasonToolsInstall", function()
        require("mason-registry").refresh()
        local names = missing_tools()
        if #names == 0 then
          print("语言服务都已安装")
          return
        end
        vim.cmd("MasonInstall " .. table.concat(names, " "))
      end, { desc = "安装本机可用的全部语言服务和格式化工具" })
    end,
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      -- Spring Boot 项目常用 Lombok：mason 的 jdtls 自带 lombok.jar
      local lombok = vim.fn.stdpath("data") .. "/mason/packages/jdtls/lombok.jar"
      if vim.uv.fs_stat(lombok) and not vim.env.JDTLS_JVM_ARGS then
        vim.env.JDTLS_JVM_ARGS = "-javaagent:" .. lombok
      end

      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
      for name, config in pairs(servers) do
        vim.lsp.config(name, config)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = on_attach,
      })

      -- 已安装的服务器自动启用（包括之后通过 mason 新装的）
      require("mason-lspconfig").setup({ automatic_enable = true })
      ensure_tools()
    end,
  },
}
