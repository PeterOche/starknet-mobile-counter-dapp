import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:starknet_provider/starknet_provider.dart';

/// Custom provider that patches V3 invoke transactions to include l1_data_gas
class PatchedJsonRpcProvider extends JsonRpcProvider {
  PatchedJsonRpcProvider({required super.nodeUri});

  @override
  Future<InvokeTransactionResponse> addInvokeTransaction(
      InvokeTransactionRequest request) async {
    print('DEBUG PatchedProvider: addInvokeTransaction called');
    
    // Convert the request to JSON
    final requestJson = request.toJson();
    print('DEBUG PatchedProvider: Original request JSON: $requestJson');
    
    // Check if this is a V3 transaction
    final txJson = requestJson['invoke_transaction'] as Map<String, dynamic>?;
    if (txJson != null && txJson['version'] == '0x3') {
      print('DEBUG PatchedProvider: Detected V3 transaction, applying patch');
      
      // Patch: Add l1_data_gas to resource_bounds if missing
      final resourceBounds = txJson['resource_bounds'] as Map<String, dynamic>?;
      if (resourceBounds != null) {
        print('DEBUG PatchedProvider: Current resource_bounds: $resourceBounds');
        
        if (!resourceBounds.containsKey('l1_data_gas')) {
          print('DEBUG PatchedProvider: Adding l1_data_gas field');
          resourceBounds['l1_data_gas'] = {
            'max_amount': '0x0',
            'max_price_per_unit': '0x0',
          };
        }
        
        print('DEBUG PatchedProvider: Patched resource_bounds: $resourceBounds');
      }
    }
    
    // Make the HTTP request manually with patched JSON
    final body = jsonEncode({
      'jsonrpc': '2.0',
      'method': 'starknet_addInvokeTransaction',
      'params': requestJson,
      'id': 1,
    });
    
    print('DEBUG PatchedProvider: Sending request body: $body');
    
    final response = await http.post(
      nodeUri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    
    print('DEBUG PatchedProvider: Response status: ${response.statusCode}');
    print('DEBUG PatchedProvider: Response body: ${response.body}');
    
    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    return InvokeTransactionResponse.fromJson(responseJson);
  }
}
