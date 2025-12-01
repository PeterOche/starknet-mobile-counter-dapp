#!/bin/bash

# Deploy Counter contract using Starkli
# This script declares and deploys the contract

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Add starkli to PATH if not already there
export PATH="$HOME/.starkli/bin:$PATH"

# Ensure starkli is available
if ! command -v starkli &> /dev/null; then
    if [ -f "$HOME/.starkli/bin/starkliup" ]; then
        echo "Installing starkli..."
        "$HOME/.starkli/bin/starkliup"
        export PATH="$HOME/.starkli/bin:$PATH"
    fi
fi

# Configuration
NETWORK="${STARKNET_NETWORK:-sepolia-testnet}"
RPC_URL="${STARKNET_RPC_URL:-}"
PRIVATE_KEY="${STARKNET_PRIVATE_KEY:-}"
ACCOUNT_ADDRESS="${STARKNET_ACCOUNT_ADDRESS:-}"

CONTRACT_FILE="target/dev/starknet_mobile_counter_Counter.contract_class.json"
OUTPUT_FILE="contract_deployment_info.json"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🔷 STARKNET COUNTER CONTRACT DEPLOYMENT${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if starkli is installed
if ! command -v starkli &> /dev/null; then
    echo -e "${YELLOW}⚠️  starkli not found in PATH, attempting to install...${NC}"
    if [ -f "$HOME/.starkli/bin/starkliup" ]; then
        "$HOME/.starkli/bin/starkliup"
        export PATH="$HOME/.starkli/bin:$PATH"
    else
        echo -e "${RED}❌ Error: starkli is not installed${NC}"
        echo "Please install starkli: curl -L https://get.starkli.sh | sh"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Starkli found: $(starkli --version)${NC}"
echo ""

# Check if contract file exists
if [ ! -f "$CONTRACT_FILE" ]; then
    echo -e "${RED}❌ Error: Contract file not found: $CONTRACT_FILE${NC}"
    echo "Please compile the contract first: scarb build"
    exit 1
fi

echo -e "${GREEN}✅ Contract file found: $CONTRACT_FILE${NC}"
echo ""

# Function to calculate class hash
calculate_class_hash() {
    echo -e "${BLUE}📋 Calculating class hash...${NC}"
    starkli class-hash "$CONTRACT_FILE" 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Could not calculate class hash automatically${NC}"
        echo "This is okay - it will be calculated during declaration"
    }
}

# Function to declare contract
declare_contract() {
    if [ -z "$PRIVATE_KEY" ] || [ -z "$ACCOUNT_ADDRESS" ]; then
        echo -e "${YELLOW}⚠️  Warning: STARKNET_PRIVATE_KEY or STARKNET_ACCOUNT_ADDRESS not set${NC}"
        echo ""
        echo "To deploy, you need:"
        echo "1. Set STARKNET_PRIVATE_KEY environment variable"
        echo "2. Set STARKNET_ACCOUNT_ADDRESS environment variable"
        echo "3. Make sure your account has ETH for gas fees"
        echo ""
        echo "Example:"
        echo "  export STARKNET_PRIVATE_KEY=0x..."
        echo "  export STARKNET_ACCOUNT_ADDRESS=0x..."
        echo ""
        echo -e "${BLUE}Extracting contract information without deployment...${NC}"
        return 1
    fi
    
    echo -e "${BLUE}📋 Declaring contract class...${NC}"
    
    # Build declare command
    DECLARE_CMD="starkli declare"
    
    if [ -n "$RPC_URL" ]; then
        DECLARE_CMD="$DECLARE_CMD --rpc $RPC_URL"
    else
        case "$NETWORK" in
            sepolia-testnet)
                DECLARE_CMD="$DECLARE_CMD --network sepolia-testnet"
                ;;
            testnet)
                DECLARE_CMD="$DECLARE_CMD --network testnet"
                ;;
            mainnet)
                DECLARE_CMD="$DECLARE_CMD --network mainnet"
                ;;
            *)
                echo -e "${YELLOW}⚠️  Unknown network, using default${NC}"
                ;;
        esac
    fi
    
    DECLARE_CMD="$DECLARE_CMD --account $ACCOUNT_ADDRESS --private-key $PRIVATE_KEY $CONTRACT_FILE"
    
    echo -e "${BLUE}Running: $DECLARE_CMD${NC}"
    
    CLASS_HASH=$(eval "$DECLARE_CMD" 2>&1 | grep -i "class hash" | grep -oE "0x[a-fA-F0-9]+" | head -1)
    
    if [ -z "$CLASS_HASH" ]; then
        echo -e "${YELLOW}⚠️  Could not extract class hash from declaration output${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Contract declared!${NC}"
    echo -e "${GREEN}   Class Hash: $CLASS_HASH${NC}"
    
    echo "$CLASS_HASH"
    return 0
}

