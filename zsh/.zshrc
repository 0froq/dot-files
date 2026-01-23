#!/usr/bin/env zsh
# File Name: .zshrc
# Last Modified: 2026-01-23 16:36:16
# Line Count: 298
#
# Main Zsh Configuration

# =============================================================================
# 1. ENVIRONMENT VARIABLES & EXPORTS
# =============================================================================
# Global environment variables and PATH modifications
export EDITOR="nvim"
export VISUAL="nvim"
export NVMDIR="$HOME/.nvm"
export PNPM_HOME="$HOME/Library/pnpm"
# export CORPUS_DIR="$HOME/2/areas/knowledge_management/corpus"
export CORPUS_DIR="$HOME/2_areas/knowledge_management/blog/docs/corpus"
export ZOTERO_BIB_FILE="$HOME/3_resources/research/refs/zotero.bib"
export AIHUB_MIX_API_KEY="sk-19voXIXyGAZWDfRS0b0aAeA9692d4040A6B3Ec10F143B10b"

# PATH modifications (order matters!)
PATH="$HOME/.rvm/bin:$PATH"
PATH="$HOME/.juliaup/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="/opt/homebrew/bin:$PATH"
PATH="/usr/local/lib:$PATH"
# PATH="/Applications/WezTerm.app/Contents/MacOS:$PATH"

# Dynamic PATH (pnpm)
case "$PATH" in
  *"$PNPM_HOME"* ) ;;
  * ) export PATH="$PNPM_HOME:$PATH" ;;
esac

# =============================================================================
# 2. ZIM FRAMEWORK INITIALIZATION
# =============================================================================
# Zim: Fast, modular Zsh configuration framework
ZIM_HOME="${ZDOTDIR:-$HOME}/.zim"

# Download zimfw.zsh bootstrap (if missing)
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  # if command -v curl >/dev/null; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o "${ZIM_HOME}/zimfw.zsh" \
      "https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh"
  else
    mkdir -p "${ZIM_HOME}" && wget -nv -O "${ZIM_HOME}/zimfw.zsh" \
      "https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh"
  fi
fi

# Install missing modules, or when ~/.zimrc changes
if [[ ! "${ZIM_HOME}/init.zsh" -nt "${ZDOTDIR:-$HOME}/.zimrc" ]]; then
  source "${ZIM_HOME}/zimfw.zsh" init -q
fi

# Initialize modules from ~/.zimrc
source "${ZIM_HOME}/init.zsh"

# ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
#   if (( ${+commands[curl]} )); then
#     curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
#         https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
#   else
#     mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
#         https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
#   fi
# fi
# if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
#   source ${ZIM_HOME}/zimfw.zsh init -q
# fi
# source ${ZIM_HOME}/init.zsh


# =============================================================================
# 3. HISTORY CONFIGURATION
# =============================================================================
# History settings: file, size, deduplication
HISTFILE="$HOME/.zsh_history"
HISTSIZE=999
SAVEHIST=1000
setopt SHARE_HISTORY           # Session history shared across terminals
setopt HIST_EXPIRE_DUPS_FIRST  # Expire duplicates first
setopt HIST_IGNORE_DUPS        # Ignore consecutive duplicates
setopt HIST_VERIFY             # Show expanded command before execution
setopt HIST_IGNORE_ALL_DUPS    # Remove older duplicates during addition

# =============================================================================
# 4. ZLE & VI MODE CONFIGURATION
# =============================================================================
# ZLE: Zsh Line Editor - Vi mode + cursor shapes + custom mappings

bindkey -v  # Enable vi mode

# Cursor shape changes
function zle-keymap-select() {
  if [[ ${KEYMAP} == vicmd ]]; then
    echo -ne '\e[1 q'  # Normal mode: block cursor
  else
    echo -ne '\e[5 q'  # Insert mode: beam cursor
  fi
}
zle -N zle-keymap-select

function zle-line-init() {
  zle -K viins
  echo -ne '\e[5 q'
}
zle -N zle-line-init

# Command line editing with nvim
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line  # Normal mode: v → nvim

# Enhanced vi mappings (add your custom mappings here)
bindkey -M vicmd 'H' beginning-of-line
bindkey -M vicmd 'L' end-of-line
bindkey -M vicmd 'j' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up

# Arrow key history substring search (Zim module)
for key in "${terminfo[kcuu1]}" "${terminfo[kcud1]}"; do
  bindkey "${key}" history-substring-search-up
  bindkey "${key}" history-substring-search-down
done
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# `aa` to escape from insert mode
bindkey -M viins 'aa' vi-cmd-mode

# Initial cursor shape
echo -ne '\e[5 q'

# =============================================================================
# 5. COMPLETION & PROMPT
# =============================================================================
# Completion (handled by Zim, but can override here)
zstyle ':completion:*' menu select

