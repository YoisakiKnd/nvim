-- 语法高亮、折叠、缩进。解析器需要 tree-sitter 命令行和 C 编译器来编译：
--   macOS / Linux：系统自带的 cc
--   Windows：已装 MSVC 就用 MSVC，否则用 Scoop 的 mingw-winlibs（gcc）
-- 都没有时不编译：Neovim 自带的正则语法高亮 + 语言服务的语义高亮，Markdown/Lua/Vim 解析器是内置的
local parsers = {
  "bash", "css", "diff", "dockerfile", "git_config", "gitcommit", "gitignore",
  "go", "gomod", "gosum", "html", "java", "javascript", "jsdoc", "json",
  "lua", "luadoc", "markdown", "markdown_inline", "properties", "python",
  "query", "regex", "sql", "toml", "tsx", "typescript", "vim", "vimdoc",
  "xml", "yaml",
}

local function has_msvc()
  if vim.fn.executable("cl") == 1 then return true end
  local program_files = vim.env["ProgramFiles(x86)"]
  if not program_files then return false end
  local vswhere = program_files .. "/Microsoft Visual Studio/Installer/vswhere.exe"
  if not vim.uv.fs_stat(vswhere) then return false end
  local result = vim.system({
    vswhere, "-latest", "-products", "*",
    "-requires", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "-property", "installationPath",
  }, { text = true }):wait()
  return result.code == 0 and vim.trim(result.stdout or "") ~= ""
end

-- 返回编译时要用的 CC：nil 表示用默认编译器，false 表示没法编译
local function compiler()
  if vim.fn.executable("tree-sitter") == 0 then return false end
  if vim.fn.has("win32") == 0 or vim.env.CC or has_msvc() then return nil end
  if vim.fn.executable("gcc") == 1 then return "gcc" end
  return false
end

-- 编译期间临时设置 CC，结束后撤掉，不影响 nvim 里的终端和 cargo 等其他构建
local function with_compiler(start)
  local cc = compiler()
  if cc == false then return nil end
  if cc then vim.env.CC = cc end
  local task = start()
  if cc then
    task:await(function() vim.env.CC = nil end)
  end
  return task
end

local function missing()
  local installed = {}
  for _, lang in ipairs(require("nvim-treesitter").get_installed()) do installed[lang] = true end
  return vim.tbl_filter(function(lang) return not installed[lang] end, parsers)
end

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- 本插件不支持延迟加载
  build = function()
    -- 插件更新后按新版本要求重编解析器
    with_compiler(function() return require("nvim-treesitter").update() end)
  end,
  config = function()
    local ts = require("nvim-treesitter")

    -- 一次编译全部解析器并等待完成，供安装脚本在无界面模式下调用
    vim.api.nvim_create_user_command("TSInstallAll", function()
      local list = missing()
      if #list == 0 then return end
      local task = with_compiler(function() return ts.install(list) end)
      if task then
        task:wait(30 * 60 * 1000)
      else
        vim.notify("没有找到 tree-sitter 命令行或 C 编译器，见 README", vim.log.levels.WARN)
      end
    end, { desc = "编译全部配置的语法解析器" })

    -- 缺解析器时在后台编译；无界面模式由 :TSInstallAll 负责，避免同时编译两次
    if #vim.api.nvim_list_uis() > 0 then
      local list = missing()
      if #list > 0 then
        with_compiler(function() return ts.install(list) end)
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
      callback = function(event)
        -- 没有对应解析器时 start 会失败，保留正则高亮和缩进折叠
        if not pcall(vim.treesitter.start, event.buf) then return end
        vim.wo[0][0].foldmethod = "expr"
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
        if lang and lang ~= "markdown" and lang ~= "yaml" then
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
