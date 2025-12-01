#!/usr/bin/env python3
"""
Deploy Counter contract to Starknet Sepolia using starknet-py
"""
import asyncio
import json
from pathlib import Path
from starknet_py.net.account.account import Account
from starknet_py.net.full_node_client import FullNodeClient
from starknet_py.net.models import StarknetChainId
from starknet_py.net.signer.stark_curve_signer import KeyPair

# Configuration
PRIVATE_KEY = 0x0510089bf65090cb87bbad425e27a5ebba82d838a8a113b06b31fad23e94af34
ACCOUNT_ADDRESS = 0x01472c0a8b37928e3138ddc8d8757fa85a551ad8d61c7ae491ecd79d3f8b8acd
RPC_URL = "https://rpc.starknet-testnet.lava.build"
CONTRACT_FILE = "target/dev/starknet_mobile_counter_Counter.contract_class.json"

async def main():
    print("🚀 Deploying Counter Contract to Starknet Sepolia")
    print("=" * 60)
    
    # Load contract
    contract_path = Path(__file__).parent / CONTRACT_FILE
    with open(contract_path, 'r') as f:
        contract_json = json.load(f)
    
    # Setup client and account
    client = FullNodeClient(node_url=RPC_URL)
    key_pair = KeyPair.from_private_key(PRIVATE_KEY)
    account = Account(
        client=client,
        address=ACCOUNT_ADDRESS,
        key_pair=key_pair,
        chain=StarknetChainId.SEPOLIA
    )
    
    print(f"📍 Account: {hex(ACCOUNT_ADDRESS)}")
    print(f"🔑 Public Key: {hex(key_pair.public_key)}")
    
    # Declare contract
    print("\n📝 Declaring contract...")
    declare_result = await account.sign_declare_v2(
        compiled_contract=contract_json,
        max_fee=int(1e16)  # 0.01 ETH max fee
    )
    
    await account.client.wait_for_tx(declare_result.transaction_hash)
    class_hash = declare_result.class_hash
    
    print(f"✅ Contract declared!")
    print(f"   Class Hash: {hex(class_hash)}")
    print(f"   Tx Hash: {hex(declare_result.transaction_hash)}")
    
    # Deploy contract
    print("\n🚢 Deploying contract...")
    deploy_result = await account.sign_invoke_v1(
        calls=account.get_deploy_account_calls(
            class_hash=class_hash,
            constructor_calldata=[]
        ),
        max_fee=int(1e16)
    )
    
    await account.client.wait_for_tx(deploy_result.transaction_hash)
    
    # Get contract address from deploy transaction
    receipt = await account.client.get_transaction_receipt(deploy_result.transaction_hash)
    contract_address = receipt.contract_address if hasattr(receipt, 'contract_address') else None
    
    print(f"✅ Contract deployed!")
    print(f"   Contract Address: {hex(contract_address) if contract_address else 'Check transaction'}")
    print(f"   Tx Hash: {hex(deploy_result.transaction_hash)}")
    
    print("\n" + "=" * 60)
    print("🎉 Deployment Complete!")
    print(f"\n📋 Update your Flutter app constants.dart with:")
    print(f"   contractAddress = '{hex(contract_address) if contract_address else 'SEE_TX'}';")
    print(f"   rpcUrl = '{RPC_URL}';")

if __name__ == "__main__":
    asyncio.run(main())
