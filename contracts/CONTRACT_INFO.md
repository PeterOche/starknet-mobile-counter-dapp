# Counter Smart Contract - Complete Information

## Overview

This document contains all extracted information about the Counter smart contract.

---

## Contract Details

- **Contract Name**: Counter
- **Package Name**: starknet_mobile_counter
- **Contract Class Version**: 0.1.0
- **Source File**: `src/lib.cairo`
- **Compiled Contract**: `target/dev/starknet_mobile_counter_Counter.contract_class.json`
- **Sierra Program Length**: 226 elements

---

## Contract Source Code

```cairo
#[starknet::interface]
trait ICounter<TContractState> {
    fn get_counter(self: @TContractState, user: felt252) -> felt252;
    fn increase_counter(ref self: TContractState);
}

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

---

## Functions

### 1. get_counter

- **Type**: View function
- **Function Selector**: `0x3370263ab53343580e77063a719a5865004caff7f367ec136a6cdd34b6786ca`
- **Function Index**: 0
- **Inputs**:
  - `user`: `felt252`
- **Outputs**:
  - `felt252` - Returns the current counter value
- **State Mutability**: View (read-only)

### 2. increase_counter

- **Type**: External function
- **Function Selector**: `0x245f9bea6574169db91599999bf914dd43aebc1e0544bdc96c9f401a52b8768`
- **Function Index**: 1
- **Inputs**: None
- **Outputs**: None
- **State Mutability**: External (writes to storage)

---

## Storage

The contract has a single storage variable:

- **counter**: `felt252` - Stores the current counter value

---

## Entry Points

| Type | Count | Details |
|------|-------|---------|
| EXTERNAL | 2 | `get_counter`, `increase_counter` |
| L1_HANDLER | 0 | None |
| CONSTRUCTOR | 0 | No constructor (uses default) |

---

## Contract ABI

The complete ABI is available in `Counter_ABI.json`. Here's a summary:

```json
[
  {
    "type": "impl",
    "name": "CounterImpl",
    "interface_name": "starknet_mobile_counter::ICounter"
  },
  {
    "type": "interface",
    "name": "starknet_mobile_counter::ICounter",
    "items": [
      {
        "type": "function",
        "name": "get_counter",
        "inputs": [
          {
            "name": "user",
            "type": "core::felt252"
          }
        ],
        "outputs": [
          {
            "type": "core::felt252"
          }
        ],
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
  },
  {
    "type": "event",
    "name": "starknet_mobile_counter::Counter::Event",
    "kind": "enum",
    "variants": []
  }
]
```

---

## Deployment Information

### Prerequisites

1. **Account**: A Starknet account with ETH for gas fees
2. **Private Key**: Your account's private key
3. **Network**: Choose a network (testnet, sepolia-testnet, or mainnet)

### Deployment Steps

#### Option 1: Using Python (starknet.py)

```bash
# Install dependencies
pip install starknet-py

# Set environment variables
export STARKNET_NETWORK=sepolia-testnet
export STARKNET_PRIVATE_KEY=0x...
export STARKNET_ACCOUNT_ADDRESS=0x...

# Deploy
python3 deploy.py
```

#### Option 2: Using Starkli CLI

```bash
# Install starkli
curl https://get.starkli.sh | sh
source ~/.starkli/env

# Declare contract
starkli declare target/dev/starknet_mobile_counter_Counter.contract_class.json \
  --network sepolia-testnet \
  --account YOUR_ACCOUNT_ADDRESS \
  --private-key YOUR_PRIVATE_KEY

# Deploy contract (replace CLASS_HASH with output from declaration)
starkli deploy CLASS_HASH \
  --network sepolia-testnet \
  --account YOUR_ACCOUNT_ADDRESS \
  --private-key YOUR_PRIVATE_KEY
```

### Network RPC Endpoints

- **Sepolia Testnet**: `https://starknet-sepolia.public.blastapi.io/rpc/v0_7`
- **Testnet**: `https://starknet-testnet.public.blastapi.io/rpc/v0_7`
- **Mainnet**: `https://starknet-mainnet.public.blastapi.io/rpc/v0_7`

---

## Contract Interaction

### Reading Counter Value

```python
from starknet_py.contract import Contract

# Connect to contract
contract = await Contract.from_address(
    address=CONTRACT_ADDRESS,
    provider=provider,
    proxy_config=True
)

# Call view function
result = await contract.functions["get_counter"].call(user_address)
counter_value = result.value
```

### Incrementing Counter

```python
# Call external function
invoke_result = await account.execute(
    Call(
        to_addr=CONTRACT_ADDRESS,
        selector=get_selector_from_name("increase_counter"),
        calldata=[],
    ),
    max_fee=int(1e16),
)
await provider.wait_for_tx(invoke_result.transaction_hash)
```

---

## Generated Files

After extraction, the following files are available:

1. **extracted_contract_info.json** - Complete contract information
2. **Counter_ABI.json** - Contract ABI only
3. **contract_info.json** - Deployment information (after deployment)
4. **CONTRACT_INFO.md** - This file

---

## Security Notes

- The contract has no constructor, so no initialization is needed
- The counter starts at 0 (default value for felt252)
- Anyone can call `increase_counter` to increment the counter
- The `user` parameter in `get_counter` is currently not used in the implementation

---

## Testing

To test the contract locally, you can use:

- **Starknet Devnet** - Local Starknet network
- **Protostar** - Starknet testing framework
- **Starknet Foundry** - Alternative testing framework

---

## Support

For deployment issues or questions:

1. Check the deployment logs
2. Verify your account has sufficient ETH
3. Ensure you're using the correct network
4. Review the Starknet documentation: https://docs.starknet.io/

---

**Last Updated**: $(date)
**Contract Version**: 0.1.0

