# AGENTS.md

Guide for AI agents working in this ZSH profile repository.

## Project Overview

This is **Jody's ZSH Profile** - a modular, platform-aware shell configuration system for macOS (darwin) and Linux. It uses [antidote](https://github.com/mattmc3/antidote) for plugin management and [spaceship-prompt](https://github.com/spaceship-prompt/spaceship-prompt) for the prompt.

**Key characteristics:**
- Modular configuration through numbered, OS-specific files in `zshrc.d/`
- Custom PATH building with duplicate detection
- Platform-specific loading (Darwin vs Linux)
- Debug mode support
- Extensive tool integrations (Docker, Kubernetes, AWS, GCP, Go, Java, etc.)

## Installation & Setup

### Initial Installation
```bash
git clone https://github.com/jodydadescott/jodys_zsh.git ~/.zshprofile
cd ~/.zshprofile
./install.sh
```

### What install.sh Does
1. Clones antidote to `~/.antidote`
2. Clones spaceship-prompt to `~/.spaceship`
3. Creates/updates `~/.zshrc` with:
   ```bash
   ZSH_PROFILE="${HOME}/.zshprofile"
   source ${ZSH_PROFILE}/zshrc
   ```
4. Backs up existing `~/.zshrc` to `~/.zshrc.$RANDOM` if different

### Manual Testing
```bash
# Enable debug mode to see what's loading
touch ~/.zdebug
# or use the function:
debug-enable

# Disable debug mode
debug-disable
```

## Repository Structure

```
.zshprofile/
├── zshrc                  # Main loader (OS detection, plugin loading, PATH setup)
├── _zshrc                 # Legacy loader (deprecated, but still present)
├── install.sh             # Installation script
├── zshrc.d/               # Modular config files (MAIN FOCUS)
│   ├── 10-common-gnu
│   ├── 11-common-local
│   ├── 100-common-*       # Cross-platform configs
│   ├── 100-darwin-*       # macOS-specific configs
│   ├── 100-linux-*        # Linux-specific configs
│   ├── context            # User notes/context (not loaded)
│   └── off/               # Disabled modules
├── plugins/
│   ├── common             # Antidote plugin list
│   ├── common.zsh         # Plugin loading logic
│   └── zsh_notify/        # Custom notify plugin
└── scripts/
    └── update_golang      # Go version updater script
```

## Module Loading System

### File Naming Convention

Files in `zshrc.d/` follow this pattern:
```
<priority>-<platform>-<name>
```

**Priority (numeric prefix):**
- `10-` = Early loading (GNU tools)
- `11-` = Local paths
- `99-` = Late loading (Homebrew)
- `100-` = Standard modules

**Platform:**
- `common` = All platforms
- `darwin` = macOS only
- `linux` = Linux only

**Examples:**
- `10-common-gnu` - Loads first, all platforms
- `100-darwin-docker` - macOS Docker config
- `100-common-aliases` - Aliases for all platforms

### Loading Order

From `zshrc` (lines 70-102):
1. Files sorted numerically by prefix
2. OS detection via `uname` (converted to lowercase)
3. Load if `parts[2]` matches OS name OR equals "common"
4. Files in `off/` subdirectory are ignored

### PATH Building

**Critical pattern:** Uses `TMP_PATH` variable to build PATH without duplicates.

```bash
# From zshrc lines 16-31
function addpath() {
  for p in $@; do
    _addpath "$p"
  done
}

function _addpath() {
  echo -e "${TMP_PATH//:/"\n"}" | while read p ; do
  [[ "$p" == "$1" ]] && {
    err-debug "ignoring duplicate request to add path $p";
    return 0
  } ||:
  done
  [ -n "$TMP_PATH" ] && { TMP_PATH+=":$1"; } || { TMP_PATH="$1"; }
  return 0
}
```

**Final PATH setup (lines 98-102):**
```bash
unset TMP_PATH
load_zshrcd
addpath /bin /usr/bin
export PATH="$TMP_PATH"
unset TMP_PATH
```

## Key Modules & Patterns

### Common Modules

#### `11-common-local`
```bash
addpath /usr/local/bin
addpath $HOME/.local/bin
```
Local binary paths for user-installed tools.

