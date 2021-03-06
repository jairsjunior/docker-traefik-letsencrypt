#!/bin/sh

ACME_SERVER=""
if [ "$LETS_ENCRYPT_TEST_MODE" = true ]; then
    ACME_SERVER="https://acme-staging-v02.api.letsencrypt.org/directory"
fi

if [ -z $SWARM_MODE ]; then
    SWARM_MODE=false
fi

if [ -z $HTTPS_REDIRECT ]; then
    if [ "$HTTPS_REDIRECT" = true ]; then
        ENTRYPOINTS='Name:http Address::80 Redirect.EntryPoint:https'
    else
        ENTRYPOINTS='Name:http Address::80'
    fi
else
    ENTRYPOINTS='Name:http Address::80'
fi

touch /acme.json
chmod 600 acme.json

traefik --api  --docker --docker.watch --docker.domain=docker.localhost --docker.swarmMode=$SWARM_MODE \
--ping --ping.entryPoint=http \
--metrics.prometheus \
--entrypoints=$ENTRYPOINTS \
--entryPoints='Name:https Address::443 TLS' \
--acme \
--acme.acmelogging \
--acme.caserver=$ACME_SERVER  --acme.email=$LETS_ENCRYPT_EMAIL   \
--acme.storage=/acme.json \
--acme.entrypoint=https \
--acme.onhostrule  --acme.httpchallenge \
--acme.httpchallenge.entrypoint=http \
--retry \
--loglevel=INFO
