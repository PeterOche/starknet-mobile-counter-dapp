#!/usr/bin/env python3
"""Simple deployment script that actually works."""
import json
import os
import sys
from pathlib import Path

# Try to use starknet.py, install if needed
try:
    from starknet_py.net.account.account import Account
    from starknet_py.net.full_node_client import FullNodeClient
    from starknet_py.net.models import StarknetChainId
    from starknet_py.net.signer.stark_curve_signer import KeyPair
except ImportError:
    print("Installing starknet-py...")
    os.system(f"{sys.executable} -m pip install --user starknet-py --quiet")
    from starknet_py.net.account.account import Account
    from starknet_py.net.full_node_client import FullNodeClient
    from starknet_py.net.models import StarknetChainId
    from starknet_py.net.signer.stark_curve_signer import KeyPair

# Your credentials
NETWORK = "sepolia-testnet"
PRIVATE_KEY = "0x0510089bf65090cb87bbad425e27a5ebba82d838a8a113b06b31fad23e94af34"
ACCOUNT_ADDRESS = "0x00268061A3489a8d2A82888Eacd3338940A83A9a33520680D75f0dAFB90Ce707"
RPC_URL = "https://starknet-sepolia.public.blastapi.io/rpc/v0_7"
CONTRACT_FILE = "target/dev/starknet_mobile_counter_Counter.contract_class.json"

def main():
    print("=" * 60)
    print("🚀 DEPLOYING COUNTER CONTRACT")
    print("=" * 60)
    print(f"Network: {NETWORK}")
    print(f"Account: {ACCOUNT_ADDRESS}\n")
    
    # Load contract
    contract_path = Path(CONTRACT_FILE)
    if not contract_path.exists():
        print(f"❌ Error: Contract file not found: {CONTRACT_FILE}")
        sys.exit(1)
    
    with open(contract_path, "r") as f:
        sierra_contract = json.load(f)
    
    print("✅ Contract loaded\n")
    
    # Setup client and account
    print("📡 Connecting to network...")
    client = FullNodeClient(node_url=RPC_URL)
    
    private_key_int = int(PRIVATE_KEY, 16)
    key_pair = KeyPair.from_private_key(private_key_int)
    account_address_int = int(ACCOUNT_ADDRESS, 16)
    
    account = Account(
        client=client,
        address=account_address_int,
        key_pair=key_pair,
        chain=StarknetChainId.SEPOLIA_TESTNET,
    )
    print("✅ Connected\n")
    
    # Declare
    print("📋 Declaring contract class...")
    declare_result = account.declare(compiled_contract=sierra_contract, max_fee=int(1e16))
    print(f"   Transaction: {hex(declare_result.transaction_hash)}")
    
    print("⏳ Waiting for declaration...")
    client.wait_for_tx(declare_result.transaction_hash)
    
    class_hash = declare_result.class_hash
    print(f"✅ Declared! Class Hash: {hex(class_hash)}\n")
    
    # Deploy
    print("📦 Deploying contract instance...")
    deploy_result = account.deploy_contract(
        class_hash=class_hash,
        constructor_args=[],
        max_fee=int(1e16),
    )
    print(f"   Transaction: {hex(deploy_result.hash)}")
    
    print("⏳ Waiting for deployment...")
    client.wait_for_tx(deploy_result.hash)
    
    contract_address = deploy_result.contract_address
    print(f"✅ Deployed! Contract Address: {hex(contract_address)}\n")
    
    # Save info
    info = {
        "network": NETWORK,
        "contract_name": "Counter",
        "contract_address": hex(contract_address),
        "class_hash": hex(class_hash),
        "declaration_tx": hex(declare_result.transaction_hash),
        "deployment_tx": hex(deploy_result.hash),
    }
    
    with open("contract_deployment_info.json", "w") as f:
        json.dump(info, f, indent=2)
    
    print("=" * 60)
    print("✅ DEPLOYMENT COMPLETE!")
    print("=" * 60)
    print(f"Contract Address: {hex(contract_address)}")
    print(f"Class Hash: {hex(class_hash)}")
    print(f"\n💾 Saved to: contract_deployment_info.json")
    print("=" * 60)

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

