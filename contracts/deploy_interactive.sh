#!/bin/bash
# Interactive deployment script for Counter contract

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Ensure starkli is in PATH
export PATH="$HOME/.starkli/bin:$PATH"

if ! command -v starkli &> /dev/null; then
    echo -e "${RED}❌ Error: starkli not found${NC}"
    echo "Please ensure starkli is installed and in your PATH"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🔷 STARKNET COUNTER CONTRACT DEPLOYMENT${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if contract file exists
CONTRACT_FILE="target/dev/starknet_mobile_counter_Counter.contract_class.json"
if [ ! -f "$CONTRACT_FILE" ]; then
    echo -e "${RED}❌ Error: Contract file not found: $CONTRACT_FILE${NC}"
    echo "Please compile the contract first: scarb build"
    exit 1
fi

# Get network
echo -e "${YELLOW}Select network:${NC}"
echo "1) sepolia-testnet (Recommended for testing)"
echo "2) testnet"
echo "3) mainnet"
read -p "Enter choice [1-3] (default: 1): " network_choice
network_choice=${network_choice:-1}

case $network_choice in
    1) NETWORK="sepolia-testnet" ;;
    2) NETWORK="testnet" ;;
    3) NETWORK="mainnet" ;;
    *) 
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}✓ Network selected: $NETWORK${NC}"
echo ""

# Get private key
read -sp "Enter your private key (0x...): " PRIVATE_KEY
echo ""
if [ -z "$PRIVATE_KEY" ]; then
    echo -e "${RED}❌ Error: Private key is required${NC}"
    exit 1
fi

# Get account address
read -p "Enter your account address (0x...): " ACCOUNT_ADDRESS
if [ -z "$ACCOUNT_ADDRESS" ]; then
    echo -e "${RED}❌ Error: Account address is required${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deploying to: $NETWORK${NC}"
echo -e "${BLUE}Account: $ACCOUNT_ADDRESS${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Export variables for the deployment script
export STARKNET_NETWORK="$NETWORK"
export STARKNET_PRIVATE_KEY="$PRIVATE_KEY"
export STARKNET_ACCOUNT_ADDRESS="$ACCOUNT_ADDRESS"

# Call the main deployment script
bash deploy_with_starkli.sh

