-- ╔══════════════════════════════════════════════════════════════╗
-- ║                    Neovim Configuration                     ║
-- ║              LazyVim + Mason + Treesitter                   ║
-- ╚══════════════════════════════════════════════════════════════╝

-- 加载核心配置
require("config.options")
require("config.keymaps")

-- 引导并启动 lazy.nvim
require("config.lazy")
