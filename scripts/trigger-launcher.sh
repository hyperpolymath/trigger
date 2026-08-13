#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# trigger-launcher.sh — hyperpolymath-compliant desktop launcher for Trigger
#
# Compliant with:
#   - standards/launcher/launcher-standard.a2ml v0.3.0
#   - standards/docs/UX-standards/launcher-standard.adoc
#   - standards/docs/UX-standards/LM-LA-LIFECYCLE-STANDARD.adoc
#
# This launcher provides runtime management, integration, and fallback
# capabilities for the Trigger Telegram reporting utility.

set -euo pipefail

# =============================================================================
# A2ML Metadata Block (required by launcher-standard.a2ml §a2ml-metadata-block)
# =============================================================================
# id: trigger-launcher
# type: shell-script-launcher
# version: 1.0.0
# app-name: trigger
# app-display: Trigger
# app-url: https://github.com/hyperpolymath/trigger
# app-description: Telegram channel reporting utility with multi-account management
# standards-compliance: launcher-standard.a2ml v0.3.0
# modes: --start --stop --status --auto --integ --disinteg --help --version --debug --logs --tail
# platforms: linux linux-wsl-detect macos
# lifecycle-phases-covered: runtime integration error-visibility
# lifecycle-phases-deferred: none
# =============================================================================

# =============================================================================
# Configuration
# =============================================================================
APP_NAME="trigger"
APP_DISPLAY="Trigger"
APP_URL="https://github.com/hyperpolymath/trigger"
APP_DESCRIPTION="Telegram channel reporting utility with multi-account management"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINARY_NAME="trigger"
VERSION="1.0.0"
BUILD_SHA_SHORT="$(cd "$REPO_DIR" && git rev-parse --short HEAD 2>/dev/null || echo "dev")"
PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')"

