# Counter Contract - Deployment and Extraction

This directory contains the Counter smart contract for Starknet and all necessary deployment scripts.

## Quick Start

### Extract Contract Information

```bash
python3 extract_contract.py
```

This will generate:
- `extracted_contract_info.json` - Full contract details
- `Counter_ABI.json` - Contract ABI

### Deploy Contract

```bash
# Set environment variables
export STARKNET_NETWORK=sepolia-testnet
export STARKNET_PRIVATE_KEY=0x...
export STARKNET_ACCOUNT_ADDRESS=0x...

# Deploy
python3 deploy.py
```

## Files

### Contract Files
- `src/lib.cairo` - Source code
- `target/dev/starknet_mobile_counter_Counter.contract_class.json` - Compiled contract

### Scripts
- `extract_contract.py` - Extract contract information
- `deploy.py` - Deploy contract using Python
- `calculate_class_hash.py` - Calculate class hash
- `deploy_with_starkli.sh` - Deploy using Starkli CLI

### Documentation
- `CONTRACT_INFO.md` - Complete contract documentation
- `DEPLOYMENT.md` - Deployment guide

### Generated Files (after extraction)
- `extracted_contract_info.json` - Contract information
- `Counter_ABI.json` - Contract ABI
- `contract_info.json` - Deployment info (after deployment)

## Contract Functions

1. **get_counter(user: felt252) -> felt252**
   - View function to read counter value
   - Selector: `0x3370263ab53343580e77063a719a5865004caff7f367ec136a6cdd34b6786ca`

2. **increase_counter()**
   - External function to increment counter
   - Selector: `0x245f9bea6574169db91599999bf914dd43aebc1e0544bdc96c9f401a52b8768`

## Requirements

- Python 3.7+
- Scarb (for compilation)
- Starknet account with ETH (for deployment)

## Installation

```bash
# Install Python dependencies
pip install starknet-py

# Or install all at once
pip install -r requirements.txt  # if you create one
```

## Network Configuration

Default network is `sepolia-testnet`. Change by setting:
```bash
export STARKNET_NETWORK=testnet  # or mainnet
```

## More Information

See `CONTRACT_INFO.md` for complete contract documentation and `DEPLOYMENT.md` for detailed deployment instructions.

