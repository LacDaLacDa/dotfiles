set fish_greeting

set -gx TERM tmux-256color

set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

alias ls "ls -p -G"
alias la "la -A"
alias ll "ls -l"
alias lla "ll -A"
alias g git
alias k kubectl
alias d docker
alias dc "docker compose"
command -qv nvim && alias vi nvim

set -gx EDITOR nvim
set -gx DOTNET_ROOT "$HOME/.dotnet"
set -gx SSH_AUTH_SOCK "~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock"

set -gx PATH /opt/homebrew/bin $PATH
set -gx PATH /opt/homebrew/sbin $PATH
set -gx PATH $HOME/.pub-cache/bin $PATH
set -gx PATH $DOTNET_ROOT $PATH
set -gx PATH $DOTNET_ROOT/tools $PATH

if type -q eza
    alias ls "eza --icons always"
    alias ll "ls -l -g"
    alias lla "ll -a"
end

if type -q mise
  ~/.local/bin/mise activate fish | source
end

if type -q bat
  set -g FZF_PREVIEW_FILE_CMD "bat --style=numsbers --color=always --line-range :500"
  set -g FZF_LEGACY_KEYBINDINGS 0
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source "$HOME/.orbstack/shell/init2.fish" 2>/dev/null || :

# cargo
source "$HOME/.cargo/env.fish"
