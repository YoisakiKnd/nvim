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

    if vim.fn.executable("tree-sitter") == 1 then
      local installed = {}
      for _, lang in ipairs(ts.get_installed()) do installed[lang] = true end
      local missing = vim.tbl_filter(function(lang) return not installed[lang] end, parsers)
      if #missing > 0 then ts.install(missing) end
    else
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
