#!/bin/bash
# FINAL deployment script - using class hash directly

export PATH="$HOME/.starkli/bin:$PATH"

CLASS_HASH="0x04163508eca596f199fbf9efb45355fa391142989f2310484baa066feb390ad0"
NETWORK="sepolia-testnet"
ACCOUNT="0x00268061A3489a8d2A82888Eacd3338940A83A9a33520680D75f0dAFB90Ce707"
PRIVATE_KEY="0x0510089bf65090cb87bbad425e27a5ebba82d838a8a113b06b31fad23e94af34"

echo "🚀 DEPLOYING CONTRACT"
echo "===================="
echo "Class Hash: $CLASS_HASH"
echo "Network: $NETWORK"
echo ""

# Check if class is already declared by trying to deploy directly
echo "📦 Attempting deployment (will declare if needed)..."
OUTPUT=$(starkli deploy "$CLASS_HASH" \
    --network "$NETWORK" \
    --account "$ACCOUNT" \
    --private-key "$PRIVATE_KEY" \
    --watch 2>&1)

echo "$OUTPUT"

# Extract contract address
CONTRACT_ADDR=$(echo "$OUTPUT" | grep -oE "0x[a-fA-F0-9]{64}" | tail -1)

if [ -n "$CONTRACT_ADDR" ] && [ "$CONTRACT_ADDR" != "$CLASS_HASH" ]; then
    echo ""
    echo "✅ SUCCESS!"
    echo "Contract Address: $CONTRACT_ADDR"
    
    cat > contract_deployment_info.json << EOF
{
  "network": "$NETWORK",
  "contract_name": "Counter",
  "class_hash": "$CLASS_HASH",
  "contract_address": "$CONTRACT_ADDR",
  "deployment_status": "deployed"
}
EOF
    
    echo "💾 Saved to contract_deployment_info.json"
else
    echo ""
    echo "Checking if we need to declare first..."
    echo "The class hash might need to be declared before deployment."
fi

