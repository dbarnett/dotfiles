#!/bin/sh
# Quick diagnostic script to check system configuration
# Usage: ./check_this_system_quick.sh

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect OS
OS=$(uname -s)

printf "%b🔍 Quick System Diagnostic%b\n" "${BLUE}" "${NC}"
printf "%s\n" "================================"
printf "\n"

if [ "$OS" = "Linux" ]; then
    ERRORS=0

    # Check notification daemon state
    printf "%b📬 Notification Daemon Check%b\n" "${BLUE}" "${NC}"
    printf "%s\n" "--------------------------------"

    if pgrep -x dunst >/dev/null 2>&1; then
        DUNST_RUNNING=1
    else
        DUNST_RUNNING=0
    fi

    if pgrep -x swaync >/dev/null 2>&1; then
        SWAYNC_RUNNING=1
    else
        SWAYNC_RUNNING=0
    fi

    if [ "$DUNST_RUNNING" -eq 1 ] && [ "$SWAYNC_RUNNING" -eq 1 ]; then
        printf "%b❌ CONFLICT: Both dunst and swaync are running!%b\n" "${RED}" "${NC}"
        printf "   %bFix this by running:%b\n" "${YELLOW}" "${NC}"
        printf "   %bpkill dunst && swaync-client --reload-config%b\n" "${GREEN}" "${NC}"
        ERRORS=$((ERRORS + 1))
    elif [ "$DUNST_RUNNING" -eq 1 ]; then
        printf "%b❌ WRONG: dunst is running (should be swaync)%b\n" "${RED}" "${NC}"
        printf "   %bFix this by running:%b\n" "${YELLOW}" "${NC}"
        printf "   %bpkill dunst && swaync &%b\n" "${GREEN}" "${NC}"
        ERRORS=$((ERRORS + 1))
    elif [ "$SWAYNC_RUNNING" -eq 1 ]; then
        printf "%b✅ OK: swaync is running%b\n" "${GREEN}" "${NC}"
    else
        printf "%b⚠️  WARNING: No notification daemon running%b\n" "${YELLOW}" "${NC}"
        printf "   %bStart swaync by running:%b\n" "${YELLOW}" "${NC}"
        printf "   %bswaync &%b\n" "${GREEN}" "${NC}"
        ERRORS=$((ERRORS + 1))
    fi
    printf "\n"

    # Check Hyprland config if running Hyprland
    if pgrep -x Hyprland >/dev/null 2>&1; then
        printf "%b🪟 Hyprland Config Check%b\n" "${BLUE}" "${NC}"
        printf "%s\n" "--------------------------------"

        CONFIG_ERRORS=$(hyprctl configerrors 2>&1)
        if [ $? -ne 0 ]; then
            printf "%b❌ ERROR: Failed to check hyprctl configerrors%b\n" "${RED}" "${NC}"
            ERRORS=$((ERRORS + 1))
        elif [ -n "$CONFIG_ERRORS" ]; then
            printf "%b❌ Config errors found:%b\n" "${RED}" "${NC}"
            printf "%s\n" "$CONFIG_ERRORS"
            printf "   %bFix errors in your Hyprland config files%b\n" "${YELLOW}" "${NC}"
            ERRORS=$((ERRORS + 1))
        else
            printf "%b✅ OK: No config errors%b\n" "${GREEN}" "${NC}"
        fi
        printf "\n"
    fi

    if [ "$ERRORS" -gt 0 ]; then
        printf "%b❌ %d error(s) found%b\n" "${RED}" "$ERRORS" "${NC}"
        exit 1
    else
        printf "%b✨ All checks passed!%b\n" "${GREEN}" "${NC}"
        exit 0
    fi

