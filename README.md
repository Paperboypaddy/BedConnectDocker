# BedrockConnect Docker

A lightweight, auto-updating Dockerized [BedrockConnect](https://github.com/Pugmatt/BedrockConnect) server paired with a public DNS server powered by `bind9`. This setup allows Minecraft: Bedrock Edition players to connect to custom servers by replacing the featured server list using DNS spoofing.

## 🔧 Features

- ✅ Dockerized version of BedrockConnect
- ✅ Public DNS server (`bind9`) listening on port 53 (UDP/TCP)
- ✅ Self-updating BedrockConnect JAR (checks GitHub releases periodically)
- ✅ Configurable update interval with `UPDATE_INTERVAL`
- ✅ Debug logging with timestamps via `DEBUG=true`
- ✅ Minimal memory footprint (`512MB` limit)
- ✅ One-command startup with Docker Compose

---

## 🐳 Docker Compose Usage

Here’s a ready-to-use `docker-compose.yml`:

```yaml
services:
  bedrockconnect:
    image: paperboypaddy/bedrockconnect:latest
    container_name: bedconnect
    environment:
      - USER=container      #Dont change this
      - DEBUG=false         #Log Debug Messages
      - UPDATE_INTERVAL=600 #Check For Updates every 600 seconds
    restart: unless-stopped
    ports:
      - "19132:19132/udp"
    volumes:
      - ./bedrockconnect/:/home/container #You can change the host folder
    mem_limit: "512M" #512MB should be enough ram to host enough players on here
  bind9:
    container_name: bind-dns
    image: ubuntu/bind9:latest
    environment:
      - BIND9_USER=root
      - TZ=America/Los_Angeles
    ports:
      - "53:53/tcp"
      - "53:53/udp"
    volumes:
      - ./bind9/config:/etc/bind #You can also change host folder here
      - ./bind9/cache:/var/cache/bind
      - ./bind9/records:/var/lib/bind
    restart: unless-stopped
```

## 🚀 Quick Start

```bash
docker compose up -d
```

Place your bind configuration inside ./bind9/config

The BedrockConnect JAR will auto-download and run inside ./bedrockconnect

The container will check for updates every 10 minutes and restart BedrockConnect when a new version is found

## ⚙️ Environment Variables

| Variable          | Description                            | Default |
| ----------------- | -------------------------------------- | ------- |
| `DEBUG`           | Enables debug logs (`true` or `false`) | `false` |
| `UPDATE_INTERVAL` | Update check interval in seconds       | `600`   |

## 🧪 Development
To build and run the container locally:

```bash
docker build -t paperboypaddy/bedrockconnect .
docker run -it --rm -e DEBUG=true paperboypaddy/bedrockconnect
```

## 🙌 Credits
- [Pugmatt/BedrockConnect](https://github.com/Pugmatt/BedrockConnect) for the original server
- Docker image based on minimal base with [javaj9](https://ghcr.io/forestracks/javaj9:8)
