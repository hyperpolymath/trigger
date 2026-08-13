#!/usr/bin/env bash
#
# Git Hooks Configuration for Trigger
#
# Customize the behavior of Git hooks by modifying these variables.
#
# SPDX-License-Identifier: MPL-2.0

# Enable/disable hooks (0 = disabled, 1 = enabled)
export ENABLE_PRE_COMMIT=1
export ENABLE_PRE_PUSH=1
export ENABLE_POST_COMMIT=1
export ENABLE_POST_MERGE=1

# Strictness level
#   0 = lenient (warn only, never block)
#   1 = normal (block on critical issues)
#   2 = strict (block on warnings)
export STRICTNESS_LEVEL=2

# Timeout for checks (in seconds)
export CHECK_TIMEOUT=300

# Directories to check
export CHECK_DIRS="src ffi tests"

# File extensions to check for SPDX headers
export SPDX_CHECK_EXTENSIONS="ads adb zig idr"

# Maximum file size for large file detection (in megabytes)
export MAX_FILE_SIZE_MB=50

# GitHub Actions workflows to trigger
export GITHUB_WORKFLOWS=("ci" "test" "lint" "build")

# Custom commands to run
export CUSTOM_PRE_COMMIT_CMD=""
export CUSTOM_PRE_PUSH_CMD=""
export CUSTOM_POST_COMMIT_CMD=""
export CUSTOM_POST_MERGE_CMD=""
