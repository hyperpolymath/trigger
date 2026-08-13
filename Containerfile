# Trigger Containerfile
# 
# Multi-stage build for Trigger application
# Author: hyperpolymath
# 
# Usage:
#   podman build -t hyperpolymath/trigger:latest .
#   podman run -it hyperpolymath/trigger:latest
#
# or with Docker (alias):
#   docker build -t hyperpolymath/trigger:latest .
#   docker run -it hyperpolymath/trigger:latest

# =============================================================================
# Stage 1: Build Ada/SPARK application
# =============================================================================
FROM ghcr.io/alire-project/gnat-native:latest AS builder

# Set environment
ENV APP_NAME=trigger \
    APP_VERSION=1.0.0 \
    BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    BUILD_COMMIT="$(git rev-parse HEAD 2>/dev/null || echo 'unknown')" \
    BUILD_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')"

WORKDIR /app

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy source files
COPY . .

# Build with GNAT
RUN mkdir -p obj bin && \
    gprbuild -P trigger.gpr -XLIBRARY_TYPE=static && \
    cp obj/trigger bin/trigger

# =============================================================================
# Stage 2: Install Zig for FFI
# =============================================================================
FROM ghcr.io/alire-project/gnat-native:latest AS zig-builder

WORKDIR /app

# Install Zig
RUN wget -O /tmp/zig.tar.xz https://ziglang.org/builds/zig-linux-x86_64-0.11.0.tar.xz && \
    tar -xf /tmp/zig.tar.xz -C /usr/local && \
    ln -s /usr/local/zig-linux-x86_64-0.11.0/zig /usr/local/bin/zig && \
    rm /tmp/zig.tar.xz

# Copy files from previous stage
COPY --from=builder /app /app

# Build Zig FFI
RUN cd ffi/zig && \
    zig build-lib -dynamic telegram.zig && \
    cd ../..

# =============================================================================
# Stage 3: Runtime image
# =============================================================================
FROM debian:stable-slim AS runtime

# Set environment
ENV APP_NAME=trigger \
    APP_VERSION=1.0.0 \
    PATH="/app/bin:${PATH}"

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgcc-s1 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create directory structure
RUN mkdir -p bin config sessions logs tmp

# Copy built binaries from builder
COPY --from=builder /app/bin/trigger bin/trigger
COPY --from=builder /app/ffi/zig/libtelegram.so lib/

# Set permissions
RUN chmod +x bin/trigger && \
    chmod 750 sessions logs tmp

# =============================================================================
# Stage 4: Final image with all components
# =============================================================================
FROM runtime AS final

# Copy documentation and configuration
COPY LICENSE LICENSES/ README.adoc CONTRIBUTING.adoc GOVERNANCE.adoc .
COPY docs/ /app/docs/
COPY .editorconfig .gitignore .gitattributes .

# Copy www files
COPY www/ /app/www/

# Copy scripts
COPY scripts/ /app/scripts/

# Copy machine-readable metadata
COPY .machine_readable/ /app/.machine_readable/

# Set default configuration
RUN mkdir -p .machine_readable/metadata && \
    echo '{"name":"trigger","version":"1.0.0","description":"Telegram reporting utility","author":"hyperpolymath"}' > .machine_readable/metadata/trigger.json

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["/app/bin/trigger", "--health"] || exit 1

# Entrypoint
ENTRYPOINT ["/app/bin/trigger"]
CMD ["--help"]

# Expose ports (if needed for future web interface)
EXPOSE 8080

# Volume for persistent data
VOLUME ["/app/sessions", "/app/logs", "/app/config"]

# Labels
LABEL org.opencontainers.image.title="Trigger" \
      org.opencontainers.image.description="Telegram channel reporting utility" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.author="hyperpolymath" \
      org.opencontainers.image.url="https://github.com/hyperpolymath/trigger" \
      org.opencontainers.image.licenses="MPL-2.0,CC-BY-SA-4.0" \
      org.opencontainers.image.source="https://github.com/hyperpolymath/trigger" \
      maintainer="hyperpolymath <hyperpolymath@users.noreply.github.com>"

# User to run as (non-root)
RUN adduser --disabled-password --gecos '' appuser && \
    chown -R appuser:appuser /app
USER appuser
