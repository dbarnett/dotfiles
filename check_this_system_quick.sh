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
    printf "%bℹ️  No diagnostics implemented for macOS yet%b\n" "${BLUE}" "${NC}"
    printf "\n"
    exit 0

else
    printf "%b⚠️  Unknown OS: %s%b\n" "${YELLOW}" "$OS" "${NC}"
    printf "%bℹ️  No diagnostics implemented for this platform%b\n" "${BLUE}" "${NC}"
    printf "\n"
    exit 0
fi
