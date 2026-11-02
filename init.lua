-- 入口：选项 → 插件 → 按键 → 自动命令
if vim.fn.has("nvim-0.12") == 0 then
  vim.api.nvim_echo({ { "此配置需要 Neovim 0.12 或更新版本", "ErrorMsg" } }, true, {})
  return
end

vim.loader.enable()

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