#### `100-common-golang`
```bash
export GOPATH=$HOME/workspace
export GOROOT=$HOME/.go
addpath $GOPATH/bin $GOROOT/bin

function gotidy() {
  find ./ -name go.mod -exec realpath {} ';' | awk '{print "dirname "$0}' | zsh | awk '{print "cd "$0" && go mod tidy -e"}' | zsh -x;
}
```
**Gotcha:** Uses custom GOROOT at `~/.go`, not system Go.

#### `100-common-history`
```bash
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTFILE=~/.zsh_history
export SAVEHIST=100000

alias history="fc -l 1"
alias hist="fc -l 1"
alias chistory="fc -n -l 1"  # Clean history (no line numbers)
alias chist="fc -n -l 1"
```

#### `100-common-jump`
Custom "jump directory" system for quickly switching between directories across shells:
```bash
jset       # Set jump directory to $PWD
j          # Jump to saved directory
```
**Implementation:** Uses `~/.jumpdir` file to store target directory.

#### `100-common-cd-ls`
```bash
function ls_after_cd() { ls; }
add-zsh-hook chpwd ls_after_cd
```
Automatically runs `ls` after every `cd`.

#### `100-common-aws`
```bash
function aws-set-profile() {
  [ -n "$1" ] || {
    unset AWS_PROFILE
    err "AWS Profile set to default. Add profile name to arg for non-default"
    return 0
  }
  export AWS_PROFILE=$1
  err "AWS Profile set to $AWS_PROFILE"
}

# Completions loaded from Homebrew-installed eksctl
source <(/opt/homebrew/bin/eksctl completion zsh)
```

#### `100-common-gcloud`
```bash
if [ -d /usr/local/google-cloud-sdk ]; then
  addpath /usr/local/google-cloud-sdk/bin
  [ -f /usr/local/google-cloud-sdk/completion.zsh.inc ] && . /usr/local/google-cloud-sdk/completion.zsh.inc ||:
fi
```

#### `100-common-aliases`
```bash
alias daisy="ssh daisy"
alias poppy="ssh poppy"
alias snoopy="ssh snoopy"
alias asterisk="docker exec -it asterisk asterisk -rvvvvv"
```
Personal server shortcuts and tool aliases.

### Darwin (macOS) Modules

#### `99-darwin-brew`
```bash
addpath /opt/homebrew/sbin /opt/homebrew/bin
```
**Loaded last** (99 prefix) to allow Homebrew to override system tools.

#### `100-darwin-base`
```bash
addpath /sbin
```
Simple PATH addition for macOS system tools.

#### `100-darwin-java`
```bash
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-21.0.8.jdk/Contents/Home
# export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-24.jdk/Contents/Home
# export JAVA_HOME=/Library/Java/JavaVirtualMachines/graalvm-jdk-24.0.2+11.1/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH
```
**Pattern:** Multiple JAVA_HOME options commented out. Currently using JDK 21.0.8.

**Gotcha:** Directly modifies PATH, not using `addpath()`. This is intentional to ensure Java bins are first in PATH.

#### `100-darwin-docker`
```bash
export DOCKER_RAW_FILE="${HOME}/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw"
export DOCKER_MAX_FILE_SIZE=13000 # Megabytes

function docker_raw_file_cleanup() {
  # Removes Docker.raw if > 13GB
}

function docker_container_cleanup() {
  docker ps -a | grep Exited | awk '{print "docker rm "$1}' | bash
}

function docker_start() {
  /Applications/Docker.app/Contents/MacOS/Docker &!;
}
```
**macOS-specific:** Docker Desktop's raw disk file management.

#### `100-darwin-kubectl`
```bash
# Full path to bin is required because path is being built
source <(/opt/homebrew/bin/kubectl completion zsh)

alias k=kubectl

function kset() {
  [[ "$1" ]] && {
    k config use-context "$1"
  } || {
    k config get-contexts --output=name
  }
}

function knset() {
  [[ "$1" ]] && {
    k config set-context --current --namespace="$1"
  } || {
    k get ns
  }
}
```
**Pattern:** Hardcoded `/opt/homebrew/bin/kubectl` because PATH is still being built at load time.

#### `100-darwin-terraform`
```bash
complete -o nospace -C /usr/local/bin/terraform terraform
```
**Gotcha:** Uses `/usr/local/bin`, not Homebrew's `/opt/homebrew/bin`. May need updating.

