@echo off
chcp 65001 >nul 2>&1
REM Neovim / Neovide Launcher (Windows)

set XDG_CONFIG_HOME=%~dp0..
set NVIM_APPNAME=nvim
set ARGS=%*

where neovide >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [*] Found Neovide, launching...
    start "" neovide %ARGS%
    exit /b 0
)

where nvim >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [*] Neovide not found, using Neovim...
    nvim %ARGS%
    exit /b 0
)

echo [!] Error: Neither Neovide nor Neovim found.
echo     Neovim:  https://github.com/neovim/neovim/releases
echo     Neovide: https://neovide.dev
pause
exit /b 1