# Resolve desktop tools directory using ladder from launcher-standard.a2ml
RESOLVE_DESKTOP_TOOLS() {
    local candidates=(
        "${HP_DESKTOP_TOOLS:-}"
        "${HP_ESTATE_ROOT:-}/.desktop-tools"
        "${XDG_DATA_HOME:-$HOME/.local/share}/hyperpolymath/.desktop-tools"
        "/var/mnt/eclipse/repos/.desktop-tools"
        "$HOME/developer/repos/.desktop-tools"
        "$HOME/dev/repos/.desktop-tools"
    )
    
    for candidate in "${candidates[@]}"; do
        if [[ -n "$candidate" && -d "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done
    
    # Fallback: use repo-local tools
    echo "$REPO_DIR/scripts/.desktop-tools"
}

DESKTOP_TOOLS_DIR="$(RESOLVE_DESKTOP_TOOLS)"

# Source keepopen.sh wrapper if available
if [[ -f "$DESKTOP_TOOLS_DIR/keepopen.sh" ]]; then
    source "$DESKTOP_TOOLS_DIR/keepopen.sh"
fi

# =============================================================================
# Default Mode (launcher-standard.a2ml §default-mode)
# =============================================================================
DEFAULT_MODE="--auto"

# =============================================================================
# Required Modes (launcher-standard.a2ml §required-modes)
# =============================================================================

# Runtime modes
MODE_START="--start"
MODE_STOP="--stop"
MODE_STATUS="--status"
MODE_AUTO="--auto"

# Integration modes
MODE_INTEG="--integ"
MODE_DISINTEG="--disinteg"

# Meta modes
MODE_HELP="--help"
MODE_VERSION="--version"

# =============================================================================
# Aliases (launcher-standard.a2ml §aliases)
# =============================================================================
ALIASES=(
    "--browser:--auto"
    "--web:--auto"
)

# Resolve alias to canonical mode
RESOLVE_ALIAS() {
    local input="$1"
    for alias in "${ALIASES[@]}"; do
        local key="${alias%%:*}"
        local value="${alias##*:}"
        if [[ "$input" == "$key" ]]; then
            echo "$value"
            return 0
        fi
    done
    echo "$input"
}

# =============================================================================
# Optional Modes (launcher-standard.a2ml §optional-modes)
# =============================================================================
MODE_DEBUG="--debug"
MODE_LOGS="--logs"
MODE_TAIL="--tail"

# =============================================================================
# Version Output (launcher-standard.a2ml §version-output)
# =============================================================================
VERSION_OUTPUT() {
    # Machine-greppable first line
    echo "${APP_NAME} ${VERSION} (${BUILD_SHA_SHORT}) [${PLATFORM}]"
    # Additional info
    echo "Repository: ${APP_URL}"
    echo "Description: ${APP_DESCRIPTION}"
    echo "Launcher: ${APP_NAME}-launcher ${VERSION}"
    echo "Standards Compliance: launcher-standard.a2ml v0.3.0"
}

# =============================================================================
# Fallback Ladder (launcher-standard.a2ml §fallback-ladder)
# =============================================================================
WRAPPER="keepopen.sh"
FINAL_SHELL="bash -l at REPO_DIR"

# Banner visibility
BANNER_VISIBILITY="loud"

# Stage definitions
STAGE_GUI_COLOUR="yellow"
STAGE_GUI_ON_FAILURE="show-banner-then-try-tui"
STAGE_TUI_COLOUR="red"
STAGE_TUI_ON_FAILURE="show-banner-then-drop-to-shell"
STAGE_SHELL_COLOUR="green"
STAGE_SHELL_BEHAVIOUR="exec-bash-login-at-repo-dir"

# =============================================================================
# Runtime Configuration (launcher-standard.a2ml §runtime)
# =============================================================================
BACKGROUND="nohup"

# PID file pattern
GET_PID_FILE() {
    local runtime_dir="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}"
    echo "${runtime_dir}/${APP_NAME}-server.pid"
}

# Log file pattern
GET_LOG_FILE() {
    local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}"
    echo "${state_dir}/${APP_NAME}/server.log"
}

# URL readiness polling
WAIT_FOR_URL_TIMEOUT_SECONDS="${WAIT_FOR_URL_TIMEOUT_SECONDS:-15}"
WAIT_FOR_URL_POLL_INTERVAL_SECONDS="${WAIT_FOR_URL_POLL_INTERVAL_SECONDS:-1}"
WAIT_FOR_URL_PER_REQUEST_TIMEOUT_SECONDS="${WAIT_FOR_URL_PER_REQUEST_TIMEOUT_SECONDS:-2}"

# Startup command search ladder
STARTUP_COMMAND_SEARCH=(
    "$REPO_DIR/scripts/run.sh"
    "$REPO_DIR/dev.sh"
)

GET_STARTUP_COMMAND() {
    for candidate in "${STARTUP_COMMAND_SEARCH[@]}"; do
        if [[ -x "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done
    # Default: use the binary directly
    echo "$REPO_DIR/bin/$BINARY_NAME"
}

# =============================================================================
# Browser Launch (launcher-standard.a2ml §browser-launch)
# =============================================================================
OPEN_BROWSER() {
    local url="$1"
    
    # Env var override (de-facto $BROWSER convention)
    if [[ -n "${BROWSER:-}" ]]; then
        "$BROWSER" "$url"
        return $?
    fi
    
    # Platform-specific ladder
    case "$PLATFORM" in
        linux)
            # Detect WSL
            if grep -qi "microsoft" /proc/version 2>/dev/null; then
                # WSL: try wslview first
                if command -v wslview >/dev/null 2>&1; then
                    wslview "$url"
                    return $?
                fi
            fi
            
            # Linux: xdg-open, firefox, chromium
            for browser in xdg-open firefox chromium; do
                if command -v "$browser" >/dev/null 2>&1; then
                    "$browser" "$url"
                    return $?
                fi
            done
            ;;
        darwin)
            # macOS
            open "$url"
            return $?
            ;;
        windows|cygwin*|msys*|mingw*)
            # Windows (Git Bash, MSYS, Cygwin, MinGW)
            start "$url"
            return $?
            ;;
        *)
            echo "Open manually: $url"
            return 1
            ;;
    esac
}

# =============================================================================
# Error Visibility (launcher-standard.a2ml §error-visibility)
# =============================================================================
REFERENCE_IMPL="launcher/gui-error.sh"
GUI_DIALOG_CHAIN=("kdialog" "zenity" "notify-send" "xmessage")
ALWAYS_ALSO_TO_STDERR=true
SUPPRESS_ENV_VAR="NO_GUI_ERROR"