# Prompt: Starship
eval "$(starship init zsh)"

# =============================================================================
# 6. TOOLS & PACKAGE MANAGERS INITIALIZATION
# =============================================================================
# Hooks
autoload -Uz add-zsh-hook

# Update terminal title on directory change
chpwd_update_title() {
  print -Pn "\e]2;%~\a"
}
add-zsh-hook chpwd chpwd_update_title

# List directory contents after changing directory
chpwd_ls() {
  print -P "%F{magenta}$(basename $PWD)%f"

  printf '─%.0s' {1..$COLUMNS}
  print

  eza --color=always --icons=always --no-time --no-user --no-permissions
}

add-zsh-hook chpwd chpwd_ls

# Directory jumping
eval "$(zoxide init zsh)"

# Node Version Manager
[ -s "$NVMDIR/nvm.sh" ] && \. "$NVMDIR/nvm.sh"
[ -s "$NVMDIR/bash_completion" ] && \. "$NVMDIR/bash_completion"

# Command correction
eval "$(thefuck --alias)"

# Yazi
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# =============================================================================
# 7. ALIASES & FUNCTIONS
# =============================================================================
git-sub-changes() {
  local submodule=${1:-nvim}
  local old_sha new_sha summary changelog gh_url

  old_sha=$(git ls-tree HEAD~1 "$submodule" 2>/dev/null | awk '{print substr($3,2)}')
  new_sha=$(git rev-parse ":$submodule" 2>/dev/null)

  [[ -z "$old_sha" || -z "$new_sha" ]] && {
    echo "❌ SHA 失败: $(git submodule status "$submodule")"
    return 1
  }
  [[ "$old_sha" == "$new_sha" ]] && { echo "ℹ️ 无变更"; return 0; }

  echo "📊 $submodule: ${old_sha:0:7} → ${new_sha:0:7}"

  # 绕过 git log：用 git status + git show 最新 commit
  summary=$(git submodule summary "$submodule" 2>/dev/null | head -3 | sed 's/^/  /')
  changelog="  $(git show --oneline -1 "$new_sha" 2>/dev/null | head -1 | sed 's/^/  /')"

  gh_url=$(git config --file .gitmodules "submodule.$submodule.url" | head -1 | \
    sed 's|git@github.com:|https://github.com/|g;s|\.git$||')/commit/$new_sha

  cat << EOF

build: update $submodule to ${new_sha:0:7}

$summary$changelog

🔗 $gh_url
EOF

  echo -n "commit? (y/N): "
  read -r reply
  [[ "$reply" =~ ^[Yy] ]] && {
    git commit -m "build: update $submodule to ${new_sha:0:7}" \
      -m "$(git submodule summary "$submodule" 2>/dev/null | head -3)"
  }
}

alias gsc='git-sub-changes'

alias gsc='git-sub-changes'

git-sub-debug() {
  local submodule=${1:-nvim}
  echo "=== 诊断 $submodule ==="
  echo "1. git submodule status:"
  git submodule status "$submodule"
  echo ""
  echo "2. 目录状态:"
  ls -la "$submodule" | head -5
  echo ""
  echo "3. 是否 Git repo?"
  (cd "$submodule" && git rev-parse --git-dir) 2>&1 || echo "❌ 不是 repo"
  echo ""
  echo "4. .gitmodules 配置:"
  git config --file .gitmodules --get-regexp "^submodule\.$submodule"
  echo ""
  echo "5. 外层记录 SHA:"
  git ls-tree HEAD "$submodule" 2>/dev/null
}

alias gsd='git-sub-debug'

# File & directory
alias ls='eza --color=always --long --icons=always --no-time --no-user --no-permissions'
alias cd='z'

# Project shortcuts
alias 1='cd ~/1_projects'
alias 2='cd ~/2_areas'
alias 3='cd ~/3_resources'
alias 4='cd ~/4_nas'
alias .conf='cd ~/.config'
alias .nvim='cd ~/.config/nvim'

# ~/.zshrc
alias vz='nvim ~/.zshrc'
alias .z='source ~/.zshrc'

# ~/.config/nvim
alias vv='cd ~/.config/nvim && nvim'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gaa='git add .'

# Development tools
alias python='/opt/homebrew/bin/python3'
alias nvim12="$HOME/bin/nvim-0.12/bin/nvim"
alias vi='nvim'
alias v='nvim'
# alias shfmt="$HOME/go/bin/shfmt"

# Knowledge management
alias corpus="$CORPUS_DIR/corpus.zsh"

# =============================================================================
# 8. CUSTOM SCRIPTS & LOCAL OVERRIDES
# =============================================================================
# Place machine-specific or experimental configs here
# Example:
# source ~/.zshrc.local  # if exists

# End of ~/.zshrc
