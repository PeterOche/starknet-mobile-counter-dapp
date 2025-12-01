# Counter Smart Contract - Extracted Information

## ✅ Contract Successfully Extracted

All smart contract information has been extracted and is ready for deployment.

---

## Contract Details

### Basic Information
- **Contract Name**: Counter
- **Package**: starknet_mobile_counter
- **Contract Class Version**: 0.1.0
- **Source File**: `src/lib.cairo`
- **Compiled Contract**: `target/dev/starknet_mobile_counter_Counter.contract_class.json`
- **Sierra Program Elements**: 226

### Class Hash
- **Class Hash**: `0x04163508eca596f199fbf9efb45355fa391142989f2310484baa066feb390ad0`
- **Calculated using**: starkli class-hash
- **Status**: ✅ Verified

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

## Contract Functions

### 1. get_counter

- **Function Signature**: `get_counter(user: felt252) -> felt252`
- **Type**: View function (read-only)
- **Function Selector**: `0x3370263ab53343580e77063a719a5865004caff7f367ec136a6cdd34b6786ca`
- **Function Index**: 0
- **Inputs**:
  - `user`: `felt252`
- **Outputs**:
  - Returns: `felt252` - The current counter value
- **State Mutability**: View

**Description**: Returns the current value of the counter. Note: The `user` parameter is currently not used in the implementation.

### 2. increase_counter

- **Function Signature**: `increase_counter()`
- **Type**: External function (writes to storage)
- **Function Selector**: `0x245f9bea6574169db91599999bf914dd43aebc1e0544bdc96c9f401a52b8768`
- **Function Index**: 1
- **Inputs**: None
- **Outputs**: None
- **State Mutability**: External

**Description**: Increments the counter by 1. This function writes to storage and requires a transaction.

---

## Storage Layout

The contract has a single storage variable:

- **counter**: `felt252`
  - Storage slot: 0 (default)
  - Initial value: 0
  - Description: Stores the current counter value

---

## Entry Points

| Type | Count | Functions |
|------|-------|-----------|
| **EXTERNAL** | 2 | `get_counter`, `increase_counter` |
| **L1_HANDLER** | 0 | None |
| **CONSTRUCTOR** | 0 | No constructor (uses default initialization) |

---

## Contract ABI

The complete ABI is available in `Counter_ABI.json`:

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

## Generated Files

All contract information has been extracted and saved to:

1. ✅ **extracted_contract_info.json** - Complete contract information including ABI, entry points, and function definitions
2. ✅ **Counter_ABI.json** - Contract ABI in standard format
3. ✅ **class_hash.json** - Pre-calculated class hash
4. ✅ **target/dev/starknet_mobile_counter_Counter.contract_class.json** - Compiled Sierra contract (required for deployment)

---

## Deployment Information

### Prerequisites

1. **Starknet Account** with ETH for gas fees
2. **Private Key** of the deploying account
3. **Account Address** of the deploying account
4. **Network Selection**: Choose one:
   - `sepolia-testnet` (Recommended for testing)
   - `testnet`
   - `mainnet`

### Deployment Status

- ✅ Contract compiled
- ✅ Contract information extracted
- ✅ Class hash calculated
- ✅ Starkli installed and ready
- ⏳ **Ready for deployment** (requires credentials)

### Quick Deployment

Set environment variables and deploy:

```bash
# Set your credentials
export STARKNET_NETWORK=sepolia-testnet
export STARKNET_PRIVATE_KEY=0x...
export STARKNET_ACCOUNT_ADDRESS=0x...

# Deploy
bash deploy_with_starkli.sh
```

---

## Contract Interaction Examples

### Reading Counter Value (View Call)

```python
from starknet_py.contract import Contract

# Connect to contract
contract = await Contract.from_address(
    address=CONTRACT_ADDRESS,
    provider=provider,
)

# Call view function
result = await contract.functions["get_counter"].call(0)  # user param (unused)
counter_value = result.value
print(f"Counter value: {counter_value}")
```

### Incrementing Counter (Transaction)

```python
from starknet_py.net.account.account import Account
from starknet_py.net.client_models import Call
from starknet_py.hash.selector import get_selector_from_name

# Invoke function
invoke_result = await account.execute(
    Call(
        to_addr=CONTRACT_ADDRESS,
        selector=get_selector_from_name("increase_counter"),
        calldata=[],
    ),
    max_fee=int(1e16),
)

await provider.wait_for_tx(invoke_result.transaction_hash)
print("Counter incremented!")
```

---

## Security Notes

- The contract has no constructor, so no initialization is needed
- The counter starts at 0 (default value for felt252)
- Anyone can call `increase_counter` to increment the counter
- The `user` parameter in `get_counter` is currently not used in the implementation (may be intended for future use)

---

## Tools Status

- ✅ **Starkli**: Installed (v0.4.2)
- ✅ **Contract Compiled**: Yes
- ✅ **Class Hash Calculated**: Yes
- ⚠️  **Python starknet-py**: Not installed (optional, can use starkli instead)

---

## Next Steps

1. ✅ Contract compiled and extracted
2. ✅ Class hash calculated
3. ✅ Deployment scripts ready
4. ⏳ Set deployment credentials
5. ⏳ Deploy to chosen network
6. ⏳ Save deployed contract address

---

**Extracted**: 2024-12-01
**Contract Version**: 0.1.0
**Status**: ✅ Ready for Deployment