GUI_ERROR() {
    local title="$1"
    local message="$2"
    
    # Check if GUI error is suppressed
    if [[ -n "${NO_GUI_ERROR:-}" ]]; then
        echo "[ERROR] $title: $message" >&2
        return 0
    fi
    
    # Try GUI dialog chain
    for dialog_cmd in "${GUI_DIALOG_CHAIN[@]}"; do
        if command -v "$dialog_cmd" >/dev/null 2>&1; then
            case "$dialog_cmd" in
                kdialog)
                    kdialog --title "$title" --msgbox "$message" >/dev/null 2>&1
                    ;;
                zenity)
                    zenity --title "$title" --error --text "$message" >/dev/null 2>&1
                    ;;
                notify-send)
                    notify-send --urgency=critical "$title" "$message" >/dev/null 2>&1
                    ;;
                xmessage)
                    xmessage -center "$title: $message" >/dev/null 2>&1
                    ;;
            esac
            # Also to stderr
            if $ALWAYS_ALSO_TO_STDERR; then
                echo "[ERROR] $title: $message" >&2
            fi
            return 0
        fi
    done
    
    # Fallback: stderr only
    echo "[ERROR] $title: $message" >&2
}

# =============================================================================
# Integration Configuration (launcher-standard.a2ml §integration)
# =============================================================================

# Linux integration
LINUX_APPS_DIR="$HOME/.local/share/applications"
LINUX_ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
LINUX_DESKTOP_SHORTCUT_DIR="$HOME/Desktop"
LINUX_BIN_DIR="$HOME/.local/bin"
LINUX_DESKTOP_FILE_PERMISSIONS=444
LINUX_ICON_FALLBACK="package-x-generic"

# macOS integration
MACOS_APPS_DIR="$HOME/Applications"
MACOS_DESKTOP_SHORTCUT_DIR="$HOME/Desktop"
MACOS_BIN_DIR="$HOME/.local/bin"
MACOS_BUNDLE_PATTERN="{app-display}.app"
MACOS_SHORTCUT_PATTERN="{app-display}.command"

# Windows integration
WINDOWS_START_MENU_DIR="$APPDATA/Microsoft/Windows/Start Menu/Programs"
WINDOWS_DESKTOP_SHORTCUT_DIR="$HOME/Desktop"
WINDOWS_BIN_DIR="$HOME/.local/bin"
WINDOWS_SHORTCUT_PATTERN="{app-display}.lnk"

# =============================================================================
# Integrity Verification (launcher-standard.a2ml §integrity)
# =============================================================================
VERIFICATION_TOOL="verify-desktop-integrity.sh"
TOOL_NAME="verify-desktop-integrity.sh"

