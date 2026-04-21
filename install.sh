#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Neovim 配置安装脚本 (macOS / Linux)                   ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

# ── 颜色 ──────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# ── 系统检测 ──────────────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Darwin) PLATFORM="macOS" ;;
    Linux)  PLATFORM="Linux" ;;
    *)      error "不支持的系统: $OS" ;;
esac

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║     Neovim 开发环境安装脚本                 ║${NC}"
echo -e "${CYAN}${BOLD}║     平台: ${PLATFORM} (${ARCH})                      ${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""

# ── 包管理器检测 ──────────────────────────────────────────────
install_pkg() {
    local pkg="$1"
    if [[ "$PLATFORM" == "macOS" ]]; then
        if ! command -v brew &>/dev/null; then
            warn "未找到 Homebrew，正在安装..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install "$pkg"
    elif command -v apt-get &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y "$pkg"
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "$pkg"
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm "$pkg"
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y "$pkg"
    else
        error "未找到支持的包管理器，请手动安装: $pkg"
    fi
}

# ── 依赖检查与安装 ────────────────────────────────────────────
check_and_install() {
    local cmd="$1"
    local pkg="${2:-$1}"
    if command -v "$cmd" &>/dev/null; then
        success "$cmd 已安装 ($(command -v "$cmd"))"
    else
        info "正在安装 $pkg ..."
        install_pkg "$pkg"
        if command -v "$cmd" &>/dev/null; then
            success "$pkg 安装成功"
        else
            error "$pkg 安装失败"
        fi
    fi
}

echo -e "${BOLD}── 检查依赖 ──────────────────────────────────${NC}"

# Git
check_and_install "git" "git"

# Node.js (部分 LSP 需要)
check_and_install "node" "nodejs"
if ! command -v node &>/dev/null; then
    check_and_install "node" "node"
fi

# npm
check_and_install "npm" "npm"

# Neovim
if command -v nvim &>/dev/null; then
    NVIM_VER=$(nvim --version | head -1)
    success "Neovim 已安装 ($NVIM_VER)"
else
    info "正在安装 Neovim ..."
    if [[ "$PLATFORM" == "macOS" ]]; then
        brew install neovim
    elif command -v apt-get &>/dev/null; then
        # Ubuntu/Debian 官方源版本可能较旧，使用 PPA
        sudo add-apt-repository -y ppa:neovim-ppa/unstable 2>/dev/null || true
        sudo apt-get update -qq
        sudo apt-get install -y neovim
    else
        install_pkg "neovim"
    fi
    success "Neovim 安装完成"
fi

# ripgrep (Telescope live_grep 需要)
check_and_install "rg" "ripgrep"

# fd (Telescope find_files 加速)
if command -v fd &>/dev/null || command -v fdfind &>/dev/null; then
    success "fd 已安装"
else
    info "正在安装 fd ..."
    install_pkg "fd-find" 2>/dev/null || install_pkg "fd"
    success "fd 安装完成"
fi

# C 编译器 (Treesitter 编译 parser 需要)
if command -v gcc &>/dev/null || command -v cc &>/dev/null; then
    success "C 编译器已安装"
else
    info "正在安装 C 编译器 ..."
    if [[ "$PLATFORM" == "macOS" ]]; then
        xcode-select --install 2>/dev/null || true
    else
        install_pkg "build-essential" 2>/dev/null || install_pkg "gcc"
    fi
    success "C 编译器安装完成"
fi

# ── Neovide (可选) ────────────────────────────────────────────
echo ""
echo -e "${BOLD}── Neovide (可选) ────────────────────────────${NC}"

if command -v neovide &>/dev/null; then
    success "Neovide 已安装"
else
    read -rp "$(echo -e "${YELLOW}是否安装 Neovide GUI？[y/N]: ${NC}")" INSTALL_NEOVIDE
    if [[ "$INSTALL_NEOVIDE" =~ ^[Yy]$ ]]; then
        info "正在安装 Neovide ..."
        if [[ "$PLATFORM" == "macOS" ]]; then
            brew install --cask neovide
        elif command -v cargo &>/dev/null; then
            cargo install --git https://github.com/neovide/neovide
        else
            warn "需要 Cargo 来编译 Neovide，正在安装 Rust ..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
            cargo install --git https://github.com/neovide/neovide
        fi
        success "Neovide 安装完成"
    else
        info "跳过 Neovide 安装"
    fi
fi

# ── 链接配置 ──────────────────────────────────────────────────
echo ""
echo -e "${BOLD}── 链接配置文件 ──────────────────────────────${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

if [[ -d "$NVIM_CONFIG_DIR" ]] || [[ -L "$NVIM_CONFIG_DIR" ]]; then
    BACKUP_DIR="${NVIM_CONFIG_DIR}.bak.$(date +%Y%m%d%H%M%S)"
    warn "发现已有配置: $NVIM_CONFIG_DIR"
    warn "备份到: $BACKUP_DIR"
    mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
fi

ln -sf "$SCRIPT_DIR" "$NVIM_CONFIG_DIR"
success "配置已链接: $SCRIPT_DIR → $NVIM_CONFIG_DIR"

# ── 首次启动安装插件 ──────────────────────────────────────────
echo ""
echo -e "${BOLD}── 安装插件 ──────────────────────────────────${NC}"

info "首次启动 Neovim 安装插件 (可能需要几分钟) ..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
success "插件安装完成"

# ── 启动脚本 ──────────────────────────────────────────────────
echo ""
echo -e "${BOLD}── 创建启动脚本 ──────────────────────────────${NC}"

START_SCRIPT="$SCRIPT_DIR/start.sh"
cat > "$START_SCRIPT" << 'STARTEOF'
#!/usr/bin/env bash
# Neovim / Neovide 启动脚本
if command -v neovide &>/dev/null; then
    echo "[*] 检测到 Neovide，正在启动..."
    neovide "$@" &
    disown
else
    echo "[*] 使用 Neovim 启动..."
    nvim "$@"
fi
STARTEOF
chmod +x "$START_SCRIPT"
success "启动脚本已创建: $START_SCRIPT"

# ── 完成 ──────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║          ✓ 安装完成！                       ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  启动方式:"
echo -e "    ${CYAN}nvim${NC}              直接启动 Neovim"
echo -e "    ${CYAN}./start.sh${NC}        自动选择 Neovide / Neovim"
echo -e ""
echo -e "  首次启动时 Mason 会自动安装 LSP 服务器，请耐心等待。"
echo -e "  使用 ${CYAN}:Mason${NC} 查看安装进度，${CYAN}:Lazy${NC} 管理插件。"
echo ""
