# nvim-config

轻量的 Neovim 配置：VS Code 风格的界面（左侧资源管理器、顶部文件标签、底部状态栏、右侧 AI 聊天、下方终端），用来写 Markdown 博客和 Java / Spring Boot、Python、Go、JavaScript / TypeScript 代码。AI 用 [CodeCompanion](https://github.com/olimorris/codecompanion.nvim)。

约 20 个插件，除配色、启动页和语法高亮外都按需加载：打开文件时才启动语言服务，进入插入模式才加载补全，按下 AI 快捷键才加载 CodeCompanion。

## 需要

- **Neovim 0.12 或更新版本**（CodeCompanion v19 和新版 nvim-treesitter 都要求 0.12）
- git、curl、[ripgrep](https://github.com/BurntSushi/ripgrep)（全局搜索）
- [Nerd Font](https://www.nerdfonts.com/) 字体，例如 Maple Mono NF CN
- 可选：**tree-sitter 命令行 0.26.1+ 和 C 编译器**，用于编译语法解析器，见下面的"语法解析器"
- 可选：[lazygit](https://github.com/jesseduffield/lazygit)（`<leader>gg`）、fd（加快文件查找）

各语言的语言服务由 Mason 自动安装，但需要本机先有对应工具链，没有的会跳过：

| 语言 | 需要 | 自动安装 |
| --- | --- | --- |
| Java / Spring Boot | **JDK 21+**（jdtls 本身要求），Maven 或 Gradle | jdtls（自带 Lombok 支持）、lemminx（pom.xml）、yaml-language-server（application.yml） |
| Python | python3 | basedpyright、ruff（检查 + 格式化） |
| Go | go | gopls、goimports、gofumpt |
| JavaScript / TypeScript / 前端 | node + npm | vtsls、json/html/css 语言服务、prettier |
| Markdown | — | marksman |

### macOS

```sh
brew install neovim git ripgrep fd lazygit tree-sitter-cli
xcode-select --install   # C 编译器，装过 Xcode 命令行工具可跳过
```

### Windows

用安装脚本一步装好（PowerShell 运行）：

```powershell
irm https://raw.githubusercontent.com/YoisakiKnd/nvim/main/install.ps1 -OutFile install.ps1
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

脚本会：
- 用 Scoop 安装 Neovim、git、ripgrep、fd、lazygit、tree-sitter（没有 Scoop 时先询问是否安装）
- 安装缺少的 Node.js、Python、Go、JDK 21；已有 JDK 但低于 21 时只提示，不改 `JAVA_HOME`
- 没有 MSVC 时安装 `mingw-winlibs`（gcc）用来编译语法解析器，不需要 Visual Studio
- 克隆配置到 `%LOCALAPPDATA%\nvim-lite`，装好插件、解析器和语言服务后启动

可以重复运行，已安装的会跳过。参数：`-NoParsers` 不编译解析器（不装 tree-sitter 和 gcc），`-Languages java,python` 只装部分工具链，`-AppName nvim` 直接作为默认配置，`-NoLaunch` 装完不启动。

### 语法解析器（可选）

不编译也能正常使用：Neovim 自带各语言的正则语法高亮，语言服务连上后再叠加语义高亮（类型、字段、参数、注解分别着色，VS Code 也是这种方式）；Markdown、Lua、Vim 的解析器是 Neovim 内置的，博客渲染不受影响。

编译解析器后多出来的：Markdown 代码块里的 Java/Go 等代码着色、按语法结构折叠（否则按缩进）、语言服务启动前的几秒也有精确高亮。

检测到 tree-sitter 命令行和 C 编译器时，启动后会在后台自动编译，也可以手动运行 `:TSInstallAll`。编译器：

- macOS：Xcode 命令行工具（`xcode-select --install`）
- Windows：有 MSVC 就用 MSVC；没有的话**不需要装 Visual Studio**，用 Scoop 的 `mingw-winlibs`（gcc，约 110 MB 压缩包）。配置只在编译解析器时临时设置 `CC=gcc`，不影响 cargo 等其他构建。注意 Scoop 里普通的 `mingw` 包编译部分解析器会失败，要用 `mingw-winlibs`

## 安装

配置目录：macOS / Linux 是 `~/.config/nvim`，Windows 是 `%LOCALAPPDATA%\nvim`。

**不影响现有配置，先试用**：放到另一个目录，用 `NVIM_APPNAME` 启动。插件和数据也会单独存放。

```sh
# macOS / Linux
git clone https://github.com/YoisakiKnd/nvim.git ~/.config/nvim-lite
NVIM_APPNAME=nvim-lite nvim
```

```powershell
# Windows
git clone https://github.com/YoisakiKnd/nvim.git $env:LOCALAPPDATA\nvim-lite
$env:NVIM_APPNAME = "nvim-lite"; nvim
```

第一次启动会自动下载插件、编译语法解析器、安装语言服务，需要一两分钟，右下角会显示进度。装完后重启一次。`:Lazy` 查看插件，`:Mason` 查看语言服务，`:checkhealth` 检查环境。

**确定要用以后**再替换默认配置（先备份）：

```sh
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.config/nvim-lite ~/.config/nvim
```

## AI（CodeCompanion）

把 API key 写进 shell 配置（如 `~/.zshrc`），设置哪个就用哪个：

```sh
export DEEPSEEK_API_KEY=sk-...
# 或 ANTHROPIC_API_KEY / OPENAI_API_KEY / GEMINI_API_KEY
```

同时设置了多个时按 Anthropic → DeepSeek → OpenAI → Gemini 的顺序选第一个；想指定的话设置 `NVIM_AI_ADAPTER=deepseek`（也可以是 `ollama`、`copilot` 等 CodeCompanion 支持的名字）。都没设置时使用 GitHub Copilot，需要先登录 Copilot。聊天窗口里按 `ga` 可以临时切换服务商和模型，按 `?` 查看全部按键。

AI 用中文回复，改 `lua/plugins/ai.lua` 里的 `language`。

## 常用按键

`<leader>` 是空格。按下空格停一下会弹出全部按键提示。

| 按键 | 作用 | 对应 VS Code |
| --- | --- | --- |
| `<leader>e` | 资源管理器 | Ctrl+B |
| `Ctrl+P` / `<leader>ff` | 查找文件 | Ctrl+P |
| `<leader>/` | 全局搜索文本 | Ctrl+Shift+F |
| `<leader>fr` | 最近文件 | |
| `Shift+H` / `Shift+L` | 上一个 / 下一个文件标签 | Ctrl+Tab |
| `<leader>bd` | 关闭当前文件 | Ctrl+W |
| `Ctrl+S` | 保存 | Ctrl+S |
| `Ctrl+/` / `<leader>tt` | 终端 | Ctrl+` |
| `Alt+J` / `Alt+K` | 下移 / 上移行 | Alt+↓ / Alt+↑ |
| `gcc` / 选中后 `gc` | 注释 | Ctrl+/ |
| `gd` / `gr` / `gI` | 跳到定义 / 查找引用 / 跳到实现 | F12 / Shift+F12 |
| `K` | 悬停说明 | 鼠标悬停 |
| `F2` / `<leader>cr` | 重命名 | F2 |
| `<leader>ca` | 代码操作（导入、修复） | Ctrl+. |
| `<leader>cf` | 格式化 | Shift+Alt+F |
| `]d` / `[d` | 下一个 / 上一个问题 | F8 |
| `<leader>xx` | 当前文件的问题列表 | Ctrl+Shift+M |
| `<leader>aa` | 打开 / 关闭 AI 聊天 | Ctrl+Alt+I |
| `<leader>ai` | 让 AI 直接改写（选中代码后用） | Ctrl+I |
| 选中后 `<leader>ad` | 把选中内容发给 AI 聊天 | |
| `<leader>ap` | AI 操作面板（解释代码、写测试等） | |
| `<leader>gg` | Lazygit | |
| `]h` / `[h` | 下一处 / 上一处 Git 改动 | |
| `<leader>gb` | 这一行是谁改的 | |

补全菜单：`Tab` 接受，`Ctrl+Space` 手动呼出，`Ctrl+N` / `Ctrl+P` 选择。

保存时会自动格式化（Markdown 除外，避免改动正文排版），`<leader>uf` 开关。

## 写博客

- Markdown 在普通模式下直接渲染标题、列表、表格、代码块，进入插入模式显示原文；`<leader>mr` 开关渲染。
- `<leader>mi` 把剪贴板里的截图存到文章旁边的 `assets/` 目录并插入图片链接。
- 自动软换行，`j` / `k` 按屏幕上的行移动。
- 保存到不存在的目录时会自动创建目录。

## 文件结构

```
init.lua                 入口
lua/config/options.lua   编辑器选项、诊断显示
lua/config/keymaps.lua   通用按键
lua/config/autocmds.lua  自动命令（缩进、恢复光标位置等）
lua/config/lazy.lua      插件管理器
lua/plugins/ui.lua       配色、文件标签、状态栏、按键提示
lua/plugins/snacks.lua   启动页、资源管理器、搜索、终端、通知
lua/plugins/editor.lua   Git 标记、自动括号
lua/plugins/coding.lua   补全、格式化
lua/plugins/lsp.lua      语言服务
lua/plugins/treesitter.lua 语法高亮
lua/plugins/markdown.lua Markdown 渲染、粘贴图片
lua/plugins/ai.lua       CodeCompanion
after/ftplugin/markdown.lua Markdown 编辑选项
```

首次启动后插件版本记录在 `lazy-lock.json`，建议提交到仓库，换电脑时装到同样的版本。`:Lazy update` 更新，`:Lazy restore` 回到锁定的版本。

旧配置（neo-tree + toggleterm，含 `install.sh`、`start.bat`）保留在提交 `fd82082` 中，需要时用 `git checkout fd82082 -- <文件>` 找回。
