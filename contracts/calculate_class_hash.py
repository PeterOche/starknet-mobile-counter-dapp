#!/usr/bin/env python3
"""
Calculate the class hash for the Counter contract.
This uses the contract class structure to compute the hash.
"""

import json
from pathlib import Path

def calculate_class_hash_from_sierra(contract_class_dict):
    """
    Calculate class hash from Sierra contract class.
    Note: This is a simplified version. The actual class hash calculation
    in Starknet uses a specific algorithm. For production, use starknet.py
    or starkli to calculate the exact hash.
    """
    # The actual class hash calculation requires:
    # 1. Serializing the contract class in a specific format
    # 2. Computing Keccak256 hash
    # 3. Converting to felt252
    
    # For now, we'll note that this requires proper Starknet libraries
    # The class hash will be computed during declaration on-chain
    return None

def main():
    contract_path = Path(__file__).parent / "target/dev/starknet_mobile_counter_Counter.contract_class.json"
    
    if not contract_path.exists():
        print(f"Error: Contract file not found at {contract_path}")
        return
    
    with open(contract_path, "r") as f:
        contract = json.load(f)
    
    print("="*70)
    print("📋 CONTRACT CLASS INFORMATION")
    print("="*70)
    print(f"\nContract Class Version: {contract.get('contract_class_version', 'N/A')}")
    print(f"Sierra Program Elements: {len(contract.get('sierra_program', []))}")
    
    entry_points = contract.get('entry_points_by_type', {})
    print(f"\nEntry Points:")
    print(f"  - EXTERNAL: {len(entry_points.get('EXTERNAL', []))}")
    print(f"  - L1_HANDLER: {len(entry_points.get('L1_HANDLER', []))}")
    print(f"  - CONSTRUCTOR: {len(entry_points.get('CONSTRUCTOR', []))}")
    
    print("\n" + "-"*70)
    print("ℹ️  Note: Class hash calculation requires declaration on-chain")
    print("   or using Starknet libraries (starknet.py, starkli, etc.)")
    print("   The class hash will be provided when you declare the contract.")
    print("-"*70)
    
    # Try to use starknet.py if available
    try:
        from starknet_py.hash.class_hash import compute_class_hash
        
        contract_class_dict = {
            "abi": contract.get("abi", []),
            "sierra_program": contract.get("sierra_program", []),
            "contract_class_version": contract.get("contract_class_version", "0.1.0"),
            "entry_points_by_type": contract.get("entry_points_by_type", {}),
        }
        
        class_hash = compute_class_hash(contract_class_dict)
        print(f"\n✅ Calculated Class Hash: {hex(class_hash)}")
        
        # Save to file
        info = {
            "class_hash": hex(class_hash),
            "contract_class_version": contract.get("contract_class_version", "0.1.0"),
        }
        
        output_path = Path(__file__).parent / "class_hash.json"
        with open(output_path, "w") as f:
            json.dump(info, f, indent=2)
        print(f"💾 Saved to: {output_path}")
        
    except ImportError:
        print("\n⚠️  starknet.py not installed. Install with: pip install starknet-py")
        print("   Or use the deployment script which will calculate it during declaration.")
    except Exception as e:
        print(f"\n⚠️  Could not calculate class hash: {e}")
        print("   The class hash will be available after contract declaration.")
    
    print("\n" + "="*70)

if __name__ == "__main__":
    main()

