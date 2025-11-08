#!/usr/bin/env bash
set -euo pipefail

cd /server

# Auto-accept EULA
echo "eula=true" > eula.txt

# Set memory in variables.txt if it exists
if [ -f variables.txt ]; then
  # Update JAVA_ARGS with memory settings
  sed -i "s/^JAVA_ARGS=.*/JAVA_ARGS=\"-Xms${MEMORY_MIN} -Xmx${MEMORY_MAX}\"/" variables.txt || true
fi

# Add operator if OP_USER is set
if [ -n "${OP_USER}" ]; then
  echo "=== Adding operator: ${OP_USER} ==="
  
  # Try to fetch Mojang UUID
  uuid_raw=$(curl -sS --fail --connect-timeout 5 "https://api.mojang.com/users/profiles/minecraft/${OP_USER}" 2>/dev/null | sed -n 's/.*"id":"\([0-9a-fA-F]*\)".*/\1/p' || true)
  
  if [ -n "${uuid_raw}" ]; then
    # Format UUID with hyphens (8-4-4-4-12)
    UUID_FORMATTED="${uuid_raw:0:8}-${uuid_raw:8:4}-${uuid_raw:12:4}-${uuid_raw:16:4}-${uuid_raw:20:12}"
    echo "Found UUID: ${UUID_FORMATTED}"
  else
    # Fallback placeholder
    UUID_FORMATTED="00000000-0000-0000-0000-000000000000"
    echo "Warning: Could not fetch UUID from Mojang, using placeholder"
  fi
  
  # Create or update ops.json
  if [ ! -f ops.json ] || [ "$(cat ops.json | tr -d ' \n')" = "[]" ]; then
    cat > ops.json <<EOF
[{"uuid":"${UUID_FORMATTED}","name":"${OP_USER}","level":4,"bypassesPlayerLimit":false}]
EOF
  else
    if ! grep -q "\"name\":\"${OP_USER}\"" ops.json; then
      sed -i "\$s/\]/, {\"uuid\":\"${UUID_FORMATTED}\",\"name\":\"${OP_USER}\",\"level\":4,\"bypassesPlayerLimit\":false}]/" ops.json
    fi
  fi
fi

# Make start.sh executable and run it
# Pipe "I agree" to auto-accept any prompts (like Jabba installation)
chmod +x ./start.sh
echo "I agree" | exec bash ./start.sh
