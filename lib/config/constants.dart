class AppConstants {
  // Using pre-deployed Sepolia Counter Contract
  static const String contractAddress = '0x02d2a4804f83c34227314dba41d5c2f8a546a500d34e30bb5078fd36b5af2d77'; 
  
  // Sepolia Testnet RPC
  static const String rpcUrl = 'https://starknet-sepolia.public.blastapi.io/rpc/v0_7';

  // Privy Configuration
  static const String privyAppId = 'cmimr6t5301uljp0ccgj7j5b4';
  static const String privyAppClientId = 'client-WY6TNZacZjq6AW37vXQ22xn2GWuDFK8yWkehP1Wimt2WU'; 

  // Counter Contract ABI (from compiled contract)
  static const List<Map<String, dynamic>> counterAbi = [
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
  ];
}
