# Tailscale DERP Server

Inspired by:

- <https://github.com/fredliang44/derper-docker>
- <https://github.com/tijjjy/Tailscale-DERP-Docker>

## Environment

| Env                   | Default                              | Description                                                                                                                       |
| --------------------- | ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| `DERP_DOMAIN`         | `derp01.tailscale.com`               |                                                                                                                                   |
| `DERP_CERT_MODE`      | `letsencrypt`                        |                                                                                                                                   |
| `DERP_CERT_DIR`       | `/app/certs`                         |                                                                                                                                   |
| `DERP_ADDR`           | `:443`                               | If you need to use a reverse proxy (Nginx, Traefik, Caddy) to manage TLS certificates, you can set ":80" to listen for http.      |
| `DERP_STUN`           | `true`                               | Enable STUN server                                                                                                                |
| `DERP_STUN_PORT`      | `3478`                               |                                                                                                                                   |
| `DERP_HTTP_PORT`      | `80`                                 |                                                                                                                                   |
| `DERP_VERIFY_CLIENTS` | `true`                               |                                                                                                                                   |
| `TS_SERVER`           | `https://controlplane.tailscale.com` | If you are using self-hosted `headscale`, set the server address. Only available `DERP_VERIFY_CLIENTS=true`.                      |
| `TS_AUTHKEY`          | `tskey-abcdef1234567890`             | If you only allow verify-client, you **MUST** set the auth key. (<https://tailscale.com/kb/1085/auth-keys>)                       |
| `TS_EXTRA_ARGS`       |                                      | Tailscale CLI arguments, for example you can set the node name via `--hostname=derp-01`. (<https://tailscale.com/kb/1080/cli#up>) |

## Example

### Docker Standalone

```bash
docker run -it \
  -e TS_SERVER=https://hs-control.example.com \
  -e TS_AUTHKEY=tskey-abcdef1432341818 \
  -e DERP_DOMAIN=derp-01.example.com \
  -p 443:443/udp
  -p 3478:3478/udp
  ghcr.io/wind4/tailscale-derper:main
```

### Docker Compose + Traefik

```yaml
version: "3"

services:
  traefik:
    image: traefik:v2.10
    command:
      - --providers.docker=true
      - --providers.docker.exposedbydefault=false
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
    ports:
      - 80:80
      - 443:443
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik_data:/etc/traefik
    restart: always

  derper:
    image: ghcr.io/wind4/tailscale-derper:main
    environment:
      - TS_SERVER=https://hs-control.example.com
      - TS_AUTHKEY=tskey-abcdef1432341818
      - TS_EXTRA_ARGS=--hostname depr-01
      - DERP_DOMAIN=derp-01.example.com
      - DERP_ADDR=:80
    labels:
      - traefik.enable=true
      - traefik.http.routers.derper.entrypoints=websecure
      - traefik.http.routers.derper.rule=Host(`derp-01.example.com`)
      - traefik.http.services.derper.loadbalancer.server.port=80
    ports:
      - 3478:3478/udp
    volumes:
      - tailscale_data:/var/lib/tailscale
    restart: always

volumes:
  traefik_data:
  tailscale_data:
```
