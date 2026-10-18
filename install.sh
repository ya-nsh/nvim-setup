#!/bin/bash
# nvim-setup installer for macOS: Neovim set up for VS Code habits, with Ghostty.
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ya-nsh/nvim-setup/main/install.sh)"
#
# Safe to run again: it updates what's there and backs up anything it replaces.
#
# Options:
#   --skip-brew     don't install Homebrew packages (you manage them yourself)
#   --no-ghostty    don't install or configure Ghostty
# Environment:
#   NVIM_SETUP_REPO, NVIM_SETUP_BRANCH   clone from somewhere else (forks, testing)

set -euo pipefail

REPO="${NVIM_SETUP_REPO:-https://github.com/ya-nsh/nvim-setup.git}"
BRANCH="${NVIM_SETUP_BRANCH:-main}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
NVIM_DIR="$CONFIG_HOME/nvim"
STAMP="$(date +%Y%m%d-%H%M%S)"

SKIP_BREW=0
GHOSTTY=1
for arg in "$@"; do
  case "$arg" in
    --skip-brew) SKIP_BREW=1 ;;
    --no-ghostty) GHOSTTY=0 ;;
    -h | --help)
      sed -n '2,13p' "$0" 2>/dev/null || true
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

bold=$'\033[1m' green=$'\033[32m' yellow=$'\033[33m' red=$'\033[31m' reset=$'\033[0m'
step() { printf '\n%s==> %s%s\n' "$bold" "$1" "$reset"; }
info() { printf '    %s\n' "$1"; }
warn() { printf '%s    ! %s%s\n' "$yellow" "$1" "$reset"; }
die() {
  printf '%sError: %s%s\n' "$red" "$1" "$reset" >&2
  exit 1
}

[ "$(uname -s)" = "Darwin" ] || die "this installer is for macOS."

# --- Homebrew --------------------------------------------------------------
brew_shellenv() {
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$b" ]; then
      eval "$("$b" shellenv)"
      return 0
    fi
  done
  return 1
}

if [ "$SKIP_BREW" -eq 0 ]; then
  step "Homebrew"
  if ! command -v brew >/dev/null 2>&1 && ! brew_shellenv; then
    info "Installing Homebrew (it asks for your password and installs Apple's command line tools)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew_shellenv || die "Homebrew installed, but brew isn't on PATH. Open a new terminal and run this again."
  fi
  # Make brew available in new shells too
  BREW_LINE="eval \"\$($(command -v brew) shellenv)\""
  if ! grep -qsF "$BREW_LINE" "$HOME/.zprofile"; then
    printf '\n%s\n' "$BREW_LINE" >>"$HOME/.zprofile"
    info "Added Homebrew to ~/.zprofile"
  fi
  info "$(brew --version | head -1)"

  step "Command-line tools"
  # neovim, git, ripgrep (search), fd (file finder), lazygit (git UI),
  # tree-sitter-cli (builds syntax parsers)
  formulae=(neovim ripgrep fd lazygit tree-sitter-cli)
  # Apple's git (installed with Homebrew's command line tools) is fine
  git --version >/dev/null 2>&1 || formulae+=(git)
  # Language servers need these; keep your own install (nvm, asdf, ...) if you have one
  command -v npm >/dev/null 2>&1 || formulae+=(node)
  command -v go >/dev/null 2>&1 || formulae+=(go)
  command -v python3 >/dev/null 2>&1 || formulae+=(python)
  missing=()
  for f in "${formulae[@]}"; do
    brew list --formula "$f" >/dev/null 2>&1 || missing+=("$f")
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    info "Installing: ${missing[*]}"
    brew install "${missing[@]}"
  else
    info "All installed"
  fi

  step "Font"
  if compgen -G "$HOME/Library/Fonts/JetBrainsMonoNerdFont*" >/dev/null ||
    compgen -G "/Library/Fonts/JetBrainsMonoNerdFont*" >/dev/null; then
    info "JetBrains Mono Nerd Font already installed"
  else
    brew install --cask font-jetbrains-mono-nerd-font
  fi

  if [ "$GHOSTTY" -eq 1 ]; then
    step "Ghostty"
    if [ -d /Applications/Ghostty.app ] || [ -d "$HOME/Applications/Ghostty.app" ]; then
      info "Already installed"
    else
      brew install --cask ghostty
    fi
  fi
