#!/usr/bin/env python3
"""
Deploy the Counter contract to Starknet and extract contract information.
"""

import json
import os
import sys
from pathlib import Path

try:
    from starknet_py.net.account.account import Account
    from starknet_py.net.client_models import Call
    from starknet_py.net.full_node_client import FullNodeClient
    from starknet_py.net.models import StarknetChainId
    from starknet_py.net.signer.stark_curve_signer import KeyPair
    from starknet_py.contract import Contract
    from starknet_py.hash.selector import get_selector_from_name
    from starknet_py.net.client_errors import ClientError
except ImportError:
    print("Installing required dependencies...")
    os.system(f"{sys.executable} -m pip install -q starknet-py")
    from starknet_py.net.account.account import Account
    from starknet_py.net.client_models import Call
    from starknet_py.net.full_node_client import FullNodeClient
    from starknet_py.net.models import StarknetChainId
    from starknet_py.net.signer.stark_curve_signer import KeyPair
    from starknet_py.contract import Contract
    from starknet_py.hash.selector import get_selector_from_name
    from starknet_py.net.client_errors import ClientError

# Configuration
NETWORK = os.getenv("STARKNET_NETWORK", "testnet")  # testnet, mainnet, or sepolia-testnet
RPC_URL = os.getenv("STARKNET_RPC_URL", None)

# Network configurations
NETWORKS = {
    "testnet": {
        "rpc": "https://starknet-testnet.public.blastapi.io/rpc/v0_7",
        "chain_id": StarknetChainId.TESTNET,
    },
    "sepolia-testnet": {
        "rpc": "https://starknet-sepolia.public.blastapi.io/rpc/v0_7",
        "chain_id": StarknetChainId.SEPOLIA_TESTNET,
    },
    "mainnet": {
        "rpc": "https://starknet-mainnet.public.blastapi.io/rpc/v0_7",
        "chain_id": StarknetChainId.MAINNET,
    },
}

def load_sierra_contract():
    """Load the compiled Sierra contract."""
    contract_path = Path(__file__).parent / "target/dev/starknet_mobile_counter_Counter.contract_class.json"
    
    if not contract_path.exists():
        print(f"Error: Contract file not found at {contract_path}")
        print("Please compile the contract first using: scarb build")
        sys.exit(1)
    
    with open(contract_path, "r") as f:
        return json.load(f)

def deploy_contract():
    """Deploy the Counter contract."""
    print(f"🚀 Deploying Counter contract to {NETWORK}...")
    
    # Load contract
    sierra_contract = load_sierra_contract()
    
    # Setup network
    if NETWORK not in NETWORKS:
        print(f"Error: Unknown network '{NETWORK}'. Choose from: {list(NETWORKS.keys())}")
        sys.exit(1)
    
    network_config = NETWORKS[NETWORK]
    rpc_url = RPC_URL or network_config["rpc"]
    
    print(f"📡 Connecting to RPC: {rpc_url}")
    
    # Initialize client
    client = FullNodeClient(node_url=rpc_url)
    
    # For deployment, we need an account
    # Try to get from environment or use a placeholder
    private_key = os.getenv("STARKNET_PRIVATE_KEY")
    
    if not private_key:
        print("\n⚠️  Warning: STARKNET_PRIVATE_KEY not set!")
        print("To deploy, you need:")
        print("1. A Starknet account with ETH for gas fees")
        print("2. Your private key set as environment variable: export STARKNET_PRIVATE_KEY=your_private_key")
        print("\nFor testing, you can use a devnet account or get testnet ETH from a faucet.")
        print("\nAttempting to use a test account (this will likely fail on real networks)...")
        private_key = "0x1"  # Placeholder
    
    try:
        private_key_int = int(private_key, 16) if private_key.startswith("0x") else int(private_key)
        key_pair = KeyPair.from_private_key(private_key_int)
        
        # Get account address (assuming it's derived or provided)
        account_address = os.getenv("STARKNET_ACCOUNT_ADDRESS")
        
        if not account_address:
            print("\n⚠️  Warning: STARKNET_ACCOUNT_ADDRESS not set!")
            print("Please set your account address: export STARKNET_ACCOUNT_ADDRESS=your_address")
            print("\nFor now, extracting contract info without deployment...")
            return extract_contract_info(sierra_contract)
        
        account_address_int = int(account_address, 16) if account_address.startswith("0x") else int(account_address)
        account = Account(
            client=client,
            address=account_address_int,
            key_pair=key_pair,
            chain=network_config["chain_id"],
        )
        
        print(f"📝 Account: {hex(account_address_int)}")
        
        # Declare the contract class
        print("\n📋 Declaring contract class...")
        declare_result = account.declare(compiled_contract=sierra_contract, max_fee=int(1e16))
        
        # Wait for transaction
        print("⏳ Waiting for declaration transaction...")
        client.wait_for_tx(declare_result.transaction_hash)
        
        class_hash = declare_result.class_hash
        print(f"✅ Contract class declared!")
        print(f"   Class Hash: {hex(class_hash)}")
        print(f"   Transaction: {hex(declare_result.transaction_hash)}")
        
        # Deploy the contract (no constructor parameters needed)
        print("\n📦 Deploying contract instance...")
        deploy_result = account.deploy_contract(
            class_hash=class_hash,
            constructor_args=[],
            max_fee=int(1e16),
        )
        
        # Wait for transaction
        print("⏳ Waiting for deployment transaction...")
        client.wait_for_tx(deploy_result.hash)
        
        contract_address = deploy_result.contract_address
        print(f"✅ Contract deployed!")
        print(f"   Contract Address: {hex(contract_address)}")
        print(f"   Transaction: {hex(deploy_result.hash)}")
        
        # Save contract info
        contract_info = {
            "network": NETWORK,
            "contract_name": "Counter",
            "contract_address": hex(contract_address),
            "class_hash": hex(class_hash),
            "declaration_tx": hex(declare_result.transaction_hash),
            "deployment_tx": hex(deploy_result.hash),
            "abi": sierra_contract.get("abi", []),
            "sierra_program": sierra_contract.get("sierra_program", []),
        }
        
        save_contract_info(contract_info)
        return contract_info
        
    except Exception as e:
        print(f"\n❌ Deployment error: {e}")
        print("\nAttempting to extract contract info without deployment...")
        return extract_contract_info(sierra_contract)

