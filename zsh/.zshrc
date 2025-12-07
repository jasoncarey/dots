# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    )

source $ZSH/oh-my-zsh.sh

fpath=(~/.zsh $fpath)
autoload -Uz compinit
compinit -u


# My stuff
export PATH="$PATH:/usr/local/bin/npm"
export GOPATH="/Users/jason/go"
export PATH="$PATH:$GOPATH/bin"
export PATH="/Library/TeX/texbin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion"  # This loads nvm bash_completion

# Awsume
# source $(brew --prefix awsume)/awsume.sh

# Zoxide
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH=~/bin:$PATH

# Created by `pipx` on 2024-09-07 14:13:59
export PATH="$PATH:/Users/jason/.local/bin"
. "/Users/jason/.deno/env"
# Added by Windsurf
export PATH="/Users/jason/.codeium/windsurf/bin:$PATH"

alias gs="git status"
alias lg="lazygit"
alias c="clear"
alias ll="ls -la"
alias l="ls -l"
alias la="ls -a"
alias lsa="ls -la"
alias ls="ls -l"
alias ll="ls -la"
alias l="ls -l"