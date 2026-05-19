ARG WOL_VERSION=0.1.0
ARG MC_VERSION=1.4.0

# Stage 1: microcheck binaries
FROM ghcr.io/tarampampam/microcheck:${MC_VERSION} AS microcheck

# Stage 2: wol runtime image
FROM ghcr.io/trugamr/wol:${WOL_VERSION}

# Copy only the HTTP checker
COPY --from=microcheck /bin/httpcheck /usr/bin/httpcheck
