FROM golang:latest AS builder
WORKDIR /app

# https://tailscale.com/kb/1118/custom-derp-servers/
RUN go install tailscale.com/cmd/derper@main

FROM ubuntu:latest
WORKDIR /app

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y ca-certificates && \
    apt-get install -y curl iptables && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /app/certs

ENV TS_SERVER https://controlplane.tailscale.com
ENV DERP_DOMAIN derp01.tailscale.com
ENV DERP_CERT_MODE letsencrypt
ENV DERP_CERT_DIR /app/certs
ENV DERP_ADDR :443
ENV DERP_STUN true
ENV DERP_STUN_PORT 3478
ENV DERP_HTTP_PORT 80
ENV DERP_VERIFY_CLIENTS true

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Copy the derper binary
COPY --from=builder /go/bin/derper .

# Copy and set permissions for the init script
COPY init.sh /init.sh
RUN chmod +x /init.sh

VOLUME ["/var/lib/tailscale"]

ENTRYPOINT ["/init.sh"]