#### `100-darwin-spaceship`
Configures spaceship-prompt display order and settings. Shows:
- user, dir, host, git
- golang, rust, java, docker, docker_compose
- aws, gcloud, kubectl, terraform
- exec_time, jobs, exit_code, sudo, char

```bash
SPACESHIP_PROMPT_SEPARATE_LINE=false
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_HOST_SHOW=true
SPACESHIP_USER_SHOW=true
SPACESHIP_CHAR_SYMBOL="➜"
SPACESHIP_DIR_SHOW=false  # Note: Directory display disabled
```

### Linux Modules

#### `100-linux-base`
```bash
PATH=/usr/bin:/bin:/usr/sbin:/sbin
PATH+=:/usr/local/bin:/usr/local/sbin
```
**Gotcha:** Directly sets PATH, not using `addpath()`. Linux base PATH setup.

## Plugin System

### Antidote Plugins

Defined in `plugins/common`:
```
belak/zsh-utils path:editor
belak/zsh-utils path:history
belak/zsh-utils path:prompt
belak/zsh-utils path:utility
belak/zsh-utils path:completion

zdharma/fast-syntax-highlighting
zsh-users/zsh-autosuggestions
zsh-users/zsh-history-substring-search
zsh-users/zsh-completions
```

### Keybindings

From `zshrc` (lines 59-63):
```bash
bindkey '^[[A' history-substring-search-up    # Up arrow
bindkey '^[[B' history-substring-search-down  # Down arrow
bindkey '^[[3~' delete-char                   # Delete key
bindkey '^[3;5~' delete-char                  # Ctrl+Delete
```

### ZSH Options

From `zshrc` (lines 42-62):
```bash
setopt auto_cd                   # cd by typing directory name
setopt auto_list                 # list choices on ambiguous completion
setopt auto_menu                 # use menu completion
setopt always_to_end            # move cursor to end on single match
setopt hist_ignore_all_dups     # remove older duplicates
setopt hist_reduce_blanks       # remove superfluous blanks
setopt inc_append_history       # save history immediately
setopt share_history            # share between instances
setopt interactive_comments     # allow # comments
```

## Scripts

### `scripts/update_golang`

Updates Go to the latest version from go.dev.

**Usage:**
```bash
# Must have GOROOT set (from 100-common-golang)
./scripts/update_golang
```

**What it does:**
1. Fetches latest Go version from go.dev/dl/
2. Compares with local version at `$GOROOT/bin/go`
3. Downloads appropriate tarball for OS/ARCH
4. Extracts to `$GOROOT` (replaces existing)
5. Verifies installation

**Gotcha:** Requires `GOROOT` to be set. Uses `uname -o` which may not work on all systems (macOS uses `uname -s`).

## Common Patterns

### Error Handling

```bash
# Standard error function used throughout
err() { echo "$@" 1>&2; }

# Debug-aware error function (from zshrc)
err-debug() {
  [ -f "$HOME/.zdebug" ] || return 0
  err "$@"
}
```

### Conditional Execution Pattern

```bash
# Common idiom for optional operations
[ condition ] && {
  # do something
  return 0
} ||:  # The ||: ensures script continues even if condition is false
```

### Function Aliases

```bash
# Pattern used for one-liner function aliases
alias j='f() { jump_to_dir $@; };f'
alias jset='f() { set_jump_dir $@; };f'
```

### Completion Loading

```bash
# Pattern: Use full path because PATH is being built
source <(/opt/homebrew/bin/kubectl completion zsh)
source <(/opt/homebrew/bin/eksctl completion zsh)
```

## Making Changes

### Adding a New Module

1. **Determine platform and priority:**
   - Cross-platform? Use `common`
   - macOS only? Use `darwin`
   - Linux only? Use `linux`
   - Choose priority: `10` (early), `11` (local), `100` (standard), `99` (late)

2. **Create file in zshrc.d/:**
   ```bash
   # Example: Add a new Python configuration
   touch zshrc.d/100-common-python
   ```

3. **Use standard patterns:**
   ```bash
   # Add to PATH
   addpath /path/to/bins
   
   # Set environment variables
   export PYTHON_HOME=/path/to/python
   
   # Add completions (use full path on macOS)
   source <(/opt/homebrew/bin/pip completion --zsh)
   
   # Create functions/aliases
   function pyclean() {
     find . -name "*.pyc" -delete
   }
   ```

