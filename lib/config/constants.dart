class AppConstants {
  // Deployed Counter Contract on Sepolia
  static const String contractAddress = '0x030397ff0ab89f249a0fbbfa378a4a2c8c1d91d660e153b15bfae84bfe990361'; 
  
  // Sepolia Testnet RPC (Lava)
  static const String rpcUrl = 'https://rpc.starknet-testnet.lava.build';

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
