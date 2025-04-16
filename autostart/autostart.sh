#!/bin/bash

# Paths to executables
SUSHI_BIN="/usr/bin/sushi"
ENVOY_BIN="/usr/bin/envoy"
BUTLER_BIN="/usr/bin/butler"
UI_SERVER_BIN="/usr/bin/ui-server"

# Configuration files
SUSHI_CONFIG="/home/mind/tonalflex-bundle/config/tonalflex-8-ch.json"
ENVOY_CONFIG="/home/mind/tonalflex-bundle/config/envoy.yaml"

# Log files
SUSHI_LOG="/tmp/sushi.log"
ENVOY_LOG="/tmp/envoy.log"
AUTOSTART_LOG="/tmp/autostart.log"

# Check if executables exist
if [ ! -x "$SUSHI_BIN" ]; then
    echo "Error: Sushi binary not found at $SUSHI_BIN" >> "$AUTOSTART_LOG"
    exit 1
fi

if [ ! -x "$ENVOY_BIN" ]; then
    echo "Error: Envoy binary not found at $ENVOY_BIN" >> "$AUTOSTART_LOG"
    exit 1
fi

if [ ! -x "$BUTLER_BIN" ]; then
    echo "Error: Butler binary not found at $BUTLER_BIN" >> "$AUTOSTART_LOG"
    exit 1
fi

if [ ! -x "$UI_SERVER_BIN" ]; then
    echo "Error: UI server binary not found at $UI_SERVER_BIN" >> "$AUTOSTART_LOG"
    exit 1
fi

# Check if configuration files exist
if [ ! -f "$SUSHI_CONFIG" ]; then
    echo "Error: Sushi config not found at $SUSHI_CONFIG" >> "$AUTOSTART_LOG"
    exit 1
fi

if [ ! -f "$ENVOY_CONFIG" ]; then
    echo "Error: Envoy config not found at $ENVOY_CONFIG" >> "$AUTOSTART_LOG"
    exit 1
fi

# Check for external HAT and start sushi
AUDIO_HAT_FILE="/tmp/audio_hat"
if [ -f "$AUDIO_HAT_FILE" ] && [ -s "$AUDIO_HAT_FILE" ]; then
    HAT_CONTENT=$(cat "$AUDIO_HAT_FILE")
    LINE_COUNT=$(echo "$HAT_CONTENT" | grep -v "^$" | wc -l)
    if [ "$LINE_COUNT" -eq 1 ] && [ "$HAT_CONTENT" = "elkpi-stereo" ]; then
        echo "Only elkpi-stereo detected, starting Sushi in dummy mode" >> "$AUTOSTART_LOG"
        $SUSHI_BIN -dummy --multicore-processing=2 -c "$SUSHI_CONFIG" > "$SUSHI_LOG" 2>&1 &
    else
        echo "Multiple audio devices detected (including HAT): $HAT_CONTENT, starting Sushi in real-time mode" >> "$AUTOSTART_LOG"
        $SUSHI_BIN -r --multicore-processing=2 -c "$SUSHI_CONFIG" > "$SUSHI_LOG" 2>&1 &
    fi
else
    echo "No audio HAT detected, starting Sushi in dummy mode" >> "$AUTOSTART_LOG"
    $SUSHI_BIN -dummy --multicore-processing=2 -c "$SUSHI_CONFIG" > "$SUSHI_LOG" 2>&1 &
fi

# Start Envoy
$ENVOY_BIN -c "$ENVOY_CONFIG" --log-path "$ENVOY_LOG" &

# Start Butler
$BUTLER_BIN &

# Start UI server
$UI_SERVER_BIN &

# Log success
echo "Started Sushi and Envoy on $(date)" >> "$AUTOSTART_LOG"