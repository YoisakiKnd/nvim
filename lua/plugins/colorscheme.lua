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
      flavour = "mocha",
      background = {
        light = "latte",
        dark  = "mocha",
      },
      transparent_background = false,
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = {
        enabled    = false,
        shade      = "dark",
        percentage = 0.15,
      },
      color_overrides = {
        mocha = {
          base     = "#222b24",
          mantle   = "#1a211b",
          crust    = "#131814",
          lavender = "#a6e3a1",
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
