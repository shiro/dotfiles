#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

# Get your personal access token from: https://www.figma.com/settings
FIGMA_TOKEN=""

# ============================================================================
# Get Figma URL from argument or prompt
# ============================================================================

if [ $# -eq 0 ]; then
    # No arguments provided, prompt for URL
    echo "Enter Figma URL (with node-id):" >&2
    read -r FIGMA_URL
else
    # Use first argument as URL
    FIGMA_URL="$1"
fi

# Validate URL is not empty
if [ -z "$FIGMA_URL" ]; then
    echo "Error: No URL provided" >&2
    exit 1
fi

# ============================================================================
# Extract File Key and Node ID from URL
# ============================================================================

# Extract file key (the hash after /design/ or /file/)
FILE_KEY=$(echo "$FIGMA_URL" | sed -E 's#.*/(design|file)/([^/\?]+).*#\2#')

# Extract node-id parameter
NODE_ID=$(echo "$FIGMA_URL" | sed -E 's#.*node-id=([^&]+).*#\1#')

echo "File Key: $FILE_KEY" >&2
echo "Node ID: $NODE_ID" >&2
echo "Fetching Figma data..." >&2
echo "" >&2

# ============================================================================
# Fetch from Figma API
# ============================================================================

# API endpoint for getting specific nodes
# Note: Figma node IDs use colons in the API, but hyphens in URLs
API_NODE_ID="${NODE_ID//-/:}"

API_URL="https://api.figma.com/v1/files/${FILE_KEY}/nodes?ids=${API_NODE_ID}"

# Make the API request
curl -s -H "X-Figma-Token: ${FIGMA_TOKEN}" "$API_URL"
