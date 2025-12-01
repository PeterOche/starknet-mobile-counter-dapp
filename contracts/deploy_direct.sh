#!/bin/bash
# Direct RPC deployment - NO dependencies, just curl and the contract file

set -e

RPC_URL="https://starknet-sepolia.public.blastapi.io/rpc/v0_7"
PRIVATE_KEY="0x0510089bf65090cb87bbad425e27a5ebba82d838a8a113b06b31fad23e94af34"
ACCOUNT_ADDRESS="0x00268061A3489a8d2A82888Eacd3338940A83A9a33520680D75f0dAFB90Ce707"
CONTRACT_FILE="target/dev/starknet_mobile_counter_Counter.contract_class.json"

echo "🚀 Deploying Counter Contract (Direct RPC Method)"
echo "=================================================="
echo ""

if [ ! -f "$CONTRACT_FILE" ]; then
    echo "❌ Contract file not found: $CONTRACT_FILE"
    exit 1
fi

echo "✅ Contract file found"
echo "⚠️  This method requires starknet-py or starkli for signing."
echo ""
echo "Let me try one more time with starkli and proper account setup..."
echo ""

# Use starkli but create account file correctly
export PATH="$HOME/.starkli/bin:$PATH"

# Create account file with proper format - try using starkli account oz init
echo "📝 Setting up account file..."
cat > account_temp.json << EOF
{
  "version": 1,
  "variant": {
    "type": "open_zeppelin",
    "version": 1,
    "public_key": "0x0",
    "legacy": false,
    "multisig": false
  }
}
EOF

# Try declaring with just the account file path and private key
echo "🚀 Declaring contract..."
OUTPUT=$(starkli declare "$CONTRACT_FILE" \
    --network sepolia-testnet \
    --account "$ACCOUNT_ADDRESS" \
    --private-key "$PRIVATE_KEY" 2>&1) || true

echo "$OUTPUT"

# Check if it worked
if echo "$OUTPUT" | grep -qi "class hash"; then
    CLASS_HASH=$(echo "$OUTPUT" | grep -i "class hash" | grep -oE "0x[a-fA-F0-9]+" | head -1)
    echo ""
    echo "✅ Declaration successful! Class Hash: $CLASS_HASH"
    
    echo ""
    echo "📦 Deploying contract..."
    DEPLOY_OUTPUT=$(starkli deploy "$CLASS_HASH" \
        --network sepolia-testnet \
        --account "$ACCOUNT_ADDRESS" \
        --private-key "$PRIVATE_KEY" 2>&1) || true
    
    echo "$DEPLOY_OUTPUT"
    
    if echo "$DEPLOY_OUTPUT" | grep -qiE "(contract|address|deployed)"; then
        CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -oE "0x[a-fA-F0-9]{64}" | tail -1)
        echo ""
        echo "✅ Deployment successful!"
        echo "Contract Address: $CONTRACT_ADDRESS"
        
        cat > contract_deployment_info.json << EOF
{
  "network": "sepolia-testnet",
  "contract_name": "Counter",
  "class_hash": "$CLASS_HASH",
  "contract_address": "$CONTRACT_ADDRESS",
  "account_address": "$ACCOUNT_ADDRESS",
  "deployment_status": "deployed"
}
EOF
        echo "💾 Saved to contract_deployment_info.json"
    fi
else
    echo ""
    echo "❌ Declaration failed. Full output above."
    exit 1
fi

