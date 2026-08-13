# Dockerfile for Trigger
# 
# This is an alias for Containerfile for Docker users.
# The actual build instructions are in Containerfile.
#
# Usage:
#   docker build -t hyperpolymath/trigger:latest .
#   docker run -it hyperpolymath/trigger:latest

FROM scratch

# This Dockerfile intentionally left blank.
# Use Containerfile instead, or run:
#   docker build -f Containerfile -t hyperpolymath/trigger:latest .

# The Containerfile contains the actual multi-stage build instructions
# optimized for both Podman and Docker.
