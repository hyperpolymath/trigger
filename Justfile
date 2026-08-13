# Trigger - Justfile with comprehensive recipes
# 
# Author: hyperpolymath
# 
# Just is a modern make alternative: https://github.com/casey/just
# 
# Usage:
#   just              # Show available recipes
#   just build         # Build the project
#   just run          # Run the application (TUI mode)
#   just test         # Run tests
#   just clean        # Clean build artifacts
#   just diagnose     # Run self-diagnostics
#   just self-heal    # Attempt self-healing
#   just install      # Install the application
#   just uninstall    # Uninstall the application

# Project metadata
PROJECT_NAME := "trigger"
PROJECT_VERSION := "1.0.0"
BINARY_NAME := "trigger"
INSTALL_PREFIX := if os() == "windows" { "C:\\Program Files\\" + PROJECT_NAME } else { "/usr/local" }
INSTALL_BIN := INSTALL_PREFIX + "/bin"
INSTALL_MAN := INSTALL_PREFIX + "/share/man/man1"

# Ada/SPARK settings
ADA_COMPILER := "gprbuild"
ADA_PROJECT := "trigger.gpr"
ADA_FLAGS := ""

# Zig settings
ZIG_COMPILER := "zig"
ZIG_BUILD := "build.zig"

# Idris2 settings
IDRIS2_COMPILER := "idris2"

# Source directories
SRC_DIR := "src"
FFI_DIR := "ffi"
TESTS_DIR := "tests"
BUILD_DIR := "obj"
BIN_DIR := "bin"

# =============================================================================
# Default Recipe: Show help
# =============================================================================
default:
    @just --list

# =============================================================================
# Build Recipes
# =============================================================================

# Build the project
build:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "[BUILD] Building Trigger..."
    
    # Create build directory
    mkdir -p {{BUILD_DIR}}
    mkdir -p {{BIN_DIR}}
    
    # Build with GNAT
    if command -v {{ADA_COMPILER}} >/dev/null 2>&1; then
        echo "[BUILD] Compiling with GNAT..."
        {{ADA_COMPILER}} -P {{ADA_PROJECT}} -XLIBRARY_TYPE=static {{ADA_FLAGS}}
        echo "[BUILD] GNAT compilation complete"
    else
        echo "[ERROR] GNAT compiler not found"
        exit 1
    fi
    
    # Build Zig FFI
    if command -v {{ZIG_COMPILER}} >/dev/null 2>&1; then
        echo "[BUILD] Compiling Zig FFI..."
        cd {{FFI_DIR}}/zig && {{ZIG_COMPILER}} build-lib -dynamic telegram.zig
        cd ../../
        echo "[BUILD] Zig compilation complete"
    else
        echo "[WARNING] Zig compiler not found, FFI will be limited"
    fi
    
    # Build Idris2 API (optional)
    if command -v {{IDRIS2_COMPILER}} >/dev/null 2>&1; then
        echo "[BUILD] Compiling Idris2 API..."
        cd {{FFI_DIR}}/idris2 && {{IDRIS2_COMPILER}} --build TelegramAPI.ipkg
        cd ../../
        echo "[BUILD] Idris2 compilation complete"
    else
        echo "[WARNING] Idris2 compiler not found, API layer will be limited"
    fi
    
    echo "[BUILD] Build complete!"
    echo "[BUILD] Binary: {{BIN_DIR}}/{{BINARY_NAME}}"

# Rebuild the project
rebuild: clean build

# Build in debug mode
debug:
    #!/usr/bin/env bash
    set -euo pipefail
    ADA_FLAGS="-g -O0" just build

# Build in release mode
release:
    #!/usr/bin/env bash
    set -euo pipefail
    ADA_FLAGS="-O3 -gnatn" just build

# =============================================================================
# Run Recipes
# =============================================================================

