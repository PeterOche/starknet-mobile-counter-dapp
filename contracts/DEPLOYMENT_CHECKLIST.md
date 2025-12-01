# Deployment Checklist

## Required Information

To deploy the Counter contract, please provide:

### 1. Network Selection
Choose one:
- `sepolia-testnet` (Recommended for testing)
- `testnet`
- `mainnet`

### 2. Account Private Key
Your Starknet account's private key (format: `0x...` or hex string)

**Security Note**: 
- Never share your private key publicly
- Make sure you have test ETH in your account for gas fees
- For mainnet, use a dedicated deployment account

### 3. Account Address
Your Starknet account's address (format: `0x...` or hex string)

### Example Format:
```bash
STARKNET_NETWORK=sepolia-testnet
STARKNET_PRIVATE_KEY=0x1234567890abcdef...
STARKNET_ACCOUNT_ADDRESS=0xabcdef1234567890...
```

---

## Quick Deployment Command

Once you have the above information, I can deploy it for you, or you can run:

```bash
export STARKNET_NETWORK=sepolia-testnet
export STARKNET_PRIVATE_KEY=0x...
export STARKNET_ACCOUNT_ADDRESS=0x...
bash deploy_with_starkli.sh
```

---

## What Happens During Deployment

1. ✅ Declares the contract class on the network
2. ✅ Deploys a contract instance
3. ✅ Saves the contract address to `contract_deployment_info.json`
4. ✅ Provides transaction hashes for verification

---

**Ready when you are!** 🚀