elif [ "$OS" = "Darwin" ]; then
    ERRORS=0
    WARNINGS=0

    # Check shell environment setup
    printf "%b🐚 Fish Shell Check (CRITICAL - your default shell)%b\n" "${BLUE}" "${NC}"
    printf "%s\n" "--------------------------------"

    # Essential paths that should be in PATH
    REQUIRED_PATHS="/opt/homebrew/bin /usr/local/bin /usr/bin"
    
    # Minimal PATH needed to find shell executables (but NOT inherited into the shell's config)
    # This simulates what macOS login provides before shell config runs
    MINIMAL_PATH="/usr/bin:/bin:/usr/sbin:/sbin"
    
    # Test fish shell in COMPLETELY ISOLATED environment (no inherited env vars)
    # This simulates what Cursor embedded terminals see - a fresh shell session
    printf "%bTesting fish (isolated - simulates Cursor terminals)...%b\n" "${BLUE}" "${NC}"
    FISH_PATH=$(env -i HOME="$HOME" USER="$USER" PATH="$MINIMAL_PATH" /opt/homebrew/bin/fish -i -c 'echo $PATH' 2>/dev/null)
    FISH_EXIT=$?
    
    if [ $FISH_EXIT -ne 0 ]; then
        printf "%b❌ ERROR: fish shell failed to start in clean environment%b\n" "${RED}" "${NC}"
        printf "   %bThis means Cursor terminals will also fail!%b\n" "${YELLOW}" "${NC}"
        ERRORS=$((ERRORS + 1))
    else
        MISSING_PATHS=""
        for required_path in $REQUIRED_PATHS; do
            if ! echo "$FISH_PATH" | tr ' ' '\n' | grep -q "^${required_path}$"; then
                MISSING_PATHS="$MISSING_PATHS $required_path"
            fi
        done
        
        if [ -n "$MISSING_PATHS" ]; then
            printf "%b❌ CRITICAL ERROR: fish shell missing essential paths:%b\n" "${RED}" "${NC}"
            printf "   Missing:%b\n" "$MISSING_PATHS"
            printf "   %b⚠️  This breaks Cursor embedded terminals and other tools!%b\n" "${YELLOW}" "${NC}"
            printf "   %bCheck ~/.config/fish/config.fish%b\n" "${YELLOW}" "${NC}"
            printf "   %bEnsure: type -q /opt/homebrew/bin/brew; and /opt/homebrew/bin/brew shellenv | source%b\n" "${YELLOW}" "${NC}"
            printf "   %b        is UNCOMMENTED and runs for interactive shells%b\n" "${YELLOW}" "${NC}"
            ERRORS=$((ERRORS + 1))
        else
            printf "%b✅ OK: fish has all essential paths%b\n" "${GREEN}" "${NC}"
        fi
    fi

    # Test essential tool availability in fish (isolated)
    printf "%bTesting essential tools in fish (isolated)...%b\n" "${BLUE}" "${NC}"
    ESSENTIAL_TOOLS="brew git node"
    MISSING_TOOLS=""
    
    for tool in $ESSENTIAL_TOOLS; do
        if ! env -i HOME="$HOME" USER="$USER" PATH="$MINIMAL_PATH" /opt/homebrew/bin/fish -i -c "type -q $tool" 2>/dev/null; then
            MISSING_TOOLS="$MISSING_TOOLS $tool"
        fi
    done
    
    if [ -n "$MISSING_TOOLS" ]; then
        printf "%b⚠️  WARNING: Some tools not accessible in fish:%b\n" "${YELLOW}" "${NC}"
        printf "   Missing:%b\n" "$MISSING_TOOLS"
        WARNINGS=$((WARNINGS + 1))
    else
        printf "%b✅ OK: All essential tools accessible%b\n" "${GREEN}" "${NC}"
    fi

    printf "\n"
    
    # Bash check is informational only (not critical since fish is the default)
    printf "%b🐚 Bash Shell Check (informational)%b\n" "${BLUE}" "${NC}"
    printf "%s\n" "--------------------------------"
    printf "%bTesting bash (isolated)...%b\n" "${BLUE}" "${NC}"
    BASH_PATH=$(env -i HOME="$HOME" USER="$USER" PATH="$MINIMAL_PATH" /bin/bash -i -c 'echo $PATH' 2>/dev/null)
    BASH_EXIT=$?
    
    if [ $BASH_EXIT -ne 0 ]; then
        printf "%b⚠️  WARNING: bash shell failed to start%b\n" "${YELLOW}" "${NC}"
        WARNINGS=$((WARNINGS + 1))
    else
        MISSING_PATHS=""
        for required_path in $REQUIRED_PATHS; do
            if ! echo "$BASH_PATH" | tr ':' '\n' | grep -q "^${required_path}$"; then
                MISSING_PATHS="$MISSING_PATHS $required_path"
            fi
        done
        
        if [ -n "$MISSING_PATHS" ]; then
            printf "%b⚠️  WARNING: bash shell missing paths:%b\n" "${YELLOW}" "${NC}"
            printf "   Missing:%b (check ~/.bashrc and ~/.profile)\n" "$MISSING_PATHS"
            WARNINGS=$((WARNINGS + 1))
        else
            printf "%b✅ OK: bash has all essential paths%b\n" "${GREEN}" "${NC}"
        fi
    fi

    printf "\n"

    # Check direnv functionality
    printf "%b🔧 Direnv Health Check%b\n" "${BLUE}" "${NC}"
    printf "%s\n" "--------------------------------"
    
    if command -v direnv >/dev/null 2>&1; then
        # Check direnv version
        DIRENV_VERSION=$(direnv version 2>&1)
        printf "%bDirectenv version: %s%b\n" "${BLUE}" "$DIRENV_VERSION" "${NC}"
        
        # Create a test .envrc in a temp directory
        TEST_DIR=$(mktemp -d)
        cat > "$TEST_DIR/.envrc" << 'EOF'