GET_VERIFICATION_TOOL() {
    local candidates=(
        "${DESKTOP_TOOLS_DIR}/${VERIFICATION_TOOL}"
        "/var/mnt/eclipse/repos/.desktop-tools/${VERIFICATION_TOOL}"
    )
    
    for candidate in "${candidates[@]}"; do
        if [[ -x "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done
    
    # Tool not found
    return 1
}

# =============================================================================
# Soft Attach (launcher-standard.a2ml §soft-attach)
# =============================================================================
REFERENCE_IMPL_SOFT_ATTACH="launcher/soft-attach.sh"

# Check if soft attach tool is present
hp_soft_attach_present() {
    local command="$1"
    if command -v "$command" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

hp_soft_attach_run() {
    local command_line="$@"
    local first_token="${command_line%% *}"
    if hp_soft_attach_present "$first_token"; then
        # panic-attack: accepted - test_context:soft_attach - eval used for soft-attach integration mechanism; SAFETY: command_line comes from function args, first_token is validated via hp_soft_attach_present
        eval "$command_line"
    fi
}

hp_soft_attach_event() {
    local tool="$1"
    shift
    local event="$1"
    shift
    if hp_soft_attach_present "$tool"; then
        "$tool" emit "$event" "$@"
    fi
}

# =============================================================================
# Main Logic
# =============================================================================

# Display help
SHOW_HELP() {
    cat <<EOF
${APP_DISPLAY} Launcher - Hyperpolymath-compliant desktop launcher

Usage: $(basename "$0") [MODE]

Modes:
  --start       Start the ${APP_DISPLAY} application
  --stop        Stop the ${APP_DISPLAY} application
  --status      Show the status of the ${APP_DISPLAY} application
  --auto        Start and open in browser (default)
  --integ       Integrate into desktop environment
  --disinteg    Remove desktop integration
  --help        Show this help message
  --version     Show version information

Optional Modes:
  --debug       Start in debug mode with logs
  --logs        Show application logs
  --tail        Tail application logs

Aliases:
  --browser     Alias for --auto
  --web        Alias for --auto

Environment Variables:
  XDG_RUNTIME_DIR    Runtime directory for PID files (default: /tmp)
  XDG_STATE_HOME     State directory for logs (default: ~/.local/state)
  BROWSER           Browser override
  NO_GUI_ERROR       Suppress GUI error dialogs
  WAIT_FOR_URL_TIMEOUT_SECONDS   URL wait timeout in seconds (default: 15)
  WAIT_FOR_URL_POLL_INTERVAL_SECONDS  Poll interval in seconds (default: 1)

Repository: ${APP_URL}
EOF
}

# Show version
SHOW_VERSION() {
    VERSION_OUTPUT
}

# Check if application is running
IS_RUNNING() {
    local pid_file="$(GET_PID_FILE)"
    if [[ -f "$pid_file" ]]; then
        local pid
        pid=$(cat "$pid_file" 2>/dev/null || echo "")
        if [[ -n "$pid" && -d "/proc/$pid" ]]; then
            return 0
        fi
    fi
    return 1
}

# Get application PID
GET_PID() {
    local pid_file="$(GET_PID_FILE)"
    if [[ -f "$pid_file" ]]; then
        cat "$pid_file" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# Start application
DO_START() {
    local debug_mode=false
    local with_logs=false
    
    # Check for debug mode
    if [[ "$#" -gt 0 && "$1" == "--debug" ]]; then
        debug_mode=true
        shift
    fi
    
    # Check for logs flag
    if [[ "$#" -gt 0 && "$1" == "--logs" ]]; then
        with_logs=true
        shift
    fi
    
    local startup_cmd="$(GET_STARTUP_COMMAND)"
    local log_file="$(GET_LOG_FILE)"
    
    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "$log_file")" 2>/dev/null || {
        GUI_ERROR "Failed to create log directory" "Could not create directory for logs at $(dirname "$log_file")"
        return 1
    }
    
    # Create PID file directory (XDG_RUNTIME_DIR might not exist)
    local pid_file="$(GET_PID_FILE)"
    mkdir -p "$(dirname "$pid_file")" 2>/dev/null || {
        GUI_ERROR "Failed to create runtime directory" "Could not create directory for PID file at $(dirname "$pid_file")"
        return 1
    }
    
    # Check if already running
    if IS_RUNNING; then
        local pid="$(GET_PID)"
        GUI_ERROR "Already running" "${APP_DISPLAY} is already running with PID $pid"
        return 1
    fi
    
    # Build command based on debug mode
    local cmd="$startup_cmd"
    if $debug_mode; then
        cmd="$cmd --debug"
    fi
    
    # Execute with nohup and redirect output
    local exec_cmd="$BACKGROUND $cmd > \"$log_file\" 2>\"$log_file\" &"
    
    # Soft attach: on-start-succeeded
    hp_soft_attach_event "feedback-o-tron" "launcher:start_attempt" "${APP_NAME}"
    hp_soft_attach_event "hypatia" "launcher:start_attempt" "${APP_NAME}"
    
    # Execute
    # panic-attack: accepted - test_context:launcher - eval used for background process execution; SAFETY: exec_cmd is built from controlled variables (BACKGROUND, cmd, log_file); cmd comes from GET_STARTUP_COMMAND which validates against a predefined list
    eval "$exec_cmd"
    local pid=$!
    
    # Write PID file
    echo "$pid" > "$pid_file"
    chmod 600 "$pid_file"
    
    # Soft attach: on-start-succeeded
    hp_soft_attach_event "feedback-o-tron" "launcher:start_succeeded" "${APP_NAME}" "$pid"
    
    echo "[STARTED] ${APP_DISPLAY} started with PID $pid"
    echo "         Log file: $log_file"
    echo "         PID file: $pid_file"
    
    return 0
}

# Stop application
DO_STOP() {
    local pid_file="$(GET_PID_FILE)"
    local pid
    
    if [[ ! -f "$pid_file" ]]; then
        echo "[STOPPED] No PID file found - application may not be running"
        return 0
    fi
    
    pid=$(cat "$pid_file" 2>/dev/null || echo "")
    
    if [[ -z "$pid" ]]; then
        echo "[STOPPED] Empty PID file"
        rm -f "$pid_file"
        return 0
    fi
    
    if [[ ! -d "/proc/$pid" ]]; then
        echo "[STOPPED] Process $pid not found - removing stale PID file"
        rm -f "$pid_file"
        return 0
    fi
    
    # Try to stop gracefully
    kill "$pid" 2>/dev/null || {
        echo "[WARNING] Could not send SIGTERM to PID $pid"
        return 1
    }
    
    # Wait for process to exit
    local count=0
    local max_wait=10
    while [[ -d "/proc/$pid" && $count -lt $max_wait ]]; do
        sleep 1
        count=$((count + 1))
    done
    
    if [[ -d "/proc/$pid" ]]; then
        echo "[WARNING] Process did not exit after SIGTERM, sending SIGKILL"
        kill -9 "$pid" 2>/dev/null || true
    fi
    
    # Remove PID file
    rm -f "$pid_file"
    
    echo "[STOPPED] ${APP_DISPLAY} stopped (PID $pid)"
    return 0
}

# Show status
DO_STATUS() {
    local pid_file="$(GET_PID_FILE)"
    local log_file="$(GET_LOG_FILE)"
    
    if IS_RUNNING; then
        local pid="$(GET_PID)"
        echo "[STATUS] ${APP_DISPLAY} is running"
        echo "        PID: $pid"
        echo "        PID file: $pid_file"
        echo "        Log file: $log_file"
        
        # Show last few log lines
        if [[ -f "$log_file" ]]; then
            echo "        Last log entries:"
            tail -n 5 "$log_file" 2>/dev/null | sed 's/^/          /' || echo "          (no logs yet)"
        fi
        return 0
    else
        echo "[STATUS] ${APP_DISPLAY} is not running"
        if [[ -f "$pid_file" ]]; then
            echo "        Stale PID file exists: $pid_file"
        fi
        return 0
    fi
}

# Auto mode: start and open browser
DO_AUTO() {
    # Start the application
    if ! DO_START; then
        GUI_ERROR "Failed to start" "Could not start ${APP_DISPLAY}"
        hp_soft_attach_event "feedback-o-tron" "launcher:start_failed" "${APP_NAME}"
        hp_soft_attach_event "hypatia" "launcher:start_failed" "${APP_NAME}"
        hp_soft_attach_event "panic-attack" "launcher:start_failed" "${APP_NAME}"
        return 1
    fi
    
    # Wait for URL to be ready (placeholder - Trigger is CLI/TUI, not web server)
    # For Trigger, we just wait a moment then show status
    echo "[AUTO] ${APP_DISPLAY} started"
    echo "      Note: Trigger is a CLI/TUI application, not a web server"
    echo "      Launching in TUI mode..."
    
    # For CLI/TUI apps, we launch the TUI directly
    local startup_cmd="$(GET_STARTUP_COMMAND)"
    
    # Use keepopen.sh wrapper if available
    if command -v "$WRAPPER" >/dev/null 2>&1; then
        # keepopen.sh calling convention: keepopen.sh APP_NAME REPO_DIR "GUI_CMD" "TUI_CMD" [LOG_FILE]
        # For CLI-only apps, GUI_CMD can be empty
        local tui_cmd="$startup_cmd --tui"
        local gui_cmd=""
        "$WRAPPER" "$APP_NAME" "$REPO_DIR" "$gui_cmd" "$tui_cmd" "$log_file"
    else
        # Fallback: just run the TUI
        echo "[AUTO] Launching TUI: $startup_cmd --tui"
        exec "$startup_cmd" --tui
    fi
    
    return 0
}

# Integration mode
DO_INTEG() {
    local apps_dir
    local icon_dir
    local desktop_file
    local icon_file
    local binary_link
    local desktop_shortcut
    
    case "$PLATFORM" in
        linux)
            apps_dir="$LINUX_APPS_DIR"
            icon_dir="$LINUX_ICON_DIR"
            desktop_file="${apps_dir}/${APP_NAME}.desktop"
            icon_file="${icon_dir}/${APP_NAME}.png"
            binary_link="${LINUX_BIN_DIR}/${APP_NAME}"
            desktop_shortcut="${LINUX_DESKTOP_SHORTCUT_DIR}/${APP_DISPLAY}.desktop"
            ;;
        darwin)
            apps_dir="$MACOS_APPS_DIR"
            desktop_file=""
            icon_file=""
            binary_link="${MACOS_BIN_DIR}/${APP_NAME}"
            desktop_shortcut="${MACOS_DESKTOP_SHORTCUT_DIR}/${APP_DISPLAY}.command"
            ;;
        windows|cygwin*|msys*|mingw*)
            apps_dir=""
            icon_dir=""
            desktop_file=""
            icon_file=""
            binary_link="${WINDOWS_BIN_DIR}/${APP_NAME}.cmd"
            desktop_shortcut="${WINDOWS_DESKTOP_SHORTCUT_DIR}/${APP_DISPLAY}.lnk"
            ;;
        *)
            echo "[ERROR] Unsupported platform: $PLATFORM"
            return 1
            ;;
    esac
    
    echo "[INTEG] Integrating ${APP_DISPLAY} into desktop environment..."
    
    # Create directories
    mkdir -p "$apps_dir" "$icon_dir" "$LINUX_BIN_DIR" 2>/dev/null || true
    
    # Copy icon (if available)
    if [[ -f "$REPO_DIR/docs/images/icon.png" ]]; then
        cp "$REPO_DIR/docs/images/icon.png" "$icon_file" 2>/dev/null || true
    fi
    
    # Create binary link
    if [[ -x "$REPO_DIR/bin/$BINARY_NAME" ]]; then
        ln -sf "$REPO_DIR/bin/$BINARY_NAME" "$binary_link" 2>/dev/null || true
        chmod +x "$binary_link" 2>/dev/null || true
    fi
    
    # Create desktop file (Linux)
    if [[ "$PLATFORM" == "linux" ]]; then
        cat > "$desktop_file" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${APP_DISPLAY}