4. **Test with debug mode:**
   ```bash
   debug-enable
   source ~/.zshrc
   # Should see "loading 100-common-python"
   ```

### Disabling a Module

Move to `off/` subdirectory:
```bash
mv zshrc.d/100-common-aliases zshrc.d/off/
```

### PATH Management Rules

1. **Use `addpath` for most cases** - prevents duplicates
2. **Use direct PATH modification for priority overrides:**
   - Java bins (needs to be first)
   - Homebrew (needs to override system tools)
   - Base system paths on Linux

3. **Order matters:**
   - Lower-numbered files load first
   - Homebrew loaded last (99 prefix) to override system tools
   - Final PATH export happens after all modules load

### Completion Loading Gotcha

⚠️ **When loading completions in Darwin modules, use full paths:**

```bash
# ✅ CORRECT
source <(/opt/homebrew/bin/kubectl completion zsh)

# ❌ WRONG (PATH not fully built yet)
source <(kubectl completion zsh)
```

**Why:** Modules load while PATH is still being constructed. The `kubectl` binary may not be in PATH yet when the module loads.

## Git Workflow

### Recent Changes Pattern

Recent commits show minimal commit messages:
```
fddfb15 updated
33396e8 updated
f7e36a1 updated
```

**When committing:**
- Use descriptive messages for significant changes
- "updated" is acceptable for minor tweaks
- Test thoroughly before committing (source ~/.zshrc to test)

### Current Status

Modified files:
```
M  zshrc.d/100-common-gcloud
D  zshrc.d/100-darwin-gcloud  (deleted)
M  zshrc.d/100-darwin-java
M  zshrc.d/11-common-local
```

Untracked files:
```
?? .gitignore
?? zshrc.d/100-darwin-autopilot
?? zshrc.d/100-darwin-gcp
?? zshrc.d/context
?? zshrc.d/off/
```

**Pattern:** `.gitignore` exists but is untracked. May want to commit it.

## Debugging & Troubleshooting

### Enable Verbose Loading

```bash
debug-enable
source ~/.zshrc
```

You'll see messages like:
```
loading 10-common-gnu
loading 100-common-aliases
ignoring duplicate request to add path /usr/local/bin
```

### Check PATH Building

```bash
# See what's in PATH
echo $PATH | tr ':' '\n'

# See if duplicate detection is working
debug-enable
# Add a path twice in a module, reload
source ~/.zshrc
# Should see "ignoring duplicate request" message
```

### Module Not Loading?

1. **Check filename format:** `<number>-<platform>-<name>`
2. **Check OS detection:**
   ```bash
   uname  # Should be "Darwin" or "Linux"
   ```
3. **Enable debug mode** to see loading messages
4. **Check file permissions:** Must be readable
5. **No .zsh extension needed** - any file without extension or with wrong pattern is ignored

### Common Issues

**Issue:** Module loads but PATH not updated
- **Cause:** Using `PATH+=` instead of `addpath`
- **Fix:** Use `addpath` for duplicate detection

**Issue:** Command not found even though module loaded
- **Cause:** PATH set after export, or duplicate PATH entry detected
- **Solution:** Check load order, ensure using `addpath`

**Issue:** Completions not working
- **Cause:** Using relative command path during load
- **Fix:** Use full path in Darwin modules: `/opt/homebrew/bin/kubectl`

## Testing

### Quick Tests After Changes

```bash
# Test syntax
zsh -n ~/.zshprofile/zshrc

# Test loading
source ~/.zshprofile/zshrc

# Test specific module
source ~/.zshprofile/zshrc.d/100-common-golang

# Verify PATH
echo $PATH | tr ':' '\n'

# Check environment variables
env | grep -E 'GOPATH|GOROOT|JAVA_HOME|AWS_PROFILE'

# Test functions
type jump_to_dir
type aws-set-profile
```

### Full Test

```bash
# Start new shell to test full load
zsh -l

# Check prompt appears correctly (spaceship)
# Try a few aliases
history
k get pods  # if kubectl configured
```

## Special Files

### `zshrc.d/context`

This file is **NOT loaded** (no platform/number prefix). Used for storing user notes/context. Current content:
```
User Question: How does ingress-nginx-controller work without having an Ingress resource itself?
Context: ingress-nginx-controller should handle ALL external ingress, using nginx PATH routing
Confusion: The controller doesn't have an ingress resource pointing to it
```

