FROM eclipse-temurin:8-jdk

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /server

# Default memory settings (can be overridden with -e flags)
ENV MEMORY_MIN=6G
ENV MEMORY_MAX=6G
ENV OP_USER="Catley"

# Install wget, unzip, and curl (for Mojang UUID lookup)
RUN apt-get update \
	&& apt-get install -y --no-install-recommends wget unzip curl \
	&& rm -rf /var/lib/apt/lists/*

# Download and extract serverpack directly to /server
RUN wget -q -O /tmp/serverpack.zip https://github.com/Marley-Mulvin-Broome/all-of-create-docker/releases/download/1.0.0/serverpack.zip \
	&& unzip -q /tmp/serverpack.zip -d /server \
	&& rm /tmp/serverpack.zip

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Minecraft default port
EXPOSE 25565

WORKDIR /server

ENTRYPOINT ["/entrypoint.sh"]

