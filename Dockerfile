FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    socat \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app


RUN curl -L -o /usr/local/bin/websocat https://github.com/vi/websocat/releases/download/v4.0.0-alpha2/websocat.x86_64-unknown-linux-musl \
&& chmod +x /usr/local/bin/websocat

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Set default relay URL that can be overridden
ENV RELAY_URL="wss://ws-relay-anlb.onrender.com/terminal1"

ENTRYPOINT ["/app/entrypoint.sh"]
# CMD ["websocat", "-b", "wss://ws-relay-anlb.onrender.com/terminal1", "exec:socat", "--exec-args", "-", "exec:bash -li,pty,stderr,setsid,sigint,sane"]