**Purpose:** Personal notes, context, reminders. Not executed.

### `zshrc.d/.crush/`

Hidden directory, appears to be from Crush AI agent tool. Contains agent memory/context files.

## External Dependencies

### Required
- **antidote** - Plugin manager (installed to `~/.antidote` by install.sh)
- **spaceship-prompt** - Prompt theme (installed to `~/.spaceship` by install.sh)

### Optional (Tool-specific)
- **Homebrew** (`/opt/homebrew` on Apple Silicon, `/usr/local` on Intel)
- **kubectl** (for Kubernetes functions)
- **eksctl** (for AWS EKS completions)
- **Docker Desktop** (for Docker functions)
- **gcloud SDK** (for Google Cloud)
- **terraform** (for completion)

### Version Requirements

**Go:** Managed by `scripts/update_golang`, uses custom `$GOROOT`
**Java:** Currently JDK 21.0.8 (hardcoded in 100-darwin-java)
**Node/NPM:** Module exists (`100-common-npm`) but not examined in detail

## Code Style

### Conventions Observed

1. **Functions:**
   ```bash
   function name() {
     # body
   }
   ```

2. **Error messages:** Use `err` function to write to stderr

3. **Conditionals:**
   ```bash
   [ condition ] && {
     # true block
   } || {
     # false block (optional)
   }
   # Or with continuation:
   } ||:
   ```

4. **Parameter checking:**
   ```bash
   [[ "$1" ]] && {
     # parameter provided
   } || {
     # no parameter
   }
   ```

5. **Comments:**
   - Use `#` for inline comments
   - Use `##...##` blocks for longer explanations (see 100-common-jump)

6. **Exports:**
   - Environment variables: `export VAR=value`
   - Functions: Just define them (exported by default in modules)

## Platform-Specific Notes

### macOS (Darwin)

- **Homebrew location:** `/opt/homebrew` (Apple Silicon) or `/usr/local` (Intel)
  - **Currently assumes Apple Silicon** in most modules
- **Java:** Managed via Homebrew cask, stored in `/Library/Java/JavaVirtualMachines/`
- **Docker:** Docker Desktop, has special cleanup functions
- **Completions:** Often need full paths during load

### Linux

- **Minimal configuration:** Only base PATH setup and spaceship config observed
- **System tools:** Uses standard locations (`/usr/bin`, `/usr/sbin`)
- **No Homebrew:** Different package manager assumed

## Future Agent Considerations

### When Making Changes

1. **Read the module first** - patterns vary between modules
2. **Test with debug mode** - catch loading issues immediately
3. **Use `addpath` unless you have a good reason** - prevents PATH pollution
4. **Match existing style** - keep consistency
5. **Consider platform differences** - test on both Darwin and Linux if possible
6. **Document non-obvious choices** - add comments for future reference

### Common Tasks

**Add new tool integration:**
1. Create `100-<platform>-<tool>` in zshrc.d/
2. Use `addpath` for binaries
3. Export environment variables
4. Source completions (full path on macOS)
5. Add helper functions/aliases

**Modify PATH:**
1. Find relevant module or create new one
2. Use `addpath` to add directories
3. Test with debug mode to check for duplicates

**Update tool version:**
1. Find module setting path/version
2. Update hardcoded paths/versions
3. Test that tool works after reload

**Disable/enable modules:**
1. Move to/from `zshrc.d/off/` directory
2. Reload shell to test

## Summary

This is a well-organized, modular ZSH configuration with:
- ✅ Clear loading order (numeric prefixes)
- ✅ OS-aware loading (darwin/linux/common)
- ✅ Duplicate PATH detection
- ✅ Debug mode support
- ✅ Extensive tool integrations
- ✅ Custom helper functions

**Key principles:**
- Modules are self-contained
- Use `addpath` for PATH management
- Use full paths for completions on macOS
- Test with debug mode enabled
- Follow existing patterns

**Watch out for:**
- Hardcoded tool paths (Java, Homebrew locations)
- Direct PATH manipulation in some modules (intentional)
- Completion loading needs full paths during module load
- OS-specific conventions (Homebrew on macOS, standard paths on Linux)
