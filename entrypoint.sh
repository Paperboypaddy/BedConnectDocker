#!/bin/bash
set -e

APP_JAR="BedrockConnect.jar"
VERSION_FILE="version.txt"
JAVA_PID=0

# Set DEBUG mode via env var (default: false)
DEBUG=${DEBUG:-false}
UPDATE_INTERVAL=${UPDATE_INTERVAL:-300}

function log() {
  local level=$1
  local message=$2

  if [[ "$level" == "DEBUG" && "$DEBUG" != "true" ]]; then
    return
  fi

  echo "$(date +"%H:%M:%S") [$level] $message"
}

function start_bedrock() {
  log "INFO" "Starting BedrockConnect..."
  java -jar "$APP_JAR" nodb=true &
  JAVA_PID=$!
  log "DEBUG" "BedrockConnect started with PID $JAVA_PID"
}

function stop_bedrock() {
  if kill -0 $JAVA_PID 2>/dev/null; then
    log "INFO" "Stopping BedrockConnect (PID $JAVA_PID)..."
    kill $JAVA_PID
    wait $JAVA_PID
    log "DEBUG" "BedrockConnect stopped"
  else
    log "DEBUG" "No BedrockConnect process to stop"
  fi
}

function check_update() {
  log "DEBUG" "Checking for updates..."
  RELEASE_JSON=$(curl -s https://api.github.com/repos/Pugmatt/BedrockConnect/releases/latest)
  LATEST_VERSION=$(echo "$RELEASE_JSON" | jq -r .tag_name)
  DOWNLOAD_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url')

  CURRENT_VERSION=""
  if [[ -f "$VERSION_FILE" ]]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")
  fi

  log "DEBUG" "Latest version: $LATEST_VERSION"
  log "DEBUG" "Current version: $CURRENT_VERSION"

  if [[ "$LATEST_VERSION" != "$CURRENT_VERSION" ]]; then
    log "INFO" "New version detected: $LATEST_VERSION (was $CURRENT_VERSION)"
    log "INFO" "Downloading new version..."
    curl -L "$DOWNLOAD_URL" -o "$APP_JAR"
    echo "$LATEST_VERSION" > "$VERSION_FILE"
    return 0
  fi

  log "DEBUG" "No update found"
  return 1
}

# Initial download if missing
if [[ ! -f "$APP_JAR" ]]; then
  log "INFO" "No BedrockConnect.jar found, downloading..."
  check_update || true
fi

start_bedrock

# Main loop: check updates every 5 minutes (300 seconds)
while true; do
  sleep 300

  if check_update; then
    log "INFO" "Update found. Restarting BedrockConnect..."
    stop_bedrock
    start_bedrock
  else
    log "INFO" "No updates found."
  fi
done