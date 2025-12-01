#!/bin/bash
set -e

echo "🚀 Deploying Counter Contract to Starknet Sepolia"
echo "=================================================="

# Configuration
ACCOUNT_ADDRESS="0x01472c0a8b37928e3138ddc8d8757fa85a551ad8d61c7ae491ecd79d3f8b8acd"
PRIVATE_KEY="0x0510089bf65090cb87bbad425e27a5ebba82d838a8a113b06b31fad23e94af34"
RPC_URL="https://rpc.starknet-testnet.lava.build"
CONTRACT_NAME="Counter"

echo "📍 Account: $ACCOUNT_ADDRESS"
echo "🌐 RPC: $RPC_URL"
echo ""

# Declare the contract
echo "📝 Declaring contract..."
DECLARE_OUTPUT=$(sncast --account-address $ACCOUNT_ADDRESS \
    --private-key $PRIVATE_KEY \
    --url $RPC_URL \
    declare \
    --contract-name $CONTRACT_NAME 2>&1)

echo "$DECLARE_OUTPUT"

# Extract class hash from output
CLASS_HASH=$(echo "$DECLARE_OUTPUT" | grep -oP 'class_hash: \K0x[0-9a-fA-F]+' || echo "$DECLARE_OUTPUT" | grep -oP 'Class hash: \K0x[0-9a-fA-F]+')

if [ -z "$CLASS_HASH" ]; then
    echo "❌ Failed to extract class hash from declare output"
    echo "Output was: $DECLARE_OUTPUT"
    exit 1
fi

echo "✅ Contract declared!"
echo "   Class Hash: $CLASS_HASH"
echo ""

# Deploy the contract
echo "🚢 Deploying contract..."
DEPLOY_OUTPUT=$(sncast --account-address $ACCOUNT_ADDRESS \
    --private-key $PRIVATE_KEY \
    --url $RPC_URL \
    deploy \
    --class-hash $CLASS_HASH 2>&1)

echo "$DEPLOY_OUTPUT"

# Extract contract address from output
CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -oP 'contract_address: \K0x[0-9a-fA-F]+' || echo "$DEPLOY_OUTPUT" | grep -oP 'Contract address: \K0x[0-9a-fA-F]+')

if [ -z "$CONTRACT_ADDRESS" ]; then
    echo "❌ Failed to extract contract address from deploy output"
    echo "Output was: $DEPLOY_OUTPUT"
    exit 1
fi

echo ""
echo "=================================================="
echo "🎉 Deployment Complete!"
echo ""
echo "📋 Contract Details:"
echo "   Class Hash: $CLASS_HASH"
echo "   Contract Address: $CONTRACT_ADDRESS"
echo ""
echo "📝 Update your Flutter app (lib/config/constants.dart):"
echo "   static const String contractAddress = '$CONTRACT_ADDRESS';"
echo "   static const String rpcUrl = '$RPC_URL';"
echo ""
echo "✅ Save these values!"
