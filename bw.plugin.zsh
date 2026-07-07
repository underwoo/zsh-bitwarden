#!/usr/bin/env zsh
# Bitwarden CLI plugin for oh-my-zsh
# Works with the official Bitwarden CLI (bw)

# Check if bw is installed
if ! command -v bw &> /dev/null; then
  return
fi

# Load completions for bw CLI
if [[ ! -f "$ZSH_CACHE_DIR/completions/_bw" ]]; then
  typeset -g -A _comps
  autoload -Uz _bw
  _comps[bw]=_bw
fi

# Generate completions
bw completion --shell zsh >| "$ZSH_CACHE_DIR/completions/_bw" &|

#
# Aliases
#
# bwstat - Show vault status
alias bwstat='bw status'
alias bwl='bw lock'
alias bwsy='bw sync'

#
# Functions
#

# bwu - Unlock vault and export session
# Usage: bwu [password]
bwu() {
  local status=$(bw status 2>/dev/null | command jq -r '.status' 2>/dev/null)
  
  if [[ "$status" == "unlocked" ]]; then
    echo "✓ Vault already unlocked"
    return 0
  fi
  
  if [[ "$status" == "unauthenticated" ]]; then
    echo "✗ Not logged in. Run: bw login"
    return 1
  fi
  
  echo "Unlocking vault..."
  if [[ -n "$1" ]]; then
    export BW_SESSION=$(bw unlock "$1" --raw)
  else
    export BW_SESSION=$(bw unlock --raw)
  fi
  
  if [[ $? -eq 0 ]]; then
    echo "✓ Vault unlocked (session: BW_SESSION)"
  else
    echo "✗ Failed to unlock vault"
    return 1
  fi
}

# bwp - Get password and copy to clipboard
# Usage: bwp <search-term>
bwp() {
  if [[ -z "$1" ]]; then
    echo "Usage: bwp <search-term>"
    return 1
  fi
  
  local password=$(bw get password "$1" 2>/dev/null)
  
  if [[ $? -eq 0 && -n "$password" ]]; then
    echo -n "$password" | clipcopy
    echo "✓ Password copied to clipboard"
    
    # Auto-clear clipboard after 20 seconds
    local _random="$RANDOM" _cache="$ZSH_CACHE_DIR/.bwp"
    echo -n "$_random" > "$_cache"
    
    {
      sleep 20 \
      && [[ "$(<"$_cache")" == "$_random" ]] \
      && clipcopy </dev/null 2>/dev/null \
      && command rm -f "$_cache" &>/dev/null
    } &|
  else
    echo "✗ No password found for: $1"
    echo "\nSearching items..."
    bw list items --search "$1" 2>/dev/null | command jq -r '.[] | "\(.name) (\(.login.username // "no username"))"'
  fi
}

# bwun - Get username
# Usage: bwun <search-term>
bwun() {
  if [[ -z "$1" ]]; then
    echo "Usage: bwun <search-term>"
    return 1
  fi
  
  local username=$(bw get username "$1" 2>/dev/null)
  
  if [[ $? -eq 0 && -n "$username" ]]; then
    echo "$username"
  else
    echo "✗ No username found for: $1" >&2
    return 1
  fi
}

# bwt - Get TOTP code and copy to clipboard
# Usage: bwt <search-term>
bwt() {
  if [[ -z "$1" ]]; then
    echo "Usage: bwt <search-term>"
    return 1
  fi
  
  local totp=$(bw get totp "$1" 2>/dev/null)
  
  if [[ $? -eq 0 && -n "$totp" ]]; then
    echo -n "$totp" | clipcopy
    echo "✓ TOTP code copied to clipboard: $totp"
  else
    echo "✗ No TOTP configured for: $1"
    return 1
  fi
}

# bwls - List items (pretty output)
# Usage: bwls [search-term]
bwls() {
  if [[ -n "$1" ]]; then
    bw list items --search "$1" 2>/dev/null | command jq -r '.[] | {name: .name, username: .login.username, url: (.login.uris[0].uri // "no url")} | "\(.name) | \(.username) | \(.url)"' | column -t -s '|'
  else
    bw list items 2>/dev/null | command jq -r '.[] | {name: .name, username: .login.username} | "\(.name) | \(.username)"' | column -t -s '|'
  fi
}

# bwget - Get full item details
# Usage: bwget <name-or-id>
bwget() {
  if [[ -z "$1" ]]; then
    echo "Usage: bwget <name-or-id>"
    return 1
  fi
  
  bw get item "$1" 2>/dev/null | command jq
}

# bwgen - Generate password and copy to clipboard
# Usage: bwgen [length]
bwgen() {
  local length=${1:-20}
  local password=$(bw generate -ulns --length "$length" 2>/dev/null)
  
  if [[ $? -eq 0 && -n "$password" ]]; then
    echo -n "$password" | clipcopy
    echo "✓ Generated password (length: $length) copied to clipboard"
    echo "$password"
  else
    echo "✗ Failed to generate password"
    return 1
  fi
}


