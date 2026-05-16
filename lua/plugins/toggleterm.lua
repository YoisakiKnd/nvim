return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = true,
  keys = {
    { "<leader>tt", "<cmd>ToggleTerm<CR>", desc = "打开/关闭浮动终端" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "垂直分屏终端" },
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "水平分屏终端" },
    { "<leader>tr", "<cmd>TermExec cmd='python3 %'<CR>", desc = "运行当前文件" },
  },
  opts = {
    -- 自定义终端外观和行为
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return 0.4
      end
    end,
    open_mapping = [[<c-\>]],
    hide_numbers = false,
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = "float",
    close_on_exit = true,
    float_opts = {
      border = "curved",
      winblend = 0,
      highlights = { border = "Normal", background = "Normal" },
    },
  },
}