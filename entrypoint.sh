#!/bin/bash
echo "Connecting provider to relay server: $RELAY_URL"
websocat -b "$RELAY_URL" exec:socat --exec-args - exec:"bash -li",pty,stderr,setsid,sigint,sane