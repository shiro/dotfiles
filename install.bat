@echo off

net session >nul 2>&1
if NOT %errorLevel% == 0 (
    echo "error: administrator permissions are required"
    exit 1
)

set home=%userprofile%
set dotfiles=%~dp0

echo "Installing dotfiles."

mkdir %home%\.config 2>&1

mklink /D %home%\.config\mintty %dotfiles%\config\mintty
mklink /D %home%\.config\nvim %dotfiles%\config\nvim

mklink %home%\.ideavimrc %dotfiles%\idea\ideavimrc.ln

echo "Done. Reload your terminal."
