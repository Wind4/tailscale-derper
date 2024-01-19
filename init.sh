#!/usr/bin/env sh

if [ -n $TS_AUTHKEY ]; then
  /usr/sbin/tailscaled --tun=userspace-networking --state=/var/lib/tailscale/tailscaled.state >> /dev/stdout &
  /usr/bin/tailscale up --login-server=$TS_SERVER --auth-key $TS_AUTHKEY $TS_EXTRA_ARGS >> /dev/stdout &
fi

/app/derper \
  --hostname=$DERP_DOMAIN \
  --certmode=$DERP_CERT_MODE \
  --certdir=$DERP_CERT_DIR \
  --a=$DERP_ADDR \
  --stun=$DERP_STUN  \
  --stun-port=$DERP_STUN_PORT \
  --http-port=$DERP_HTTP_PORT \
  --verify-clients=$DERP_VERIFY_CLIENTS
