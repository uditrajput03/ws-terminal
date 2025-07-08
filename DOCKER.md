# Docker Usage for WS-Terminal

This document explains how to use Docker to run the ws-terminal provider, making it easy to deploy and manage remote terminal access without installing dependencies directly on your host system.

## Overview

The [Dockerfile](Dockerfile) creates a containerized version of the ws-terminal provider that includes all necessary dependencies:
- Ubuntu 22.04 base image
- `socat` for terminal multiplexing
- `websocat` for WebSocket communication
- Pre-configured [entrypoint.sh](entrypoint.sh) script

## Building the Docker Image

Build the Docker image from the project root directory:

```bash
docker build -t ws-terminal .
```

## Running the Container

### Basic Usage with Default Relay Server

The container comes pre-configured to connect to the default relay server:

```bash
docker run -it ws-terminal
```

This will connect to `wss://ws-relay-anlb.onrender.com/terminal1` by default.

### Custom Relay Server

Override the default relay URL using the `RELAY_URL` environment variable:

```bash
docker run -it -e RELAY_URL="wss://your-relay-server.com/terminal1" ws-terminal
```

### Different Terminal Channels

Connect to different terminal channels by changing the URL path:

```bash
# Terminal 1
docker run -it -e RELAY_URL="wss://ws-relay-anlb.onrender.com/terminal1" ws-terminal

# Terminal 2
docker run -it -e RELAY_URL="wss://ws-relay-anlb.onrender.com/terminal2" ws-terminal

# Custom channel
docker run -it -e RELAY_URL="wss://ws-relay-anlb.onrender.com/my-server" ws-terminal
```

## Docker Compose

Create a `docker-compose.yml` file for easier management:

```yaml
version: '3.8'

services:
  ws-terminal-1:
    build: .
    environment:
      - RELAY_URL=wss://ws-relay-anlb.onrender.com/terminal1
    restart: unless-stopped

  ws-terminal-2:
    build: .
    environment:
      - RELAY_URL=wss://ws-relay-anlb.onrender.com/terminal2
    restart: unless-stopped
```

Run with Docker Compose:

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

## Container Details

### Image Contents

The Docker image includes:
- **Base OS**: Ubuntu 22.04
- **websocat**: v4.0.0-alpha2 (downloaded from GitHub releases)
- **socat**: Installed via apt package manager
- **Entry point**: [entrypoint.sh](entrypoint.sh) script that handles the WebSocket connection

### Environment Variables

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `RELAY_URL` | `wss://ws-relay-anlb.onrender.com/terminal1` | WebSocket relay server URL |

### Working Directory

The container uses `/app` as the working directory where the [entrypoint.sh](entrypoint.sh) script is located.

## Use Cases

### 1. Remote Server Access

Deploy the container on a remote server to provide terminal access:

```bash
# On remote server
docker run -d --name remote-terminal \
  -e RELAY_URL="wss://your-relay.com/server1" \
  --restart unless-stopped \
  ws-terminal
```

### 2. Development Environment

Provide terminal access to development environments:

```bash
# Development terminal
docker run -it --name dev-terminal \
  -v /path/to/project:/workspace \
  -w /workspace \
  -e RELAY_URL="wss://relay.dev.company.com/dev-env" \
  ws-terminal
```

### 3. CI/CD Pipeline Integration

Use in CI/CD pipelines for debugging:

```bash
# In CI/CD script
if [ "$DEBUG_MODE" = "true" ]; then
  docker run -d --name ci-debug \
    -e RELAY_URL="wss://relay.company.com/ci-debug-$BUILD_ID" \
    ws-terminal
  echo "Debug terminal available at: wss://relay.company.com/ci-debug-$BUILD_ID"
fi
```

## Security Considerations

### Container Security

- The container runs as root by default - consider using a non-root user for production
- Limit container capabilities if not all features are needed
- Use read-only filesystem where possible

### Network Security

- Always use WSS (secure WebSocket) URLs in production
- Ensure your relay server is trusted and secure
- Consider network policies to restrict container access

### Example with Security Enhancements

```bash
docker run -it \
  --read-only \
  --tmpfs /tmp \
  --cap-drop ALL \
  --cap-add SETUID \
  --cap-add SETGID \
  -e RELAY_URL="wss://secure-relay.company.com/terminal1" \
  ws-terminal
```

## Troubleshooting

### Connection Issues

Check container logs:
```bash
docker logs <container-name>
```

### Relay Server Connectivity

Test connectivity to relay server:
```bash
docker run --rm ws-terminal curl -I https://your-relay-server.com
```

### Interactive Debugging

Run container with shell access:
```bash
docker run -it --entrypoint /bin/bash ws-terminal
```

## Integration with Consumer

Once the Docker container is running, consumers can connect using the same relay URL:

```bash
# Consumer connection (from USAGE.md)
socat file:`tty`,raw,echo=0 exec:'./websocat --binary "wss://ws-relay-anlb.onrender.com/terminal1" "-"'
```

Or through a web browser using a WebSocket client library.

## Performance Considerations

- Container startup time: ~2-3 seconds
- Memory usage: ~50-100MB depending on terminal activity
- Network overhead: Minimal, only WebSocket traffic
- CPU usage: Low, mainly I/O bound operations

## Related Documentation

- [README.md](README.md) - Main project documentation
- [USAGE.md](USAGE.md) - Detailed usage instructions
- [Dockerfile](Dockerfile) - Container build configuration
- [entrypoint.sh](entrypoint.sh) - Container startup script