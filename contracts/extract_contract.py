#!/usr/bin/env python3
"""
Extract contract information from compiled Starknet contract.
This script extracts all necessary information without requiring deployment.
"""

import json
import hashlib
from pathlib import Path
from typing import Dict, Any

def calculate_keccak256(data: bytes) -> str:
    """Calculate Keccak256 hash."""
    # Note: Python's hashlib doesn't have Keccak256, but for class hash calculation
    # we'll use the contract class structure. In practice, you'd use a proper Keccak256 library.
    # For now, we'll extract what we can without external dependencies.
    return hashlib.sha256(data).hexdigest()

def load_contract() -> Dict[str, Any]:
    """Load the compiled Sierra contract."""
    contract_path = Path(__file__).parent / "target/dev/starknet_mobile_counter_Counter.contract_class.json"
    
    if not contract_path.exists():
        raise FileNotFoundError(f"Contract file not found at {contract_path}")
    
    with open(contract_path, "r") as f:
        return json.load(f)

def extract_abi(contract: Dict[str, Any]) -> list:
    """Extract ABI from contract."""
    return contract.get("abi", [])

def extract_entry_points(contract: Dict[str, Any]) -> Dict[str, Any]:
    """Extract entry points from contract."""
    return contract.get("entry_points_by_type", {})

def extract_function_info(contract: Dict[str, Any]) -> Dict[str, Any]:
    """Extract function information."""
    entry_points = extract_entry_points(contract)
    functions = {}
    
    # External functions
    for func in entry_points.get("EXTERNAL", []):
        selector = func.get("selector", "")
        # Handle both hex string and integer formats
        if isinstance(selector, str):
            selector_hex = selector
        else:
            selector_hex = hex(selector)
        func_idx = func.get("function_idx", "")
        functions[selector_hex] = {
            "selector": selector_hex,
            "function_index": func_idx,
            "type": "EXTERNAL"
        }
    
    return functions

def extract_contract_summary(contract: Dict[str, Any]) -> Dict[str, Any]:
    """Extract a comprehensive summary of the contract."""
    abi = extract_abi(contract)
    entry_points = extract_entry_points(contract)
    functions = extract_function_info(contract)
    
    # Find function names from ABI
    function_names = {}
    for item in abi:
        if item.get("type") == "interface":
            for interface_item in item.get("items", []):
                if interface_item.get("type") == "function":
                    func_name = interface_item.get("name", "")
                    # Calculate selector from name
                    # Note: This is a simplified version. Actual selector calculation
                    # requires Keccak256 hashing of the function signature
                    function_names[func_name] = interface_item
    
    return {
        "contract_name": "Counter",
        "contract_class_version": contract.get("contract_class_version", "0.1.0"),
        "abi": abi,
        "entry_points": entry_points,
        "functions": functions,
        "function_definitions": function_names,
        "sierra_program_length": len(contract.get("sierra_program", [])),
    }

def save_extracted_info(info: Dict[str, Any], output_path: Path):
    """Save extracted information to JSON file."""
    with open(output_path, "w") as f:
        json.dump(info, f, indent=2)
    print(f"✅ Saved contract info to: {output_path}")

def print_summary(info: Dict[str, Any]):
    """Print a human-readable summary."""
    print("\n" + "="*70)
    print("📄 EXTRACTED CONTRACT INFORMATION")
    print("="*70)
    print(f"\nContract Name: {info['contract_name']}")
    print(f"Contract Class Version: {info['contract_class_version']}")
    print(f"Sierra Program Length: {info['sierra_program_length']} elements")
    
    print("\n" + "-"*70)
    print("📋 Functions:")
    print("-"*70)
    for func_name, func_def in info['function_definitions'].items():
        print(f"\n  Function: {func_name}")
        print(f"    Type: {func_def.get('type', 'N/A')}")
        print(f"    State Mutability: {func_def.get('state_mutability', 'N/A')}")
        
        inputs = func_def.get('inputs', [])
        if inputs:
            print(f"    Inputs:")
            for inp in inputs:
                print(f"      - {inp.get('name', 'N/A')}: {inp.get('type', 'N/A')}")
        
        outputs = func_def.get('outputs', [])
        if outputs:
            print(f"    Outputs:")
            for out in outputs:
                print(f"      - {out.get('type', 'N/A')}")
    
    print("\n" + "-"*70)
    print("🔑 Entry Points:")
    print("-"*70)
    for selector, func_info in info['functions'].items():
        print(f"  Selector: {selector}")
        print(f"    Index: {func_info['function_index']}")
        print(f"    Type: {func_info['type']}")
    
    print("\n" + "="*70)

def main():
    print("🔍 Extracting contract information...")
    
    try:
        contract = load_contract()
        info = extract_contract_summary(contract)
        
        # Save to file
        output_path = Path(__file__).parent / "extracted_contract_info.json"
        save_extracted_info(info, output_path)
        
        # Save ABI separately
        abi_path = Path(__file__).parent / "Counter_ABI.json"
        with open(abi_path, "w") as f:
            json.dump(info['abi'], f, indent=2)
        print(f"✅ Saved ABI to: {abi_path}")
        
        # Print summary
        print_summary(info)
        
        print("\n✅ Extraction complete!")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()

