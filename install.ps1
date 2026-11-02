<#
.SYNOPSIS
    在 Windows 上安装这套 Neovim 配置及其依赖。

.DESCRIPTION
    1. 用 Scoop 安装 Neovim、git、ripgrep、fd、tree-sitter、lazygit
    2. 按需安装语言工具链（Node.js、Python、Go、JDK 21），已有的跳过
    3. 检查 C 编译器（MSVC），缺少时询问是否用 winget 安装 VS Build Tools
    4. 把配置克隆到 %LOCALAPPDATA%\<AppName>，默认 nvim-lite，不影响现有的 %LOCALAPPDATA%\nvim
    5. 在无界面模式下装好插件、语法解析器和语言服务，然后启动 Neovim

    可以重复运行：已安装的跳过，配置目录已存在时只做 git pull。

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\install.ps1

.EXAMPLE
    # 只装 Java 和 Python 工具链，装 VS Build Tools 时不再询问
    powershell -ExecutionPolicy Bypass -File .\install.ps1 -Languages java,python -InstallBuildTools
#>
[CmdletBinding()]
param(
    # 配置目录名，同时也是启动时 NVIM_APPNAME 的值；改成 nvim 会直接作为默认配置
    [string]$AppName = 'nvim-lite',
    # 需要的语言工具链，本机已有的不会重复安装
    [ValidateSet('node', 'python', 'go', 'java')]
    [string[]]$Languages = @('node', 'python', 'go', 'java'),
    # 缺少 C 编译器时直接安装 VS Build Tools，不再询问
    [switch]$InstallBuildTools,
    # 装完不启动 Neovim
    [switch]$NoLaunch,
    [string]$Repo = 'https://github.com/YoisakiKnd/nvim.git'
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Step([string]$Text) { Write-Host "`n==> $Text" -ForegroundColor Cyan }
function Write-Ok([string]$Text) { Write-Host "    $Text" -ForegroundColor Green }
function Write-Note([string]$Text) { Write-Host "    $Text" -ForegroundColor Yellow }

function Test-Command([string]$Name) {
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Confirm-Action([string]$Question) {
    $answer = Read-Host "    $Question [y/N]"
    return $answer -match '^(y|yes)$'
}

# Scoop 和安装程序会改用户 PATH，重新读取让本次会话立即生效
function Update-SessionPath {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user"
    $javaHome = [Environment]::GetEnvironmentVariable('JAVA_HOME', 'User')
    if ($javaHome) { $env:JAVA_HOME = $javaHome }
}

function Get-ScoopRoot {
    if ($env:SCOOP) { return $env:SCOOP }
    return Join-Path $env:USERPROFILE 'scoop'
}

function Test-ScoopApp([string]$App) {
    return Test-Path (Join-Path (Get-ScoopRoot) "apps\$App\current")
}

function Add-ScoopBucket([string]$Bucket) {
    if (-not (Test-Path (Join-Path (Get-ScoopRoot) "buckets\$Bucket"))) {
        scoop bucket add $Bucket
    }
}

function Install-ScoopApp([string]$App, [string]$Command = '') {
    if (Test-ScoopApp $App) {
        Write-Ok "$App 已安装"
        return
    }
    # 用其他方式（官方安装包、winget）装过的也算
    if ($Command -and (Test-Command $Command)) {
        Write-Ok "$App 已安装（$((Get-Command $Command).Source)）"
        return
    }
    scoop install $App
    if (-not (Test-ScoopApp $App)) { throw "Scoop 安装 $App 失败" }
    Update-SessionPath
}

# 运行命令并取得输出，不把 stderr 当成脚本错误（java -version 输出在 stderr）
function Get-CommandOutput([string]$Command) {
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try { return (cmd /c "$Command 2>&1" | Out-String) }
    finally { $ErrorActionPreference = $previous }
}

# 运行一次确认是真程序：Windows 自带的 python 别名只会打开应用商店
function Test-RealCommand([string]$Name) {
    if (-not (Test-Command $Name)) { return $false }
    $null = Get-CommandOutput "$Name --version"
    return $LASTEXITCODE -eq 0
}

function Get-JavaMajor {
    if (-not (Test-Command 'java')) { return 0 }
    $text = Get-CommandOutput 'java -version'
    if ($text -match 'version "1\.(\d+)') { return [int]$Matches[1] }
    if ($text -match 'version "(\d+)') { return [int]$Matches[1] }
    return 0
}

function Test-Msvc {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path $vswhere)) { return $false }
    $path = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    return [bool]$path
}