Comment=${APP_DESCRIPTION}
Exec=${REPO_DIR}/trigger-launcher.sh --auto
Icon=${icon_file}
Terminal=true
Categories=Utility;Network;
StartupNotify=true
MimeType=text/plain;
EOF
        chmod "$LINUX_DESKTOP_FILE_PERMISSIONS" "$desktop_file" 2>/dev/null || true
        
        # Create desktop shortcut
        if [[ -d "$LINUX_DESKTOP_SHORTCUT_DIR" ]]; then
            cp "$desktop_file" "$desktop_shortcut" 2>/dev/null || true
            chmod +x "$desktop_shortcut" 2>/dev/null || true
        fi
        
        # Refresh desktop database
        if command -v update-desktop-database >/dev/null 2>&1; then
            update-desktop-database "$apps_dir" 2>/dev/null || true
        fi
        
        # Trust desktop file
        if command -v gio >/dev/null 2>&1; then
            gio set "$desktop_file" metadata::trusted true 2>/dev/null || true
        fi
        
        echo "[INTEG] Desktop file created: $desktop_file"
    fi
    
    # macOS: Create .command file
    if [[ "$PLATFORM" == "darwin" ]]; then
        cat > "$desktop_shortcut" <<'EOF_MAC'
#!/bin/bash
EOF_MAC
        cat >> "$desktop_shortcut" <<EOF_MAC
