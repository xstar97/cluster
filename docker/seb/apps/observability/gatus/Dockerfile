ARG GATUS_VERSION=v5.36.0@sha256:c5f210d095fa78e6efaa20ffeb14803f2ba4f10615e16a6d12087697149617f0
ARG MC_VERSION=1.4.0

# Stage 1: microcheck binaries
FROM ghcr.io/tarampampam/microcheck:${MC_VERSION} AS microcheck

# Stage 2: distroless gatus runtime
FROM ghcr.io/twin/gatus:${GATUS_VERSION}

# Copy only the HTTP checker
COPY --from=microcheck /bin/httpcheck /usr/bin/httpcheck