def extract_contract_info(sierra_contract):
    """Extract contract information from the compiled contract."""
    print("\n📄 Extracting contract information...")
    
    # Calculate class hash from Sierra program
    try:
        from starknet_py.hash.class_hash import compute_class_hash
        
        # Prepare contract class for hashing
        contract_class_dict = {
            "abi": sierra_contract.get("abi", []),
            "sierra_program": sierra_contract.get("sierra_program", []),
            "contract_class_version": sierra_contract.get("contract_class_version", "0.1.0"),
            "entry_points_by_type": sierra_contract.get("entry_points_by_type", {}),
        }
        
        class_hash = compute_class_hash(contract_class_dict)
        print(f"✅ Calculated Class Hash: {hex(class_hash)}")
        
    except Exception as e:
        print(f"⚠️  Could not calculate class hash: {e}")
        class_hash = None
    
    # Extract function selectors
    entry_points = sierra_contract.get("entry_points_by_type", {})
    external_functions = entry_points.get("EXTERNAL", [])
    
    print(f"\n📋 Contract Functions:")
    for func in external_functions:
        selector = func.get("selector", "unknown")
        func_idx = func.get("function_idx", "unknown")
        print(f"   - Selector: {hex(selector)} (idx: {func_idx})")
    
    # Get ABI
    abi = sierra_contract.get("abi", [])
    
    contract_info = {
        "contract_name": "Counter",
        "class_hash": hex(class_hash) if class_hash else "N/A",
        "abi": abi,
        "entry_points": entry_points,
        "sierra_program_hash": "N/A",  # Would need to compute
    }
    
    save_contract_info(contract_info)
    return contract_info

def save_contract_info(contract_info):
    """Save contract information to a JSON file."""
    output_path = Path(__file__).parent / "contract_info.json"
    
    with open(output_path, "w") as f:
        json.dump(contract_info, f, indent=2)
    
    print(f"\n💾 Contract information saved to: {output_path}")
    
    # Also save ABI separately
    abi_path = Path(__file__).parent / "Counter_ABI.json"
    with open(abi_path, "w") as f:
        json.dump(contract_info.get("abi", []), f, indent=2)
    print(f"💾 ABI saved to: {abi_path}")

def print_summary(contract_info):
    """Print a summary of the contract information."""
    print("\n" + "="*60)
    print("📊 CONTRACT DEPLOYMENT SUMMARY")
    print("="*60)
    print(f"Contract Name: {contract_info.get('contract_name', 'Counter')}")
    
    if "contract_address" in contract_info:
        print(f"Contract Address: {contract_info['contract_address']}")
    if "class_hash" in contract_info:
        print(f"Class Hash: {contract_info['class_hash']}")
    if "network" in contract_info:
        print(f"Network: {contract_info['network']}")
    if "declaration_tx" in contract_info:
        print(f"Declaration TX: {contract_info['declaration_tx']}")
    if "deployment_tx" in contract_info:
        print(f"Deployment TX: {contract_info['deployment_tx']}")
    
    print("\n" + "="*60)

if __name__ == "__main__":
    print("="*60)
    print("🔷 STARKNET COUNTER CONTRACT DEPLOYMENT")
    print("="*60)
    
    contract_info = deploy_contract()
    print_summary(contract_info)
    
    print("\n✅ Done!")

