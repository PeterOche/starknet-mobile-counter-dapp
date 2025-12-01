# Counter Contract Deployment Guide

## Contract Information

- **Contract Name**: Counter
- **Contract File**: `target/dev/starknet_mobile_counter_Counter.contract_class.json`
- **Source Code**: `src/lib.cairo`

## Extracted Contract Details

### Functions

1. **get_counter(user: felt252) -> felt252**
   - Type: View function
   - Selector: `0x3370263ab53343580e77063a719a5865004caff7f367ec136a6cdd34b6786ca`
   - Returns the current counter value

2. **increase_counter()**
   - Type: External function
   - Selector: `0x245f9bea6574169db91599999bf914dd43aebc1e0544bdc96c9f401a52b8768`
   - Increments the counter by 1

### Entry Points

- **EXTERNAL**: 2 functions
- **L1_HANDLER**: 0 functions
- **CONSTRUCTOR**: None (no constructor parameters)

## Deployment Methods

### Method 1: Using Python Script (Recommended)

The contract has been extracted. To deploy:

```bash
# Install dependencies
pip install starknet-py

# Set environment variables
export STARKNET_NETWORK=sepolia-testnet  # or testnet, mainnet
export STARKNET_PRIVATE_KEY=0x...
export STARKNET_ACCOUNT_ADDRESS=0x...

# Deploy
python3 deploy.py
```

### Method 2: Using Starkli CLI

```bash
# Install starkli
curl https://get.starkli.sh | sh
source ~/.starkli/env

# Configure starkli
starkli signer keystore from-key --file keystore.json

# Declare contract
starkli declare target/dev/starknet_mobile_counter_Counter.contract_class.json --network sepolia-testnet

# Deploy contract (replace CLASS_HASH with output from declaration)
starkli deploy CLASS_HASH --network sepolia-testnet
```

### Method 3: Using Starknet.js

```javascript
const { Account, Contract, Provider, RpcProvider } = require('starknet');

// Connect to network
const provider = new RpcProvider({ nodeUrl: 'https://starknet-sepolia.public.blastapi.io/rpc/v0_7' });

// Load contract
const compiledSierra = require('./target/dev/starknet_mobile_counter_Counter.contract_class.json');

// Declare and deploy
const declareResponse = await account.declare({ contract: compiledSierra });
await provider.waitForTransaction(declareResponse.transaction_hash);

const deployResponse = await account.deployContract({
    classHash: declareResponse.class_hash,
    constructorCalldata: []
});
await provider.waitForTransaction(deployResponse.transaction_hash);
```

## Files Generated

After extraction/deployment, the following files are created:

- `extracted_contract_info.json` - Full contract information
- `Counter_ABI.json` - Contract ABI only
- `contract_info.json` - Deployment information (if deployed)
- `contract_deployment_info.json` - Deployment details (if deployed)

## Contract ABI

The ABI is available in `Counter_ABI.json` and includes:

```json
[
  {
    "type": "interface",
    "name": "starknet_mobile_counter::ICounter",
    "items": [
      {
        "type": "function",
        "name": "get_counter",
        "inputs": [{"name": "user", "type": "core::felt252"}],
        "outputs": [{"type": "core::felt252"}],
        "state_mutability": "view"
      },
      {
        "type": "function",
        "name": "increase_counter",
        "inputs": [],
        "outputs": [],
        "state_mutability": "external"
      }
    ]
  }
]
```

## Network RPC Endpoints

- **Sepolia Testnet**: `https://starknet-sepolia.public.blastapi.io/rpc/v0_7`
- **Testnet**: `https://starknet-testnet.public.blastapi.io/rpc/v0_7`
- **Mainnet**: `https://starknet-mainnet.public.blastapi.io/rpc/v0_7`

## Next Steps

1. Get testnet ETH from a faucet (for testnet deployment)
2. Set up an account with private key
3. Run deployment script with credentials
4. Save contract address and class hash for frontend integration

## Contract Source Code

```cairo
#[starknet::contract]
mod Counter {
    use starknet::get_caller_address;

    #[storage]
    struct Storage {
        counter: felt252,
    }

    #[abi(embed_v0)]
    impl CounterImpl of super::ICounter<ContractState> {
        fn get_counter(self: @ContractState, user: felt252) -> felt252 {
            self.counter.read()
        }

        fn increase_counter(ref self: ContractState) {
            let current = self.counter.read();
            self.counter.write(current + 1);
        }
    }
}
```

