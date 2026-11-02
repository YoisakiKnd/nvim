-- AI：CodeCompanion。聊天窗口在右侧，类似 VS Code 的 Copilot Chat
--
-- 服务商按以下顺序选择：
--   1. 环境变量 NVIM_AI_ADAPTER（例如 anthropic、deepseek、openai、gemini、copilot、ollama）
--   2. 第一个设置了 API key 的服务商：ANTHROPIC_API_KEY → DEEPSEEK_API_KEY → OPENAI_API_KEY → GEMINI_API_KEY
--   3. 都没有时用 GitHub Copilot（需要先登录 Copilot）
local function pick_adapter()
  if vim.env.NVIM_AI_ADAPTER and vim.env.NVIM_AI_ADAPTER ~= "" then
    return vim.env.NVIM_AI_ADAPTER
  end
  for _, item in ipairs({
    { "ANTHROPIC_API_KEY", "anthropic" },
    { "DEEPSEEK_API_KEY", "deepseek" },
    { "OPENAI_API_KEY", "openai" },
    { "GEMINI_API_KEY", "gemini" },
  }) do
    local key = vim.env[item[1]]
    if key and key ~= "" then return item[2] end
  end
  return "copilot"
end

return {
  "olimorris/codecompanion.nvim",
  version = "^19.0.0",
  dependencies = {
    { "nvim-lua/plenary.nvim", branch = "master" },
    "nvim-treesitter/nvim-treesitter",
  },
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
  keys = {
    { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", desc = "打开/关闭 AI 聊天", mode = { "n", "x" } },
    { "<leader>an", "<cmd>CodeCompanionChat<cr>", desc = "新建 AI 聊天", mode = { "n", "x" } },
    { "<leader>ad", "<cmd>CodeCompanionChat Add<cr>", desc = "把选中内容发给聊天", mode = "x" },
    { "<leader>ap", "<cmd>CodeCompanionActions<cr>", desc = "AI 操作面板", mode = { "n", "x" } },
    { "<leader>ai", ":CodeCompanion ", desc = "AI 直接改写（输入要求）", mode = { "n", "x" } },
  },
  opts = function()
    local adapter = pick_adapter()
    return {
      interactions = {
        chat = { adapter = adapter },
        inline = { adapter = adapter },
        cmd = { adapter = adapter },
      },
      display = {
        chat = {
          window = { layout = "vertical", position = "right", width = 0.36 },
        },
        action_palette = { provider = "snacks" },
      },
      opts = {
        language = "Chinese",
      },
    }
  end,
}
