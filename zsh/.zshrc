#!/usr/bin/env zsh
# File Name: .zshrc
# Last Modified: 2026-04-22 23:21:27
# Line Count: 317
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
export CORPUS_DIR="$HOME/2_areas/knowledge_management/blog/docs/corpus"
export ZOTERO_BIB_FILE="$HOME/3_resources/research/refs/zotero.bib"
export AIHUB_MIX_API_KEY="sk-19voXIXyGAZWDfRS0b0aAeA9692d4040A6B3Ec10F143B10b"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export EZA_CONFIG_DIR="$HOME/.config/eza"
export OPENCODE_SERVER_PASSWORD="oQ939393"
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# LS_COLORS for eza (if needed, but eza has its own config)
export LS_COLORS=""
export LS_COLORS="di=1;97:fi=37:ln=37:*=37\
"

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --preview "bat --color=always --style=plain {}" --preview-window "~3"
  --preview-window "right,60%,border-left,+{2}+3/3,~3"
  --color=fg:-1,fg+:#fff9f5,bg:-1,bg+:#272727
  --color=hl:#60b89a,hl+:#9adcc0,info:#6f6d6c,marker:#6fa8f0
  --color=prompt:#fff9f5,spinner:#b7b3b0,pointer:#fff9f5,header:#fff9f5
  --color=border:#272727,preview-label:#68f4df,label:#826363,query:#fff9f5
  --border="sharp" --border-label=""
  --marker="*" --pointer="▌" --separator="─" --scrollbar="│"
  --layout="reverse" --info="right"
  --height=40%
  '

export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target,.sisyphus
  --preview 'tree -C {}'
  "

# PATH modifications (order matters!)
PATH="$HOME/bin:$PATH"
PATH="$HOME/.cargo/bin:$PATH"
PATH="$HOME/.rvm/bin:$PATH"
PATH="$HOME/.juliaup/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
# PATH="/opt/homebrew/bin:$PATH"
PATH="/usr/local/lib:$PATH"
PATH="/usr/local/bin:$PATH"

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
# Keymap indicators for Vi mode
function zle-keymap-select {
  case $KEYMAP in
    vicmd)
      echo -ne '\e[1 q'
      ;;
    viins|main)
      echo -ne '\e[5 q'
      ;;
  esac
}

function zle-line-init {
  echo -ne '\e[5 q'
}

zle -N zle-keymap-select
zle -N zle-line-init

# ZLE: Zsh Line Editor
bindkey -e

# Command line editing with nvim
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

bindkey '^U' undefined-key
bindkey -r '^U'

# =============================================================================
# 5. COMPLETION & PROMPT
# =============================================================================
# Completion (handled by Zim, but can override here)
zstyle ':completion:*' menu select

# bun completions
[ -s "/Users/oQ/.bun/_bun" ] && source "/Users/oQ/.bun/_bun"

# Prompt: Starship
eval "$(starship init zsh)"

# FZF: Fuzzy finder (if installed)
source <(fzf --zsh)

# Custom fzf-based file search with preview
w() {
  #!/usr/bin/env bash

  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  INITIAL_QUERY="${*:-}"
  fzf --ansi --disabled --query "$INITIAL_QUERY" \
    --bind "start:reload:$RG_PREFIX {q} || true" \
    --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --delimiter : \
    --preview 'bat --color=always --style=plain {1} --highlight-line {2}' \
    --bind 'enter:become(nvim {1} +{2})'
}

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
  eza --color=always --no-time --no-user
}

add-zsh-hook chpwd chpwd_ls

# Directory jumping
eval "$(zoxide init zsh)"

# Node Version Manager
[ -s "$NVMDIR/nvm.sh" ] && \. "$NVMDIR/nvm.sh"
[ -s "$NVMDIR/bash_completion" ] && \. "$NVMDIR/bash_completion"

# Command correction
eval "$(thefuck --alias)"

# Boot up x-cmd
[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X"

# Yazi
# function y() {
#   local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
#   command yazi "$@" --cwd-file="$tmp"
#   IFS= read -r -d '' cwd <"$tmp"
#   [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
#   rm -f -- "$tmp"
# }

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
alias ls='eza \
-l \
--hyperlink \
--color=always \
--no-time \
--no-user \
'

alias oc="opencode"
alias nvim='~/bin/nvim-0.11.7/bin/nvim'

# Semantic anchors
typeset -gA J
J[.]="$HOME/.config"
J[v]="$HOME/.config/nvim"
J[1]="$HOME/1_projects"
J[2]="$HOME/2_areas"
J[3]="$HOME/3_resources"
J[c]="$HOME/2_areas/knowledge_management/blog/docs/corpus"

# g(go, cd)
g() { builtin cd -- "${J[$1]:-$HOME}/${2:-}"; }

# v(nvim)
v() {
  local key=$1
  shift
  g "$key"
  nvim "$@"
}

# Nav to parent directory
gg() { builtin cd ../; }

alias f='fzf'

# source ~/.zshrc
alias zz='exec zsh'

# Git shortcuts
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -v'

# Development tools
alias python='/opt/homebrew/bin/python3'
alias nvim12="$HOME/bin/nvim0.12/bin/nvim"
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