# Function to deploy contract instance
deploy_contract() {
    local class_hash=$1
    
    echo ""
    echo -e "${BLUE}📦 Deploying contract instance...${NC}"
    
    DEPLOY_CMD="starkli deploy"
    
    if [ -n "$RPC_URL" ]; then
        DEPLOY_CMD="$DEPLOY_CMD --rpc $RPC_URL"
    else
        case "$NETWORK" in
            sepolia-testnet)
                DEPLOY_CMD="$DEPLOY_CMD --network sepolia-testnet"
                ;;
            testnet)
                DEPLOY_CMD="$DEPLOY_CMD --network testnet"
                ;;
            mainnet)
                DEPLOY_CMD="$DEPLOY_CMD --network mainnet"
                ;;
        esac
    fi
    
    DEPLOY_CMD="$DEPLOY_CMD --account $ACCOUNT_ADDRESS --private-key $PRIVATE_KEY $class_hash"
    
    echo -e "${BLUE}Running: $DEPLOY_CMD${NC}"
    
    CONTRACT_ADDRESS=$(eval "$DEPLOY_CMD" 2>&1 | grep -iE "(contract|address|deployed)" | grep -oE "0x[a-fA-F0-9]+" | head -1)
    
    if [ -z "$CONTRACT_ADDRESS" ]; then
        echo -e "${YELLOW}⚠️  Could not extract contract address from deployment output${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Contract deployed!${NC}"
    echo -e "${GREEN}   Contract Address: $CONTRACT_ADDRESS${NC}"
    
    echo "$CONTRACT_ADDRESS"
    return 0
}

# Extract contract info
extract_info() {
    echo -e "${BLUE}📄 Extracting contract information...${NC}"
    
    # Run Python extraction script
    if [ -f "extract_contract.py" ]; then
        python3 extract_contract.py
    fi
    
    # Try to calculate class hash
    CLASS_HASH=$(starkli class-hash "$CONTRACT_FILE" 2>&1 | grep -oE "0x[a-fA-F0-9]+" | head -1)
    
    if [ -z "$CLASS_HASH" ]; then
        CLASS_HASH="N/A (requires declaration to calculate)"
    fi
    
    # Create deployment info JSON
    cat > "$OUTPUT_FILE" << EOF
{
  "network": "$NETWORK",
  "contract_name": "Counter",
  "class_hash": "$CLASS_HASH",
  "contract_file": "$CONTRACT_FILE",
  "deployment_status": "extracted",
  "note": "Contract information extracted. To deploy, set STARKNET_PRIVATE_KEY and STARKNET_ACCOUNT_ADDRESS environment variables and run this script again."
}
EOF
    
    echo -e "${GREEN}✅ Contract information saved to: $OUTPUT_FILE${NC}"
}

# Main execution
if [ -n "$PRIVATE_KEY" ] && [ -n "$ACCOUNT_ADDRESS" ]; then
    echo -e "${BLUE}🚀 Attempting to deploy contract...${NC}"
    echo ""
    
    CLASS_HASH=$(declare_contract)
    if [ $? -eq 0 ] && [ -n "$CLASS_HASH" ]; then
        CONTRACT_ADDRESS=$(deploy_contract "$CLASS_HASH")
        
        if [ $? -eq 0 ] && [ -n "$CONTRACT_ADDRESS" ]; then
            # Save deployment info
            cat > "$OUTPUT_FILE" << EOF
{
  "network": "$NETWORK",
  "contract_name": "Counter",
  "class_hash": "$CLASS_HASH",
  "contract_address": "$CONTRACT_ADDRESS",
  "contract_file": "$CONTRACT_FILE",
  "deployment_status": "deployed",
  "deployed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
            echo ""
            echo -e "${GREEN}✅ Deployment information saved to: $OUTPUT_FILE${NC}"
        fi
    fi
else
    extract_info
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Done!${NC}"
echo -e "${BLUE}========================================${NC}"

