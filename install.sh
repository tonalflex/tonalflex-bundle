#!/bin/bash
set -e

MANIFEST_FILE="manifest.json"
CORE_DIR="/bin"
PLUGIN_DIR="/home/mind/plugins"
TMP_DIR="/tmp/tonalflex-install"
JQ_PATH="/usr/bin/jq"
JQ_URL="https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-arm64"

cat << "EOF"
  
 _____                 _  __ _           
|_   _|__  _ __   __ _| |/ _| | _____  __
  | |/ _ \| '_ \ / _` | | |_| |/ _ \ \/ /
  | | (_) | | | | (_| | |  _| |  __/>  < 
  |_|\___/|_| |_|\__,_|_|_| |_|\___/_/\_\

        🎛️  INSTALLING TONALFLEX...
  
EOF

# Check if jq is installed
if ! command -v jq >/dev/null 2>&1; then
  echo "⚠️ jq not found — installing static binary using wget..."
  sudo wget -O "$JQ_PATH" "$JQ_URL"
  sudo chmod +x "$JQ_PATH"

  if ! command -v jq >/dev/null 2>&1; then
    echo "❌ Failed to install jq. Exiting."
    exit 1
  fi

  echo -e "✅ jq installed successfully.\n"
fi

# Check that the manifest file exists
if [ ! -f "$MANIFEST_FILE" ]; then
  echo "❌ $MANIFEST_FILE not found in current directory. Exiting."
  exit 1
fi

mkdir -p "$CORE_DIR" "$PLUGIN_DIR" "$TMP_DIR"

echo -e "Installing TonalFlex binaries from $MANIFEST_FILE...\n"

# Install core components
jq -c '.core[]' "$MANIFEST_FILE" | while read -r item; do
  NAME=$(echo "$item" | jq -r '.name')
  URL=$(echo "$item" | jq -r '.url')
  BINARY=$(echo "$item" | jq -r '.binary')

  echo "📦 Installing core binary: $NAME"

  wget -O "$TMP_DIR/$BINARY.tar.gz" "$URL"
  tar -xzf "$TMP_DIR/$BINARY.tar.gz" -C "$TMP_DIR"
  sudo chmod +x "$TMP_DIR/$BINARY"
  sudo mv "$TMP_DIR/$BINARY" "$CORE_DIR/$BINARY"

  echo -e "✔️  Installed $BINARY to $CORE_DIR \n"
done

# Install plugins
jq -c '.plugins[]' "$MANIFEST_FILE" | while read -r item; do
  NAME=$(echo "$item" | jq -r '.name')
  URL=$(echo "$item" | jq -r '.url')
  BINARY=$(echo "$item" | jq -r '.binary')

  echo "📦 Installing plugin: $NAME"

  wget -O "$TMP_DIR/$BINARY.tar.gz" "$URL"
  tar -xzf "$TMP_DIR/$BINARY.tar.gz" -C "$PLUGIN_DIR"

  echo -e "✔️  Installed plugin to $PLUGIN_DIR\n"
done

echo -e "✅ All binaries and plugins installed successfully. \n"

# Clean up
rm -rf "$TMP_DIR"

# Install autostart script
echo "🚀 Setting up device autostart..."
sudo chmod +x autostart/autostart.sh
sudo cp autostart/autostart.sh /udata/autostart.sh
sudo cp autostart/tonalflex-autostart.service /lib/systemd/system/tonalflex-autostart.service

sudo systemctl daemon-reload  
sudo systemctl enable tonalflex-autostart
sudo systemctl start tonalflex-autostart 
echo -e "🕓 Autostart service is enabled and will run on next boot.\n"

echo -e "✅ Tonalflex installation complete! \n"

read -p "Reboot now? [y/N]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  sudo reboot
fi
