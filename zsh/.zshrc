#!/usr/bin/env zsh
# File Name: .zshrc
# Last Modified: 2026-01-26 23:47:28
# Line Count: 238
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
*"$PNPM_HOME"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# =============================================================================
# 2. ZIM FRAMEWORK INITIALIZATION
# =============================================================================
# Zim: Fast, modular Zsh configuration framework
ZIM_HOME="${ZDOTDIR:-$HOME}/.zim"

# Download zimfw.zsh bootstrap (if missing)
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  # if command -v curl >/dev/null; then
  # if (( ${+commands[curl]} )); then
  if command -v curl >/dev/null 2>&1; then
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

# =============================================================================
# 3. HISTORY CONFIGURATION
# =============================================================================
# History settings: file, size, deduplication
HISTFILE="$HOME/.zsh_history"
HISTSIZE=999
SAVEHIST=1000
setopt SHARE_HISTORY          # Session history shared across terminals
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first
setopt HIST_IGNORE_DUPS       # Ignore consecutive duplicates
setopt HIST_VERIFY            # Show expanded command before execution
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicates during addition

# =============================================================================
# 4. ZLE & KEYBINDINGS CONFIGURATION
# =============================================================================
# ZLE: Zsh Line Editor

bindkey -e

# Command line editing with nvim
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

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
  IFS= read -r -d '' cwd <"$tmp"
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
    echo "❌ SHA failed: $(git submodule status "$submodule")"
    return 1
  }
  [[ "$old_sha" == "$new_sha" ]] && {
    echo "ℹ️ No changes"
    return 0
  }

  echo "📊 $submodule: ${old_sha:0:7} → ${new_sha:0:7}"

  summary=$(git submodule summary "$submodule" 2>/dev/null | head -3 | sed 's/^/  /')
  changelog="  $(git show --oneline -1 "$new_sha" 2>/dev/null | head -1 | sed 's/^/  /')"

  gh_url=$(git config --file .gitmodules "submodule.$submodule.url" | head -1 |
    sed 's|git@github.com:|https://github.com/|g;s|\.git$||')/commit/$new_sha

  cat <<EOF

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

# File & directory
alias ls='eza --color=always --long --icons=always --no-time --no-user --no-permissions'
alias cd='z'

# Semantic anchors
typeset -gA J
J[.]="$HOME/.config"
J[v]="$HOME/.config/nvim"
J[1]="$HOME/1_projects"
J[2]="$HOME/2_areas"
J[3]="$HOME/3_resources"
J[c]="$HOME/2_areas/knowledge_management/blog/docs/corpus"

# o(open, cd)
o() { builtin cd -- "${J[$1]:-$HOME}/${2:-}"; }

# v(nvim)
v() {
  local key=$1
  shift
  o "$key"
  nvim "$@"
}

ov() { o v "$@"; }
vv() { v v "$@"; }
o.() { o . "$@"; }
v.() { v . "$@"; }

# source ~/.zshrc
alias .z='exec zsh'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -v'

# Development tools
alias python='/opt/homebrew/bin/python3'
alias nvim12="$HOME/bin/nvim-0.12/bin/nvim"
alias vi='nvim'

# Knowledge management
alias corpus="$CORPUS_DIR/corpus.zsh"

# =============================================================================
# 8. CUSTOM SCRIPTS & LOCAL OVERRIDES
# =============================================================================
# Place machine-specific or experimental configs here
# Example:
# source ~/.zshrc.local  # if exists

# End of ~/.zshrc