export TEST_VAR="test_value"
EOF
        
        # Test direnv allow and load
        cd "$TEST_DIR" || exit 1
        if timeout 3 direnv allow >/dev/null 2>&1; then
            printf "%b✅ OK: direnv allow works (no hang)%b\n" "${GREEN}" "${NC}"
            
            # Test if it loads
            if timeout 3 bash -c 'eval "$(direnv export bash 2>/dev/null)" && [ "$TEST_VAR" = "test_value" ]' 2>/dev/null; then
                printf "%b✅ OK: direnv load works%b\n" "${GREEN}" "${NC}"
            else
                printf "%b⚠️  WARNING: direnv allow works but load might have issues%b\n" "${YELLOW}" "${NC}"
                WARNINGS=$((WARNINGS + 1))
            fi
        else
            printf "%b❌ ERROR: direnv allow hangs or times out%b\n" "${RED}" "${NC}"
            printf "   %bThis indicates a bash/direnv configuration issue%b\n" "${YELLOW}" "${NC}"
            ERRORS=$((ERRORS + 1))
        fi
        
        # Cleanup
        cd - >/dev/null || exit 1
        rm -rf "$TEST_DIR"
    else
        printf "%b⚠️  WARNING: direnv not installed%b\n" "${YELLOW}" "${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi

    printf "\n"

    if [ "$ERRORS" -gt 0 ]; then
        printf "%b❌ %d error(s) and %d warning(s) found%b\n" "${RED}" "$ERRORS" "$WARNINGS" "${NC}"
        exit 1
    elif [ "$WARNINGS" -gt 0 ]; then
        printf "%b⚠️  %d warning(s) found (no critical errors)%b\n" "${YELLOW}" "$WARNINGS" "${NC}"
        exit 0
    else
        printf "%b✨ All checks passed!%b\n" "${GREEN}" "${NC}"
        exit 0
    fi

else
    printf "%b⚠️  Unknown OS: %s%b\n" "${YELLOW}" "$OS" "${NC}"
    printf "%bℹ️  No diagnostics implemented for this platform%b\n" "${BLUE}" "${NC}"
    printf "\n"
    exit 0
fi
