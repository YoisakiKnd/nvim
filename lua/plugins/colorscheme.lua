-- ╔══════════════════════════════════════════════════════════════╗
-- ║                   Catppuccin 主题配置                       ║
-- ║               主题色: Mocha Green (#a6e3a1)                 ║
-- ╚══════════════════════════════════════════════════════════════╝

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    opts = {
      flavour = "mocha", -- 保持暗色模式，文字是护眼的浅色
      background = {
        light = "latte",
        dark  = "mocha",
      },
      transparent_background = false, -- 必须关掉，否则自定义的背景色会变成完全透明
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = {
        enabled    = false,
        shade      = "dark",
        percentage = 0.15,
      },
      -- 护眼暗绿 (Forest/Matcha) 方案：
      -- 把背景替换为非常有质感的深绿色，搭配 0.65 的透明度会形成深绿色的毛玻璃
      color_overrides = {
        mocha = {
          base     = "#222b24", -- 主背景：深邃的墨绿/森林绿
          mantle   = "#1a211b", -- 侧边栏/浮窗：稍微再深一点
          crust    = "#131814", -- 边缘：最深的绿色
          lavender = "#a6e3a1", -- 强调色：保留你最初喜欢的明亮抹茶绿
        },
      },
      styles = {
        comments     = { "italic" },
        conditionals = { "italic" },
        loops        = {},
        functions    = { "bold" },
        keywords     = { "bold" },
        strings      = {},
        variables    = {},
        numbers      = {},
        booleans     = { "bold" },
        properties   = {},
        types        = { "bold" },
        operators    = {},
      },
      integrations = {
        cmp          = true,
        gitsigns     = true,
        treesitter   = true,
        notify       = true,
        mason        = true,
        native_lsp   = {
          enabled = true,
          virtual_text = {
            errors      = { "italic" },
            hints       = { "italic" },
            warnings    = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors      = { "underline" },
            hints       = { "underline" },
            warnings    = { "underline" },
            information = { "underline" },
          },
          inlay_hints = {
            background = true,
          },
        },
        indent_blankline = {
          enabled = true,
          colored_indent_levels = false,
        },
        telescope    = { enabled = true },
        which_key    = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
