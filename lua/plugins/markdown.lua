-- 写博客：在编辑器里直接渲染 Markdown，粘贴截图自动存成图片并插入链接
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "切换渲染", ft = "markdown" },
    },
    opts = {
      file_types = { "markdown", "codecompanion" },
      render_modes = { "n", "c", "t" }, -- 插入模式下显示原文，方便编辑
      heading = { width = "block", left_pad = 0, right_pad = 2 },
      code = { width = "block", left_pad = 1, right_pad = 2, border = "thin" },
      checkbox = { enabled = true },
      completions = { lsp = { enabled = true } },
    },
  },

  {
    "HakonHarnes/img-clip.nvim",
    cmd = "PasteImage",
    keys = {
      { "<leader>mi", "<cmd>PasteImage<cr>", desc = "粘贴剪贴板图片", ft = "markdown" },
    },
    opts = {
      default = {
        -- 图片放在文章旁边的 assets 目录，文件名用时间戳
        dir_path = function() return vim.fn.expand("%:p:h") .. "/assets" end,
        relative_to_current_file = true,
        file_name = "%Y%m%d-%H%M%S",
        prompt_for_file_name = false,
        drag_and_drop = { enabled = false },
      },
    },
  },
}