fi

# --- Checks ----------------------------------------------------------------
step "Checking requirements"
for cmd in git nvim rg fd tree-sitter; do
  command -v "$cmd" >/dev/null 2>&1 || die "$cmd not found. Install it (or run without --skip-brew)."
done
NVIM_OK="$(nvim --headless --clean -c 'lua io.stdout:write(vim.fn.has("nvim-0.11"))' -c 'qall!' 2>/dev/null || true)"
[ "$NVIM_OK" = "1" ] || die "Neovim 0.11 or newer is needed; $(command -v nvim) is $(nvim --version | head -1)."
info "$(nvim --version | head -1) at $(command -v nvim)"

# --- The config ------------------------------------------------------------
step "Neovim config in $NVIM_DIR"
mkdir -p "$CONFIG_HOME"
if [ -d "$NVIM_DIR/.git" ] && git -C "$NVIM_DIR" remote get-url origin 2>/dev/null | grep -q "nvim-setup"; then
  if [ -n "$(git -C "$NVIM_DIR" status --porcelain)" ]; then
    warn "You have local changes in $NVIM_DIR; leaving them alone (not updating)."
  else
    git -C "$NVIM_DIR" pull --ff-only --quiet && info "Updated to the latest version"
  fi
else
  if [ -e "$NVIM_DIR" ] || [ -L "$NVIM_DIR" ]; then
    mv "$NVIM_DIR" "$NVIM_DIR.bak-$STAMP"
    info "Moved your old config to $NVIM_DIR.bak-$STAMP"
  fi
  git clone --quiet --branch "$BRANCH" "$REPO" "$NVIM_DIR"
  info "Cloned $REPO"
fi

# --- Ghostty config --------------------------------------------------------
if [ "$GHOSTTY" -eq 1 ]; then
  step "Ghostty config"
  GHOSTTY_KEYS="$NVIM_DIR/ghostty/nvim.conf"
  existing=""
  for f in "$CONFIG_HOME/ghostty/config.ghostty" "$CONFIG_HOME/ghostty/config" \
    "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty" \
    "$HOME/Library/Application Support/com.mitchellh.ghostty/config"; do
    if [ -s "$f" ]; then
      existing="$f"
      break
    fi
  done
  if [ -z "$existing" ]; then
    # No Ghostty config yet: use this repo's look and keys
    mkdir -p "$CONFIG_HOME/ghostty"
    printf '# Look and keys from nvim-setup (edit that file, or add your own settings below)\nconfig-file = %s\n' \
      "$NVIM_DIR/ghostty/config" >"$CONFIG_HOME/ghostty/config"
    info "Created $CONFIG_HOME/ghostty/config"
  elif grep -qsF "$GHOSTTY_KEYS" "$existing" || grep -qsF "$NVIM_DIR/ghostty/config" "$existing"; then
    info "Already set up in $existing"
  else
    # Keep your Ghostty config; just add the Neovim keys to it
    cp "$existing" "$existing.bak-$STAMP"
    printf '\n# nvim-setup: let Cmd+Z, Cmd+F, Cmd+Shift+F, Cmd+Shift+P reach Neovim\nconfig-file = %s\n' \
      "$GHOSTTY_KEYS" >>"$existing"
    info "Added Neovim keys to $existing (backup: $existing.bak-$STAMP)"
  fi
fi

# --- Plugins, parsers, language servers --------------------------------------
step "Installing plugins, parsers and language servers (a few minutes)"
# pcall + cquit: if the script errors, exit with a failure instead of leaving Neovim open
BOOTSTRAP="$NVIM_DIR/scripts/bootstrap.lua"
nvim --headless -c "lua local ok, err = pcall(dofile, [[$BOOTSTRAP]]) if not ok then io.stderr:write(tostring(err) .. '\n') vim.cmd('cquit 1') end" ||
  die "Setup inside Neovim failed (see above). Fix it and run this again."

printf '\n%s%sDone!%s\n' "$green" "$bold" "$reset"
cat <<EOF
  1. Open Ghostty (or reload it: Cmd+S then R).
  2. Run: nvim .
  3. Press ? for help: every shortcut, explained.

  Berkeley Mono is a paid font, so it isn't installed. If you own it, install it
  and Ghostty uses it automatically; until then you get JetBrains Mono.
EOF