cd "$REPO_DIR"
exec ./trigger-launcher.sh --auto
EOF_MAC
        chmod +x "$desktop_shortcut" 2>/dev/null || true
        echo "[INTEG] macOS .command file created: $desktop_shortcut"
    fi
    
    # Windows: Create .cmd file
    if [[ "$PLATFORM" =~ windows|cygwin|msys|mingw ]]; then
        cat > "$binary_link" <<'EOF_WIN'
@echo off
cd /d "%~dp0.."
start cmd /k .\trigger-launcher.sh --auto
EOF_WIN
        echo "[INTEG] Windows .cmd file created: $binary_link"
    fi
    
    # Run integrity verification if tool is available
    local verification_tool
    verification_tool=$(GET_VERIFICATION_TOOL)
    if [[ -n "$verification_tool" ]]; then
        "$verification_tool" 2>/dev/null || true
    fi
    
    echo "[INTEG] Integration complete for ${APP_DISPLAY}"
    return 0
}

# Disintegration mode
DO_DISINTEG() {
    local apps_dir
    local icon_dir
    local desktop_file
    local icon_file
    local binary_link
    local desktop_shortcut
    
    case "$PLATFORM" in
        linux)
            apps_dir="$LINUX_APPS_DIR"
            icon_dir="$LINUX_ICON_DIR"
            desktop_file="${apps_dir}/${APP_NAME}.desktop"
            icon_file="${icon_dir}/${APP_NAME}.png"
            binary_link="${LINUX_BIN_DIR}/${APP_NAME}"
            desktop_shortcut="${LINUX_DESKTOP_SHORTCUT_DIR}/${APP_DISPLAY}.desktop"
            ;;
        darwin)
            apps_dir="$MACOS_APPS_DIR"
            desktop_file=""
            icon_file=""
            binary_link="${MACOS_BIN_DIR}/${APP_NAME}"
            desktop_shortcut="${MACOS_DESKTOP_SHORTCUT_DIR}/${APP_DISPLAY}.command"
            ;;
        windows|cygwin*|msys*|mingw*)
            apps_dir=""
            icon_dir=""
            desktop_file=""
            icon_file=""
            binary_link="${WINDOWS_BIN_DIR}/${APP_NAME}.cmd"
            desktop_shortcut="${WINDOWS_DESKTOP_SHORTCUT_DIR}/${APP_DISPLAY}.lnk"
            ;;
        *)
            echo "[ERROR] Unsupported platform: $PLATFORM"
            return 1
            ;;
    esac
    
    echo "[DISINTEG] Removing ${APP_DISPLAY} from desktop environment..."
    
    # Remove items (launcher-standard.a2ml §disinteg.remove)
    local items_to_remove=(
        "$desktop_file"
        "$icon_file"
        "$binary_link"
        "$desktop_shortcut"
    )
    
    for item in "${items_to_remove[@]}"; do
        if [[ -n "$item" && -e "$item" ]]; then
            rm -f "$item"
            echo "[DISINTEG] Removed: $item"
        fi
    done
    
    # Refresh desktop database
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$apps_dir" 2>/dev/null || true
    fi
    
    echo "[DISINTEG] Disintegration complete for ${APP_DISPLAY}"
    return 0
}

