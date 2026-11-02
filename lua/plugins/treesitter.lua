-- 语法高亮、折叠、缩进。解析器需要 tree-sitter 命令行和 C 编译器来编译
local parsers = {
  "bash", "css", "diff", "dockerfile", "git_config", "gitcommit", "gitignore",
  "go", "gomod", "gosum", "html", "java", "javascript", "jsdoc", "json",
  "lua", "luadoc", "markdown", "markdown_inline", "properties", "python",
  "query", "regex", "sql", "toml", "tsx", "typescript", "vim", "vimdoc",
  "xml", "yaml",
}

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

    local headless = #vim.api.nvim_list_uis() == 0
    if vim.fn.executable("tree-sitter") == 1 then
      -- 无界面模式由 :TSInstallAll 负责，避免同时编译两次
      local list = headless and {} or missing()
      if #list > 0 then ts.install(list) end
    elseif not headless then
      vim.schedule(function()
        vim.notify("未找到 tree-sitter 命令行，暂时只有内置语言有语法高亮。安装方法见 README", vim.log.levels.WARN)
      end)
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
      callback = function(event)
        -- 没有对应解析器时 start 会失败，保留普通高亮
        if not pcall(vim.treesitter.start, event.buf) then return end
        local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
        if lang and lang ~= "markdown" and lang ~= "yaml" then
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
