-- ╔══════════════════════════════════════════════════════════════╗
-- ║                   lazy.nvim 引导安装                        ║
-- ╚══════════════════════════════════════════════════════════════╝

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "--branch=stable", lazyrepo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

-- ── 启动 lazy.nvim ──────────────────────────────────────────
require("lazy").setup({
  spec = {
    { import = "plugins" }, -- 自动加载 lua/plugins/ 下所有文件
  },
  defaults = { lazy = false },
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = true, notify = false }, -- 自动检查插件更新
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    border = "rounded",
    icons = {
      cmd     = " ",
      config  = " ",
      event   = " ",
      ft      = " ",
      init    = " ",
      keys    = " ",
      plugin  = " ",
      runtime = " ",
      require = "󰢱 ",
      source  = " ",
      start   = " ",
      task    = "✔ ",
      lazy    = "󰒲 ",
    },
  },
})
