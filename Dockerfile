FROM eclipse-temurin:8-jdk

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /opt/minecraft

# Install unzip (used to extract serverpack.zip) and certificates
RUN apt-get update \
	&& apt-get install -y --no-install-recommends unzip ca-certificates curl \
	&& rm -rf /var/lib/apt/lists/*

# Copy the repository into the image. If you build with a `serverpack.zip` in the build context
# it will be extracted in the next step. If you already have the server directory (e.g.
# `All_of_Create_6.0_v2.1_serverpack/`) this will also be copied.
COPY . /opt/minecraft/

# Add entrypoint wrapper which ensures EULA acceptance and optionally adds an OP user
COPY entrypoint.sh /opt/minecraft/entrypoint.sh
RUN chmod +x /opt/minecraft/entrypoint.sh

# If a serverpack.zip was provided, extract it into the working directory and remove the zip.
RUN if [ -f /opt/minecraft/serverpack.zip ]; then \
	  unzip -q /opt/minecraft/serverpack.zip -d /opt/minecraft && rm /opt/minecraft/serverpack.zip; \
	fi

# Create a non-root user and take ownership of the server files
RUN useradd -m -u 6969 mc \
	&& chown -R mc:mc /opt/minecraft

USER mc
ENV HOME=/home/mc

# Make sure the provided start script is executable (no-op if missing)
RUN chmod +x /opt/minecraft/start.sh || true

# Minecraft default port
EXPOSE 25565

# Expose common directories as volumes so host can persist worlds, configs and mods.
# For full persistence mount `/opt/minecraft` or mount at least `world`, `config`, and `mods`.
VOLUME ["/opt/minecraft/world", "/opt/minecraft/config", "/opt/minecraft/mods"]

WORKDIR /opt/minecraft

# Use our entrypoint which will create eula.txt and optionally add an operator via OP_USER env var
ENTRYPOINT ["/opt/minecraft/entrypoint.sh"]

