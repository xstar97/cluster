ARG PRUNEMATE_VERSION=1.3.3
ARG MC_VERSION=1.4.0

# Stage 1: microcheck binaries
FROM ghcr.io/tarampampam/microcheck:${MC_VERSION} AS microcheck

# Stage 2: runtime image
FROM anoniemerd/prunemate:${PRUNEMATE_VERSION}

# Copy only the HTTP checker
COPY --from=microcheck /bin/httpcheck /usr/bin/httpcheck