# Run the application (TUI mode)
run:
    #!/usr/bin/env bash
    set -euo pipefail
    
    # Check if built
    if [ -f "{{BIN_DIR}}/{{BINARY_NAME}}" ]; then
        {{BIN_DIR}}/{{BINARY_NAME}}
    elif [ -f "{{BINARY_NAME}}" ]; then
        ./{{BINARY_NAME}}
    else
        echo "[ERROR] Binary not found. Run 'just build' first."
        exit 1
    fi

# Run with specific arguments
run-cli *args:
    #!/usr/bin/env bash
    set -euo pipefail
    
    if [ -f "{{BIN_DIR}}/{{BINARY_NAME}}" ]; then
        {{BIN_DIR}}/{{BINARY_NAME}} "{{args}}"
    elif [ -f "{{BINARY_NAME}}" ]; then
        ./{{BINARY_NAME}} "{{args}}"
    else
        echo "[ERROR] Binary not found. Run 'just build' first."
        exit 1
    fi

# Run with help
help:
    just run-cli --help

# Run with man page
man:
    just run-cli --man

# Run with version
version:
    just run-cli --version

# Run diagnostics
diagnose:
    just run-cli --diagnose

# Run self-healing
self-heal:
    just run-cli --self-heal

# =============================================================================
# Test Recipes
# =============================================================================

test:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "[TEST] Running tests..."
    
    # Ensure built
    if [ ! -f "{{BIN_DIR}}/{{BINARY_NAME}}" ]; then
        just build
    fi
    
    # Run test binary if it exists
    if [ -f "{{BIN_DIR}}/test_trigger" ]; then
        {{BIN_DIR}}/test_trigger
    elif [ -f "tests/test_trigger.adb" ]; then
        echo "[TEST] Compiling tests..."
        gprbuild -P trigger.gpr tests/test_trigger.adb
        echo "[TEST] Running tests..."
        {{BIN_DIR}}/test_trigger
    else
        echo "[WARNING] No tests found"
    fi
    
    echo "[TEST] Tests complete"

# Run tests with coverage
test-coverage:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "[TEST] Running tests with coverage..."
    
    # Requires gnatcov
    if ! command -v gnatcov >/dev/null 2>&1; then
        echo "[ERROR] gnatcov not found"
        exit 1
    fi
    
    # Build with coverage instrumentation
    gprbuild -P trigger.gpr -f -gnatg
    
    # Run tests
    if [ -f "{{BIN_DIR}}/test_trigger" ]; then
        {{BIN_DIR}}/test_trigger
    fi
    
    # Generate coverage report
    gnatcov *.ali
    
    echo "[TEST] Coverage report generated"

# =============================================================================
# Clean Recipes
# =============================================================================

# Clean build artifacts
clean:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "[CLEAN] Cleaning build artifacts..."
    
    # Remove build directories
    rm -rf {{BUILD_DIR}}
    rm -rf {{BIN_DIR}}
    
    # Remove object files
    find . -name "*.o" -delete
    find . -name "*.ali" -delete
    find . -name "*.a" -delete
    
    # Remove test files
    rm -f test_*.adb test_*.ads
    
    # Remove temporary files
    rm -f *.tmp *.swp *~ .TMP
    
    # Remove session files (with confirmation if interactive)
    if [ -t 1 ]; then
        read -p "[CLEAN] Remove session directory? (y/N): " ans
        if [ "$ans" = "y" ] || [ "$ans" = "Y" ]; then
            rm -rf sessions/
        fi
    fi
    
    echo "[CLEAN] Clean complete"

# Deep clean (removes everything including config)
deep-clean: clean
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "[CLEAN] Deep cleaning..."
    
    # Remove config files
    rm -f config.json *.log
    
    # Remove .alire and .alr if they exist
    rm -rf .alire .alr
    
    echo "[CLEAN] Deep clean complete"

# =============================================================================
# Install/Uninstall Recipes
# =============================================================================

