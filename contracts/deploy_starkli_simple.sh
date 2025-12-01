#!/bin/bash
# Simplified starkli deployment using direct signer

set -e

export PATH="$HOME/.starkli/bin:$PATH"

NETWORK="sepolia-testnet"
PRIVATE_KEY="0x0510089bf65090cb87bbad425e27a5ebba82d838a8a113b06b31fad23e94af34"
ACCOUNT_ADDRESS="0x00268061A3489a8d2A82888Eacd3338940A83A9a33520680D75f0dAFB90Ce707"
CONTRACT_FILE="target/dev/starknet_mobile_counter_Counter.contract_class.json"

echo "🔷 Deploying Counter Contract to $NETWORK"
echo "=========================================="
echo ""

# Check if contract exists
if [ ! -f "$CONTRACT_FILE" ]; then
    echo "❌ Error: Contract file not found: $CONTRACT_FILE"
    exit 1
fi

echo "📋 Step 1: Declaring contract class..."
echo ""

# Declare using starkli with private key as signer
DECLARE_OUTPUT=$(starkli declare "$CONTRACT_FILE" \
    --network "$NETWORK" \
    --account "$ACCOUNT_ADDRESS" \
    --private-key "$PRIVATE_KEY" 2>&1)

echo "$DECLARE_OUTPUT"

# Extract class hash
CLASS_HASH=$(echo "$DECLARE_OUTPUT" | grep -i "class hash" | grep -oE "0x[a-fA-F0-9]+" | head -1)

if [ -z "$CLASS_HASH" ]; then
    # Try to extract from different patterns
    CLASS_HASH=$(echo "$DECLARE_OUTPUT" | grep -oE "0x[a-fA-F0-9]{64}" | head -1)
fi

if [ -z "$CLASS_HASH" ]; then
    echo ""
    echo "❌ Error: Could not extract class hash from declaration output"
    echo "Full output was saved above"
    exit 1
fi

echo ""
echo "✅ Contract declared!"
echo "   Class Hash: $CLASS_HASH"
echo ""

# Wait a moment for the transaction to be processed
echo "⏳ Waiting for transaction confirmation..."
sleep 5

echo ""
echo "📦 Step 2: Deploying contract instance..."
echo ""

# Deploy the contract
DEPLOY_OUTPUT=$(starkli deploy "$CLASS_HASH" \
    --network "$NETWORK" \
    --account "$ACCOUNT_ADDRESS" \
    --private-key "$PRIVATE_KEY" 2>&1)

echo "$DEPLOY_OUTPUT"

# Extract contract address
CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -iE "(contract|address|deployed)" | grep -oE "0x[a-fA-F0-9]+" | head -1)

if [ -z "$CONTRACT_ADDRESS" ]; then
    # Try to extract from different patterns
    CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -oE "0x[a-fA-F0-9]{64}" | head -2 | tail -1)
fi

if [ -z "$CONTRACT_ADDRESS" ]; then
    echo ""
    echo "❌ Error: Could not extract contract address from deployment output"
    echo "Full output was saved above"
    exit 1
fi

echo ""
echo "✅ Contract deployed successfully!"
echo ""
echo "=========================================="
echo "📊 DEPLOYMENT SUMMARY"
echo "=========================================="
echo "Network: $NETWORK"
echo "Class Hash: $CLASS_HASH"
echo "Contract Address: $CONTRACT_ADDRESS"
echo ""

# Save deployment info
cat > contract_deployment_info.json << EOF
{
  "network": "$NETWORK",
  "contract_name": "Counter",
  "class_hash": "$CLASS_HASH",
  "contract_address": "$CONTRACT_ADDRESS",
  "account_address": "$ACCOUNT_ADDRESS",
  "deployment_status": "deployed",
  "deployed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

echo "💾 Deployment information saved to: contract_deployment_info.json"
echo ""
echo "✅ Deployment complete!"

