command -v direnv >/dev/null && direnv hook fish | source
command -v thefuck >/dev/null && thefuck --alias | source
export PATH="$PATH:$HOME/.local/bin"
