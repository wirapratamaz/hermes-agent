#!/bin/bash
# Hermes Agent + ClawRouter Startup Script

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${MAGENTA}${BOLD}"
echo "┌─────────────────────────────────────────────────────────┐"
echo "│     Hermes Agent + ClawRouter Integration               │"
echo "│     x402 USDC Micropayments on Base                     │"
echo "└─────────────────────────────────────────────────────────┘"
echo -e "${NC}"

# Check if ClawRouter is running
if ! curl -s http://127.0.0.1:8402/health > /dev/null 2>&1; then
    echo -e "${CYAN}→${NC} Starting ClawRouter proxy..."
    
    # Start ClawRouter in background
    npx @blockrun/clawrouter > /tmp/clawrouter.log 2>&1 &
    CLAW_PID=$!
    
    # Wait for ClawRouter to be ready
    echo -e "${YELLOW}⏳${NC} Waiting for ClawRouter to start..."
    for i in {1..30}; do
        if curl -s http://127.0.0.1:8402/health > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} ClawRouter is running on http://127.0.0.1:8402"
            break
        fi
        sleep 1
    done
    
    # Show wallet address
    sleep 2
    if [ -f /tmp/clawrouter.log ]; then
        WALLET=$(grep -i "0x[a-fA-F0-9]\{40\}" /tmp/clawrouter.log | head -1 | grep -o "0x[a-fA-F0-9]\{40\}" || echo "")
        if [ -n "$WALLET" ]; then
            echo -e "${CYAN}→${NC} Wallet address: ${BOLD}$WALLET${NC}"
            echo -e "${CYAN}→${NC} Send USDC on Base to fund your wallet"
        fi
    fi
else
    echo -e "${GREEN}✓${NC} ClawRouter already running"
fi

echo ""
echo -e "${CYAN}→${NC} Starting Hermes Agent..."
echo -e "${CYAN}→${NC} Model: ${BOLD}blockrun/auto${NC} (smart routing enabled)"
echo ""

# Start Hermes Agent with the config
cd "$(dirname "$0")"
export HERMES_CONFIG="$(pwd)/.config"
uv run hermes chat --model blockrun/auto

# Cleanup on exit
trap "kill $CLAW_PID 2>/dev/null" EXIT
