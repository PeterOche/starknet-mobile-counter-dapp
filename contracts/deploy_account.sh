#!/bin/bash
# Deploy account to Sepolia if it doesn't exist

export PATH="$HOME/.starkli/bin:$PATH"

PRIVATE_KEY="0x0510089bf65090cb87bbad425e27a5ebba82d838a8a113b06b31fad23e94af34"
DESIRED_ADDRESS="0x00268061A3489a8d2A82888Eacd3338940A83A9a33520680D75f0dAFB90Ce707"
RPC="https://starknet-sepolia-rpc.publicnode.com"

echo "🔍 Checking if account exists on Sepolia..."
echo "Account: $DESIRED_ADDRESS"
echo ""

# Check if account exists
RESPONSE=$(curl -s -X POST "$RPC" \
  -H "Content-Type: application/json" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"starknet_getNonce\",\"params\":{\"contract_address\":\"$DESIRED_ADDRESS\",\"block_id\":\"latest\"},\"id\":1}")

if echo "$RESPONSE" | grep -q "Contract not found"; then
    echo "❌ Account does NOT exist on Sepolia"
    echo ""
    echo "📝 To create an account on Sepolia, you need to:"
    echo "1. Get Sepolia ETH (from a faucet)"
    echo "2. Deploy the account contract"
    echo ""
    echo "Would you like to:"
    echo "A) Create a NEW account on Sepolia (easier)"
    echo "B) Deploy your existing account (requires Sepolia ETH)"
    echo ""
    echo "The account.json file we created has a different address."
    echo "We can create a new account file that matches your private key."
else
    echo "✅ Account EXISTS on Sepolia!"
    echo "$RESPONSE"
fi

