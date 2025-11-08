#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")" || exit 1

# Ensure eula is accepted so user doesn't have to interactively accept
if [ ! -f eula.txt ]; then
  echo "eula=true" > eula.txt
else
  # replace any existing value to true
  if grep -q "^eula=" eula.txt 2>/dev/null; then
    sed -i 's/^eula=.*/eula=true/' eula.txt || true
  else
    echo "eula=true" >> eula.txt
  fi
fi

# Optionally add an operator before starting. Provide OP_USER="playername" as env var.
if [ -n "${OP_USER:-}" ]; then
  uuid_raw=""
  # Try to fetch Mojang UUID for the username (online-mode servers)
  if command -v curl >/dev/null 2>&1; then
    # Query Mojang API: returns JSON like {"id":"<hexuuid>","name":"<name>"}
    uuid_raw=$(curl -sS --fail --connect-timeout 5 "https://api.mojang.com/users/profiles/minecraft/${OP_USER}" 2>/dev/null | sed -n 's/.*"id":"\([0-9a-fA-F]*\)".*/\1/p' || true)
  fi

  if [ -n "${uuid_raw}" ]; then
    # Add hyphens to raw UUID (8-4-4-4-12)
    UUID_FORMATTED="${uuid_raw:0:8}-${uuid_raw:8:4}-${uuid_raw:12:4}-${uuid_raw:16:4}-${uuid_raw:20:12}"
  else
    # Fallback placeholder if lookup fails (may not grant op in online-mode)
    UUID_FORMATTED="00000000-0000-0000-0000-000000000000"
  fi

  # create ops.json if it doesn't exist or is empty
  if [ ! -f ops.json ] || [ "$(cat ops.json | tr -d ' \n')" = "[]" ]; then
    cat > ops.json <<EOF
[{"uuid":"${UUID_FORMATTED}","name":"${OP_USER}","level":4,"bypassesPlayerLimit":false}]
EOF
  else
    # If ops.json exists and doesn't already contain the name, insert an entry before the final ]
    if ! grep -q "\"name\":\"${OP_USER}\"" ops.json; then
      # Insert comma + entry before the last closing bracket
      sed -i "\$s/\]/, {\"uuid\":\"${UUID_FORMATTED}\",\"name\":\"${OP_USER}\",\"level\":4,\"bypassesPlayerLimit\":false}]/" ops.json
    fi
  fi
fi

# Ensure start script is executable
chmod +x ./start.sh || true

# Exec the original start script so signals are forwarded
exec bash ./start.sh
