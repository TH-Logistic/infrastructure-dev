#!/bin/bash

docker run \
    --name kong_gateway_container \
    --mount type=bind,source="$(pwd)/"kong.yaml,target=/kong/config/kong.yaml,readonly \
    --env KONG_DATABASE=off \
    --env KONG_DECLARATIVE_CONFIG=/kong/config/kong.yaml \
    --env KONG_PROXY_ACCESS_LOG=/dev/stdout \
    --env KONG_ADMIN_ACCESS_LOG=/dev/stdout \
    --env KONG_PROXY_ERROR_LOG=/dev/stderr \
    --env KONG_ADMIN_ERROR_LOG=/dev/stderr \
    --env KONG_ADMIN_LISTEN=0.0.0.0:8001 \
    --env KONG_ADMIN_GUI_URL=http://localhost:9002 \
    -p 9000:8000 \
    -p 9443:8443 \
    -p 9001:8001 \
    -p 9444:8444 \
    -p 9002:8002 \
    -p 9445:8445 \
    -p 9003:8003 \
    -p 9004:8004 \
    -d kong/kong-gateway:3.2.2.1

# docker-compose --context remote-server-thinhlh -f gateway.docker-compose.yaml down --rmi all --volumes
# docker-compose --context remote-server-thinhlh -f gateway.docker-compose.yaml up -d
# docker-compose --context remote-server-thinhlh -f gateway.docker-compose.yaml logs --follow