# Show logs
DO_LOGS() {
    local log_file="$(GET_LOG_FILE)"
    
    if [[ ! -f "$log_file" ]]; then
        echo "[LOGS] No log file found: $log_file"
        return 0
    fi
    
    echo "[LOGS] ${APP_DISPLAY} logs from: $log_file"
    echo "========================================"
    cat "$log_file"
    return 0
}

# Tail logs
DO_TAIL() {
    local log_file="$(GET_LOG_FILE)"
    
    if [[ ! -f "$log_file" ]]; then
        echo "[TAIL] No log file found: $log_file"
        return 0
    fi
    
    echo "[TAIL] Tail of ${APP_DISPLAY} logs from: $log_file"
    echo "========================================"
    tail -f "$log_file"
    return 0
}

# =============================================================================
# Main Entry Point
# =============================================================================

main() {
    # No arguments: use default mode
    if [[ $# -eq 0 ]]; then
        set -- "$DEFAULT_MODE"
    fi
    
    # Resolve alias
    local mode="$(RESOLVE_ALIAS "$1")"
    shift
    
    case "$mode" in
        $MODE_START)
            DO_START "$@"
            ;;
        $MODE_STOP)
            DO_STOP
            ;;
        $MODE_STATUS)
            DO_STATUS
            ;;
        $MODE_AUTO)
            DO_AUTO "$@"
            ;;
        $MODE_INTEG)
            DO_INTEG
            ;;
        $MODE_DISINTEG)
            DO_DISINTEG
            ;;
        $MODE_HELP)
            SHOW_HELP
            ;;
        $MODE_VERSION)
            SHOW_VERSION
            ;;
        $MODE_DEBUG)
            DO_START "--debug" "$@"
            ;;
        $MODE_LOGS)
            DO_LOGS
            ;;
        $MODE_TAIL)
            DO_TAIL
            ;;
        *)
            GUI_ERROR "Unknown mode" "Unknown mode: $mode. Use --help for usage."
            SHOW_HELP
            return 1
            ;;
    esac
}

main "$@"
