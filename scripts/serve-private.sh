#!/bin/sh
set -eu
port=${1:-3000}
case "$port" in ''|*[!0-9]*) echo "Supply a numeric loopback service port" >&2; exit 2;; esac
[ "$port" -ge 1 ] && [ "$port" -le 65535 ] || exit 2
command -v tailscale >/dev/null || { echo "Install and enroll Tailscale first" >&2; exit 2; }
# Serves only an existing host loopback service; no Funnel/public sharing.
tailscale serve --bg "http://127.0.0.1:$port"
tailscale serve status
