# zsh-bitwarden

Oh My Zsh plugin for the [Bitwarden CLI](https://bitwarden.com/help/cli/) (`bw`).

Provides convenient aliases and functions for managing passwords, TOTP codes, and vault items directly from the command line, with automatic clipboard management and smart session handling.

**For Bitwarden Secrets Manager (`bws`), see the companion plugin:** [zsh-bitwarden-sm](https://github.com/underwoo/zsh-bitwarden-sm)

## Table of Contents

- [Installation](#installation)
  - [Oh My Zsh](#oh-my-zsh)
  - [Manual](#manual)
- [Requirements](#requirements)
- [Usage](#usage)
  - [Quick Start](#quick-start)
  - [Aliases](#aliases)
  - [Functions](#functions)
- [Examples](#examples)
- [Features](#features)
- [Configuration](#configuration)
- [Related Plugins](#related-plugins)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Installation

### Oh My Zsh

1. Clone this repository into `$ZSH_CUSTOM/plugins`:

   ```zsh
   git clone https://github.com/underwoo/zsh-bitwarden ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-bitwarden
   ```

2. Add `zsh-bitwarden` to your plugins array in `~/.zshrc`:

   ```zsh
   plugins=(
     # ... other plugins
     zsh-bitwarden
   )
   ```

3. Reload your shell:

   ```zsh
   source ~/.zshrc
   ```

### Manual

If you're not using Oh My Zsh, you can install manually:

```zsh
git clone https://github.com/underwoo/zsh-bitwarden ~/.zsh-bitwarden
echo "source ~/.zsh-bitwarden/bw.plugin.zsh" >> ~/.zshrc
source ~/.zshrc
```

## Requirements

- **Required**: [Bitwarden CLI (`bw`)](https://bitwarden.com/help/cli/) - version 2024.1.0 or later
- **Required**: `jq` - for JSON parsing
- **Oh My Zsh**: Recommended but not required

**Note:** For Bitwarden Secrets Manager (`bws`), see the separate [zsh-bitwarden-sm](https://github.com/underwoo/zsh-bitwarden-sm) plugin.

### Installing Dependencies

**macOS (Homebrew):**
```zsh
brew install bitwarden-cli jq
```

**Linux:**
```zsh
# Bitwarden CLI
curl -L https://vault.bitwarden.com/download/?app=cli&platform=linux -o bw.zip
unzip bw.zip && chmod +x bw && sudo mv bw /usr/local/bin/

# jq
sudo apt-get install jq  # Debian/Ubuntu
sudo dnf install jq      # Fedora/RHEL
```

## Usage

### Quick Start

```zsh
# One-time: Login to Bitwarden
bw login

# Daily workflow:
bwu                    # Unlock vault (start of day)
bwp github.com         # Get password → clipboard
bwt github.com         # Get TOTP code → clipboard
bwl                    # Lock vault (end of day)
```

### Aliases

#### Bitwarden CLI (`bw`)

| Alias | Command | Description |
|:------|:--------|:------------|
| `bwstat` | `bw status` | Show vault status (locked/unlocked) |
| `bwl` | `bw lock` | Lock vault and clear session |
| `bwsy` | `bw sync` | Sync vault with server |

#

### Functions

#### Bitwarden CLI (`bw`)

##### `bwu [password]`

Unlock vault and export session key.

```zsh
bwu                    # Prompts for password
bwu "my-password"      # Unlocks with provided password
```

- Checks vault status before unlocking
- Exports `BW_SESSION` environment variable
- Shows success/error messages

##### `bwp <search-term>`

Get password and copy to clipboard. Auto-clears after 20 seconds.

```zsh
bwp github.com         # Copy password for github.com
bwp aws                # Search and copy password for aws
```

- Searches vault by name/URL
- Copies password to clipboard
- Auto-clears clipboard after 20 seconds
- Shows search results if no exact match

##### `bwun <search-term>`

Get username for an item.

```zsh
bwun github.com        # Print username for github.com
```

- Returns username to stdout
- Useful for scripting

##### `bwt <search-term>`

Get TOTP code and copy to clipboard.

```zsh
bwt github.com         # Copy TOTP code for github.com
```

- Generates current TOTP code
- Copies to clipboard
- Displays code on screen

##### `bwls [search-term]`

List vault items with formatted output.

```zsh
bwls                   # List all items
bwls github            # Search for github items
```

- Shows name, username, and URL
- Formatted as table
- Searchable

##### `bwget <name-or-id>`

Get full item details as JSON.

```zsh
bwget github.com       # Show full item details
bwget <uuid>           # Get by item ID
```

- Returns complete item JSON
- Useful for scripting and inspection

##### `bwgen [length]`

Generate secure password and copy to clipboard.

```zsh
bwgen                  # Generate 20-char password (default)
bwgen 32               # Generate 32-char password
```

- Uses uppercase, lowercase, numbers, and symbols
- Copies to clipboard
- Displays generated password



## Examples

### Daily Development Workflow

```zsh
# Morning: Unlock vault
bwu

# Get credentials throughout the day
bwp github.com         # Push to GitHub
bwun aws-console       # Get AWS username
bwp aws-console        # Get AWS password
bwt aws-console        # Get MFA code

# Generate new password
bwgen 24               # For new account signup

# Evening: Lock vault
bwl
```

### Search and Discovery

```zsh
# Find items
bwls aws              # Search for AWS items
bwls                  # List everything

# Get details
bwget aws-console     # Full item JSON
```

## Features

```zsh
# Use in scripts
#!/usr/bin/env zsh
export DB_PASSWORD=$(bw get password "production-db" 2>/dev/null)
if [[ -z "$DB_PASSWORD" ]]; then
  echo "Failed to get password"
  exit 1
fi
# ... use DB_PASSWORD
```

## Features

### 🔒 Security

- **Auto-clear clipboard**: Passwords/TOTP codes auto-clear after 20 seconds
- **Session management**: `BW_SESSION` environment variable for secure session handling
- **Status checking**: Commands check vault status before operations
- **No password storage**: Passwords never written to disk by this plugin

### 🚀 Convenience

- **Smart search**: Fuzzy matching for item names and URLs
- **Tab completion**: Full command completion for `bw` CLI
- **Error handling**: Helpful error messages guide you to solutions
- **Pretty output**: Formatted tables and colored output

### 🔧 Flexibility

- **Scriptable**: All functions return predictable output for automation
- **Configurable**: Works with any Bitwarden server (self-hosted supported)
- **No bloat**: Only personal vault features - no unused dependencies

## Configuration

### Custom Bitwarden Server

```zsh
# Set before loading plugin (in .zshrc before oh-my-zsh.sh)
export BW_SERVER_URL="https://vault.example.com"
```

### Disable Auto-clear Clipboard

The plugin uses Oh My Zsh's `clipcopy` function which respects system clipboard. To prevent auto-clearing, you can modify the source or manually copy passwords.

## Related Plugins

### Bitwarden Secrets Manager

For managing application secrets, API keys, and service credentials, check out the companion plugin:

**[zsh-bitwarden-sm](https://github.com/underwoo/zsh-bitwarden-sm)** - Bitwarden Secrets Manager (`bws`) plugin

Key differences:
- **`bw` (this plugin)**: Personal password vault, interactive authentication
- **`bws` (separate plugin)**: Application/service secrets, token-based authentication

Install both if you need personal password management AND automated secrets management:

```zsh
plugins=(
  zsh-bitwarden     # Personal vault (bw)
  zsh-bitwarden-sm  # Secrets Manager (bws)
)
```

## Troubleshooting

### Vault is locked

```zsh
bwu  # Unlock vault
```

### Not logged in

```zsh
bw login  # One-time login
```

### Session expired

```zsh
bw lock   # Clear old session
bwu       # Get new session
```

### Command not found: bw

```zsh
# Check installation
which bw

# Install on macOS
brew install bitwarden-cli

# Verify
bw --version
```

### jq not found

```zsh
# macOS
brew install jq

# Linux
sudo apt-get install jq  # Debian/Ubuntu
sudo dnf install jq      # Fedora/RHEL
```

### Clipboard not clearing

The auto-clear feature uses background jobs. If you exit your shell before 20 seconds, clipboard won't clear. This is intentional - the data remains accessible until timeout.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development

```zsh
# Clone for development
git clone https://github.com/underwoo/zsh-bitwarden
cd zsh-bitwarden

# Test changes
source bw.plugin.zsh

# Run syntax check
zsh -n bw.plugin.zsh
```

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Bitwarden](https://bitwarden.com/) for the excellent CLI tools
- [Oh My Zsh](https://ohmyz.sh/) for the plugin framework
- Inspired by various Bitwarden CLI wrapper projects

## Related Projects

- [zsh-bitwarden-sm](https://github.com/underwoo/zsh-bitwarden-sm) - Companion plugin for Bitwarden Secrets Manager
- [Bitwarden CLI](https://github.com/bitwarden/clients/tree/main/apps/cli) - Official Bitwarden command-line client
- [rbw](https://github.com/doy/rbw) - Unofficial Bitwarden CLI (Rust)

---

**Author**: [Seth Underwood](https://github.com/underwoo)

**Repository**: [github.com/underwoo/zsh-bitwarden](https://github.com/underwoo/zsh-bitwarden)

**Issues**: [github.com/underwoo/zsh-bitwarden/issues](https://github.com/underwoo/zsh-bitwarden/issues)