# ── 1. Scoop 和基础工具 ───────────────────────────────────────
Write-Step '检查 Scoop'
if (-not (Test-Command 'scoop')) {
    Write-Note '没有找到 Scoop（https://scoop.sh）。'
    if (-not (Confirm-Action '现在安装 Scoop 吗？会把当前用户的执行策略设为 RemoteSigned')) {
        throw '需要 Scoop 才能继续'
    }
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
    Update-SessionPath
}
Write-Ok 'Scoop 可用'

Write-Step '安装基础工具'
Install-ScoopApp 'git' 'git'
Add-ScoopBucket 'extras'
$tools = [ordered]@{ 'neovim' = 'nvim'; 'ripgrep' = 'rg'; 'fd' = 'fd'; 'tree-sitter' = 'tree-sitter'; 'lazygit' = 'lazygit' }
foreach ($app in $tools.Keys) {
    Install-ScoopApp $app $tools[$app]
}

# 其他方式装的旧版 nvim 可能排在 PATH 前面
$nvimVersion = Get-CommandOutput 'nvim --version'
if ($nvimVersion -match 'NVIM v(\d+)\.(\d+)') {
    $major = [int]$Matches[1]; $minor = [int]$Matches[2]
    $nvimPath = (Get-Command nvim).Source
    if ($major -eq 0 -and $minor -lt 12) {
        throw "当前命令行用的是 $nvimPath（v$major.$minor），这套配置需要 0.12+。请卸载旧版或调整 PATH 后重新运行"
    }
    Write-Ok "Neovim v$major.$minor（$nvimPath）"
} else {
    throw '无法运行 nvim'
}

# ── 2. 语言工具链 ─────────────────────────────────────────────
Write-Step '检查语言工具链'
foreach ($language in $Languages) {
    switch ($language) {
        'node' {
            if (Test-Command 'npm') { Write-Ok 'Node.js 已安装' } else { Install-ScoopApp 'nodejs-lts' }
        }
        'python' {
            if ((Test-RealCommand 'python') -or (Test-RealCommand 'python3')) { Write-Ok 'Python 已安装' }
            else { Install-ScoopApp 'python' }
        }
        'go' {
            if (Test-Command 'go') { Write-Ok 'Go 已安装' } else { Install-ScoopApp 'go' }
        }
        'java' {
            $javaMajor = Get-JavaMajor
            if ($javaMajor -ge 21) {
                Write-Ok "JDK $javaMajor 已安装"
            } elseif ($javaMajor -gt 0) {
                # 不替换现有 JDK，免得改掉项目依赖的 JAVA_HOME
                Write-Note "当前 Java 是 $javaMajor。Java 语言服务（jdtls）本身需要 JDK 21+ 才能运行，"
                Write-Note '项目仍可用旧版本编译。需要时自行安装：scoop bucket add java; scoop install temurin21-jdk'
            } else {
                Add-ScoopBucket 'java'
                Install-ScoopApp 'temurin21-jdk' # 会设置 JAVA_HOME
            }
        }
    }
}

