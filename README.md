# All of Create Minecraft Server - Docker

Docker setup for running the All of Create modpack server.

## Quick Start

### Build the Image

```bash
docker build -t all-of-create-server .
```

### Run the Server

Basic run (no persistence):
```bash
docker run -d \
  --name all-of-create-server \
  -p 25565:25565 \
  all-of-create-server
```

With persistence (recommended):
```bash
docker run -d \
  --name all-of-create-server \
  -p 25565:25565 \
  -v "$(pwd)/server-data":/opt/minecraft \
  all-of-create-server
```

With persistence and automatic operator:
```bash
docker run -d \
  --name all-of-create-server \
  -p 25565:25565 \
  -v "$(pwd)/server-data":/opt/minecraft \
  -e OP_USER="YourMinecraftUsername" \
  all-of-create-server
```

## Environment Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `OP_USER` | Minecraft username to grant operator privileges | No | `OP_USER="Notch"` |

## Volumes

For data persistence, mount `/opt/minecraft` to a host directory:

```bash
-v /path/on/host:/opt/minecraft
```

This will persist:
- World data
- Configuration files
- Mods
- Server properties
- Operator list (ops.json)
- Logs

You can also mount specific subdirectories:
```bash
-v "$(pwd)/world":/opt/minecraft/world \
-v "$(pwd)/config":/opt/minecraft/config \
-v "$(pwd)/mods":/opt/minecraft/mods
```

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 25565 | TCP | Minecraft server default port |

## Managing the Container

### View logs
```bash
docker logs -f all-of-create-server
```

### Stop the server
```bash
docker stop all-of-create-server
```

### Start the server
```bash
docker start all-of-create-server
```

### Remove the container
```bash
docker rm -f all-of-create-server
```

### Access the server console
```bash
docker attach all-of-create-server
```
*Note: Use `Ctrl+P` then `Ctrl+Q` to detach without stopping the server.*

## Features

- **Automatic EULA acceptance** - No need to manually accept the Minecraft EULA
- **Automatic operator assignment** - Set `OP_USER` to automatically grant operator privileges using Mojang's UUID lookup
- **Java 8** - Uses Eclipse Temurin JDK 8 for compatibility with the modpack
- **Non-root user** - Server runs as user `mc` (UID 6969) for security
- **Automatic serverpack download** - Downloads the serverpack from GitHub releases during build

## Troubleshooting

### Server won't start
Check the logs:
```bash
docker logs all-of-create-server
```

### Port already in use
If port 25565 is already in use, map to a different port:
```bash
docker run -d \
  --name all-of-create-server \
  -p 25566:25565 \
  -v "$(pwd)/server-data":/opt/minecraft \
  all-of-create-server
```

### Permission issues with volumes
If you encounter permission errors with mounted volumes, ensure the host directory is writable by UID 6969:
```bash
mkdir -p server-data
sudo chown -R 6969:6969 server-data
```

## Updating the Server

To update to a new version of the serverpack:

1. Update the download URL in the `Dockerfile`
2. Rebuild the image:
   ```bash
   docker build -t all-of-create-server .
   ```
3. Stop and remove the old container:
   ```bash
   docker rm -f all-of-create-server
   ```
4. Start a new container with the updated image

Your world data and configs will be preserved if you're using volume mounts.
