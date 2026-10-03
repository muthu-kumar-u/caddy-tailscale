# Caddy and Tailscale starter

Standalone local/server templates for a public HTTPS reverse proxy and private administration. Caddy runs in Docker; Tailscale runs on the host so enrollment, private access and recovery remain separate from app containers. No product API or database is included.

## Local reverse proxy

```sh
cp .env.example .env
docker compose --env-file .env -f compose.local.yml up -d --build
```

Open `http://localhost:8088`. A tiny demo confirms the proxy; it is not a production application. The local listener is loopback only and intentionally HTTP. Use `LOCAL_PORT` if 8088 is occupied.

## Server HTTPS

Set a real DNS A/AAAA record, monitored TLS email, accepted `CADDY_IMAGE` digest and `UPSTREAM=YOUR_SERVICE:PORT` in the host `.env`. Connect the application and edge to the same external Docker network. Caddy cannot reach an unrelated app container without that network.

```sh
docker network create application_network
# Attach your app service to that network first.
docker compose --env-file .env -f compose.server.yml pull
docker compose --env-file .env -f compose.server.yml up -d
```

Open public 80/443 for DNS/HTTPS; keep app/database ports private. Caddy automatically manages certificates for a valid public hostname. Preserve certificate volumes. Application-specific CSP, OAuth origins and API body limits belong to the owning app/deployment repo and must be reviewed for that application.

## Tailscale on a workstation or server

Install using the [official OS instructions](https://tailscale.com/download), enroll under the intended operator's tailnet and review `tailscale status`. On Linux a host can be enrolled with `sudo tailscale up --hostname=YOUR_HOST`; use an interactive login or a narrowly scoped short-lived enrollment mechanism. Never commit an auth key.

Adapt `tailscale/policy.hujson` with real identities and merge it into the tailnet policy. Restrict viewers to the private HTTPS service; operators may use normal SSH through the tailnet with their existing SSH authentication. Policy tests need to pass before relying on restrictions. Assign the configured server tag. The template does not enable Tailscale SSH automatically.

For Grafana or another host-loopback admin service:

```sh
sh scripts/serve-private.sh 3000
```

Use the exact HTTPS URL reported by Serve. Configure the app's public/root URL and secure-cookie setting for that private URL. Keep application authentication enabled too. Do not enable Funnel for private logs. Use `tailscale serve status` to inspect active configuration; resetting Serve affects existing routes, so review them first.

Each clone has its own Git history and CI. Pushes build/publish the Caddy image with independent branch/SHA/version tags; PRs build only. The workflow derives the registry path from the repo, so another project can reuse it. References: [Caddy proxy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy), [Tailscale Serve](https://tailscale.com/docs/reference/tailscale-cli/serve).