# ── 3. C 编译器（编译语法解析器用） ───────────────────────────
Write-Step '检查 C 编译器'
if ($env:CC) {
    Write-Ok "使用环境变量 CC=$env:CC"
} elseif (Test-Msvc) {
    Write-Ok '找到 MSVC'
} else {
    Write-Note 'tree-sitter 需要 MSVC 编译语法解析器。没有的话只有 Lua、Markdown、Vim 等内置语言有精确高亮。'
    $install = $InstallBuildTools
    if (-not $install) {
        $install = Confirm-Action '用 winget 安装 Visual Studio 2022 Build Tools（C++ 工具，约 2–6 GB）吗？'
    }
    if ($install) {
        if (-not (Test-Command 'winget')) { throw '没有 winget，请从 Microsoft Store 安装"应用安装程序"后重试' }
        winget install --id Microsoft.VisualStudio.2022.BuildTools --exact --source winget `
            --accept-package-agreements --accept-source-agreements `
            --override '--passive --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended'
        if (Test-Msvc) { Write-Ok 'MSVC 安装完成' } else { Write-Note 'Build Tools 安装似乎没有完成，稍后可在 nvim 里运行 :TSInstallAll 重试' }
    } else {
        Write-Note '已跳过。装好编译器后在 nvim 里运行 :TSInstallAll'
    }
}

# ── 4. 配置文件 ───────────────────────────────────────────────
Write-Step "获取配置（$AppName）"
$target = Join-Path $env:LOCALAPPDATA $AppName
if (Test-Path $target) {
    if (-not (Test-Path (Join-Path $target '.git'))) {
        throw "$target 已存在但不是 git 仓库，为避免覆盖没有做任何改动。换一个 -AppName 或先移走该目录"
    }
    $remote = (git -C $target remote get-url origin).Trim()
    if ($remote -ne $Repo) {
        throw "$target 是另一个仓库（$remote），没有做任何改动。换一个 -AppName 或先移走该目录"
    }
    git -C $target pull --ff-only
    if ($LASTEXITCODE -ne 0) { throw "更新 $target 失败，可能有本地改动" }
    Write-Ok "已更新 $target"
} else {
    git clone $Repo $target
    if ($LASTEXITCODE -ne 0) { throw '克隆配置失败' }
    Write-Ok "已克隆到 $target"
}

# ── 5. 插件、语法解析器、语言服务 ─────────────────────────────
$env:NVIM_APPNAME = $AppName

Write-Step '安装插件'
nvim --headless '+Lazy! sync' +qa
if ($LASTEXITCODE -ne 0) { throw '插件安装失败' }

if (Test-Command 'tree-sitter') {
    Write-Step '编译语法解析器（第一次需要几分钟）'
    nvim --headless '+TSInstallAll' +qa
    if ($LASTEXITCODE -ne 0) { Write-Note '部分解析器编译失败，可在 nvim 里运行 :checkhealth nvim-treesitter 查看原因' }
}

Write-Step '安装语言服务和格式化工具'
nvim --headless '+MasonToolsInstall' +qa
if ($LASTEXITCODE -ne 0) { Write-Note '部分工具安装失败，可在 nvim 里运行 :Mason 查看' }

# ── 完成 ──────────────────────────────────────────────────────
Write-Step '完成'
if ($AppName -eq 'nvim') {
    Write-Host '    启动：nvim'
} else {
    Write-Host "    启动：`$env:NVIM_APPNAME = '$AppName'; nvim"
    Write-Host '    想以后直接输入 nvl 启动，把下面这行加到 $PROFILE：'
    Write-Host "    function nvl { `$env:NVIM_APPNAME = '$AppName'; nvim @args; Remove-Item Env:NVIM_APPNAME }"
}
Write-Host ''
Write-Host '    AI 需要 API key，例如（设置后重开终端）：'
Write-Host "    [Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', 'sk-...', 'User')"
Write-Host '    终端字体请选 Nerd Font（如 Maple Mono NF CN），否则图标显示为方块。'

if (-not $NoLaunch) { nvim }
