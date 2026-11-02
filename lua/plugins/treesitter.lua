-- 语法高亮、折叠、缩进。解析器需要 tree-sitter 命令行和 C 编译器来编译。
-- 都没有时不编译：Neovim 自带的正则语法高亮 + 语言服务的语义高亮，Markdown/Lua/Vim 解析器是内置的
local parsers = {
  "bash", "css", "diff", "dockerfile", "git_config", "gitcommit", "gitignore",
  "go", "gomod", "gosum", "html", "java", "javascript", "jsdoc", "json",
  "lua", "luadoc", "markdown", "markdown_inline", "properties", "python",
  "query", "regex", "sql", "toml", "tsx", "typescript", "vim", "vimdoc",
  "xml", "yaml",
}

-- Windows 上 tree-sitter 用 MSVC 编译；检测不到时不尝试，免得每次启动都报编译失败
local function can_compile()
  if vim.fn.executable("tree-sitter") == 0 then return false end
  if vim.fn.has("win32") == 0 then return true end
  if vim.env.CC or vim.fn.executable("cl") == 1 then return true end
  local program_files = vim.env["ProgramFiles(x86)"]
  return program_files ~= nil
    and vim.uv.fs_stat(program_files .. "/Microsoft Visual Studio/Installer/vswhere.exe") ~= nil
end

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- 本插件不支持延迟加载
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")

    local function missing()
      local installed = {}
      for _, lang in ipairs(ts.get_installed()) do installed[lang] = true end
      return vim.tbl_filter(function(lang) return not installed[lang] end, parsers)
    end

    -- 一次编译全部解析器并等待完成，供安装脚本在无界面模式下调用
    vim.api.nvim_create_user_command("TSInstallAll", function()
      local list = missing()
      if #list > 0 then ts.install(list):wait(30 * 60 * 1000) end
    end, { desc = "编译全部配置的语法解析器" })

    -- 无界面模式由 :TSInstallAll 负责，避免同时编译两次
    if #vim.api.nvim_list_uis() > 0 and can_compile() then
      local list = missing()
      if #list > 0 then ts.install(list) end
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
