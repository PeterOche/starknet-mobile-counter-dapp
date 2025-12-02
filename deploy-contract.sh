#!/bin/bash

# Deploy Counter Contract to Devnet using starkli

echo "Deploying Counter Contract to Local Devnet..."

# Devnet account details
ACCOUNT_ADDRESS="0x01346c1b579a994541dc0bef3e6427c31c8df892115825139dc60c09aa925d04"
PRIVATE_KEY="0x00000000000000000000000000000000ef0125d1158ba6e7d5b5bd24082062fc"
RPC_URL="http://localhost:5050"

# Contract files
CONTRACT_CLASS="contracts/target/dev/starknet_mobile_counter_Counter.contract_class.json"
CASM="contracts/target/dev/starknet_mobile_counter_Counter.compiled_contract_class.json"

echo "Step 1: Declaring contract..."
CLASS_HASH=$(starkli declare $CONTRACT_CLASS \
  --rpc $RPC_URL \
  --account $ACCOUNT_ADDRESS \
  --private-key-raw $PRIVATE_KEY \
  2>&1 | grep "Class hash declared" | awk '{print $NF}')

if [ -z "$CLASS_HASH" ]; then
  echo "Error: Failed to declare contract"
  exit 1
fi

echo "Class hash: $CLASS_HASH"

echo "Step 2: Deploying contract..."
CONTRACT_ADDRESS=$(starkli deploy $CLASS_HASH \
  --rpc $RPC_URL \
  --account $ACCOUNT_ADDRESS \
  --private-key-raw $PRIVATE_KEY \
  2>&1 | grep "Contract deployed" | awk '{print $NF}')

if [ -z "$CONTRACT_ADDRESS" ]; then
  echo "Error: Failed to deploy contract"
  exit 1
fi

echo ""
echo "✅ Contract deployed successfully!"
echo "Contract Address: $CONTRACT_ADDRESS"
echo ""
echo "Update lib/config/constants.dart with:"
echo "static const String contractAddress = '$CONTRACT_ADDRESS';"