# Install the application
install:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "[INSTALL] Installing Trigger..."
    
    # Build first
    just build
    
    # Create install directories
    echo "[INSTALL] Creating directories..."
    mkdir -p "{{INSTALL_BIN}}"
    mkdir -p "{{INSTALL_MAN}}"
    
    # Install binary
    echo "[INSTALL] Installing binary..."
    if [ -f "{{BIN_DIR}}/{{BINARY_NAME}}" ]; then
        cp "{{BIN_DIR}}/{{BINARY_NAME}}" "{{INSTALL_BIN}}/{{BINARY_NAME}}"
    elif [ -f "{{BINARY_NAME}}" ]; then
        cp "{{BINARY_NAME}}" "{{INSTALL_BIN}}/{{BINARY_NAME}}"
    else
        echo "[ERROR] Binary not found"
        exit 1
    fi
    
    # Install man page
    if [ -f "docs/trigger.1" ]; then
        echo "[INSTALL] Installing man page..."
        cp "docs/trigger.1" "{{INSTALL_MAN}}/trigger.1"
        gzip "{{INSTALL_MAN}}/trigger.1"
    fi
    
    # Set permissions
    chmod +x "{{INSTALL_BIN}}/{{BINARY_NAME}}"
    
    echo "[INSTALL] Installation complete!"
    echo "[INSTALL] Trigger installed to: {{INSTALL_BIN}}/{{BINARY_NAME}}"

# Uninstall the application
uninstall:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "[UNINSTALL] Uninstalling Trigger..."
    
    # Remove binary
    if [ -f "{{INSTALL_BIN}}/{{BINARY_NAME}}" ]; then
        rm "{{INSTALL_BIN}}/{{BINARY_NAME}}"
        echo "[UNINSTALL] Removed binary"
    else
        echo "[WARNING] Binary not found at {{INSTALL_BIN}}/{{BINARY_NAME}}"
    fi
    
    # Remove man page
    if [ -f "{{INSTALL_MAN}}/trigger.1.gz" ]; then
        rm "{{INSTALL_MAN}}/trigger.1.gz"
        echo "[UNINSTALL] Removed man page"
    else
        echo "[WARNING] Man page not found"
    fi
    
    echo "[UNINSTALL] Uninstallation complete"

# =============================================================================
# Documentation Recipes
# =============================================================================

# Generate documentation
docs:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "[DOCS] Generating documentation..."
    
    # Requires asciidoctor
    if ! command -v asciidoctor >/dev/null 2>&1; then
        echo "[ERROR] asciidoctor not found"
        exit 1
    fi
    
    # Generate HTML
    asciidoctor -D docs/html README.adoc
    asciidoctor -D docs/html EXPLAINME.adoc
    asciidoctor -D docs/html CONTRIBUTING.adoc
    asciidoctor -D docs/html docs/ARCHITECTURE.adoc
    
    # Generate man page
    asciidoctor -b manpage -D docs trigger-man.adoc -o docs/trigger.1
    
    echo "[DOCS] Documentation generated in docs/html/"

# Show README
readme:
    @cat README.adoc

# Show EXPLAINME
explain:
    @cat EXPLAINME.adoc

# =============================================================================
# Development Recipes
# =============================================================================

# Run all development checks
dev-check:
    just lint
    just format-check
    just test

# Lint the code
lint:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "[LINT] Running linter..."
    
    # Ada linting
    if command -v gnatcheck >/dev/null 2>&1; then
        echo "[LINT] Running gnatcheck..."
        gnatcheck -P {{ADA_PROJECT}}
    fi
    
    # Zig linting
    if command -v zig >/dev/null 2>&1; then
        echo "[LINT] Running zig fmt check..."
        cd {{FFI_DIR}}/zig
        zig fmt --check *.zig
        cd ../../
    fi
    
    echo "[LINT] Linting complete"

# Format the code
format:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "[FORMAT] Formatting code..."
    
    # Zig formatting
    if command -v zig >/dev/null 2>&1; then
        echo "[FORMAT] Formatting Zig code..."
        cd {{FFI_DIR}}/zig
        zig fmt *.zig
        cd ../../
    fi
    
    echo "[FORMAT] Formatting complete"

