#!/usr/bin/env bash
set -e

CONTAINER_NAME="all-of-create-server"
IMAGE_NAME="all-of-create-server"
DATA_DIR="$(pwd)/server-data"

echo "=== Building Docker image ==="
docker build -t "$IMAGE_NAME" .

echo ""
echo "=== Removing existing container (if any) ==="
docker rm -f "$CONTAINER_NAME" 2>/dev/null || echo "No existing container to remove"

echo ""
echo "=== Starting new container ==="
docker run -d \
  --name "$CONTAINER_NAME" \
  -p 25565:25565 \
  -v "$DATA_DIR":/server \
  -e OP_USER="${OP_USER:-}" \
  "$IMAGE_NAME"

echo ""
echo "=== Container started successfully ==="
echo "Container name: $CONTAINER_NAME"
echo "Data directory: $DATA_DIR"
echo "Port: 25565"
echo ""
echo "Useful commands:"
echo "  View logs:        docker logs -f $CONTAINER_NAME"
echo "  Stop server:      docker stop $CONTAINER_NAME"
echo "  Start server:     docker start $CONTAINER_NAME"
echo "  Remove container: docker rm -f $CONTAINER_NAME"
echo ""
echo "Tailing logs (Ctrl+C to exit, container keeps running):"
docker logs -f "$CONTAINER_NAME"
