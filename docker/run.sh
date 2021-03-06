#!/bin/sh

if echo $PROXY | egrep -sq "true|TRUE|y|Y|yes|YES|1" \
        && [[ ! -z "$KAFKA_REST_PROXY_URL" ]]; then
    echo "Enabling proxy."
    cat <<EOF >>/caddy/Caddyfile
proxy /api/kafka-rest-proxy $KAFKA_REST_PROXY_URL {
    without /api/kafka-rest-proxy
}
EOF
KAFKA_REST_PROXY_URL=/api/kafka-rest-proxy
fi

if [[ -z "$KAFKA_REST_PROXY_URL" ]]; then
    echo "Kafka REST Proxy URL was not set via KAFKA_REST_PROXY_URL environment variable."
else
    echo "Kafka REST Proxy URL to $KAFKA_REST_PROXY_URL."
    cat <<EOF >kafka-topics-ui/env.js
var clusters = [
   {
     NAME:"default",
     KAFKA_REST: "$KAFKA_REST_PROXY_URL",
     MAX_BYTES: "?max_bytes=50000"
   }
]
EOF
fi

echo

exec /caddy/caddy -conf /caddy/Caddyfile