# Check formatting
format-check:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "[FORMAT] Checking code formatting..."
    
    # Zig format check
    if command -v zig >/dev/null 2>&1; then
        echo "[FORMAT] Checking Zig formatting..."
        cd {{FFI_DIR}}/zig
        zig fmt --check *.zig
        cd ../../
    fi
    
    echo "[FORMAT] Format check complete"

# =============================================================================
# Diagnostics Recipes
# =============================================================================

# Check dependencies
check-deps:
    just run-cli --check-deps

# Check configuration
check-config:
    just run-cli --check-config

# Check sessions
check-sessions:
    just run-cli --check-sessions

# Health check
health:
    just run-cli --health

# Full diagnostics
diagnostics: diagnose

# =============================================================================
# Session Management Recipes
# =============================================================================

# List all sessions
list-sessions:
    just run-cli --list-sessions

# Clean invalid sessions
clean-sessions:
    just run-cli --clean-sessions

# Encrypt all sessions
encrypt-sessions:
    just run-cli --encrypt --all-accounts

# Decrypt all sessions
decrypt-sessions:
    just run-cli --decrypt --all-accounts

# =============================================================================
# Reporting Recipes
# =============================================================================

# Report with dry run (preview)
report-dry *channel *count:
    just run-cli --dry-run --channel {{channel}} --report-count {{count}}

# Report with specific account
report-account *account *channel:
    just run-cli --account {{account}} --channel {{channel}}

# Report with all accounts
report-all *channel:
    just run-cli --all-accounts --channel {{channel}}

# Report with custom settings
report *channel *count *delay *reason:
    just run-cli --channel {{channel}} --report-count {{count}} --delay {{delay}} --reason {{reason}} --all-accounts

# =============================================================================
# Utility Recipes
# =============================================================================

# Show system information
sysinfo:
    #!/usr/bin/env bash
    echo "=== System Information ==="
    echo "Date: $(date)"
    echo "Host: $(hostname)"
    echo "OS: $(uname -srm)"
    echo ""
    echo "=== Compiler Versions ==="
    gnat --version 2>&1 | head -1 || echo "GNAT: not found"
    zig version 2>&1 | head -1 || echo "Zig: not found"
    idris2 --version 2>&1 | head -1 || echo "Idris2: not found"
    echo ""
    echo "=== Environment ==="
    echo "USER: $USER"
    echo "HOME: $HOME"
    echo "PWD: $PWD"

# Show project information
project-info:
    @echo "Project: {{PROJECT_NAME}}"
    @echo "Version: {{PROJECT_VERSION}}"
    @echo "Author: hyperpolymath"
    @echo "URL: https://github.com/hyperpolymath/trigger"

# Edit configuration
edit-config:
    #!/usr/bin/env bash
    if [ -f config.json ]; then
        if command -v code >/dev/null 2>&1; then
            code config.json
        elif command -v vim >/dev/null 2>&1; then
            vim config.json
        elif command -v nano >/dev/null 2>&1; then
            nano config.json
        else
            ${EDITOR:-vi} config.json
        fi
    else
        echo "Config file not found. Run 'trigger --set-credentials' to create one."
    fi

# =============================================================================
# Docker Recipes
# =============================================================================

# Build Docker image
docker-build:
    docker build -t hyperpolymath/trigger:latest .

# Run Docker container
docker-run:
    docker run -it hyperpolymath/trigger:latest

# Run Docker with volume mount
docker-run-dev:
    docker run -it -v $(pwd):/app hyperpolymath/trigger:latest bash

# =============================================================================
# Cleanup Recipes
# =============================================================================

# Remove all build artifacts and temporary files
nuke:
    just clean
    rm -rf .alire .alr .zig-cache .idris2
    rm -f *.log *.tmp

# Remove everything except source and git
nuke-all: nuke
    rm -rf sessions/ config.json docs/html/
