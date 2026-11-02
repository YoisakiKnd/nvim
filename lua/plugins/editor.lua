-- 编辑辅助：Git 行标记、自动括号
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▁" },
        topdelete = { text = "▔" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        map("n", "]h", function() gs.nav_hunk("next") end, "下一处改动")
        map("n", "[h", function() gs.nav_hunk("prev") end, "上一处改动")
        map("n", "<leader>gp", gs.preview_hunk_inline, "预览改动")
        map({ "n", "x" }, "<leader>gr", ":Gitsigns reset_hunk<cr>", "撤销这处改动")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "这一行的提交")
        map("n", "<leader>gd", gs.diffthis, "与暂存区对比")
      end,
    },
  },

  {
    "nvim-mini/mini.pairs",
    event = "InsertEnter",
    opts = {
      modes = { insert = true, command = false, terminal = false },
    },
  },
}
