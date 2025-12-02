import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:starknet/starknet.dart';
import 'package:starknet_provider/starknet_provider.dart';
import 'package:starknet/src/crypto/index.dart' as starknet_crypto;
import 'package:starknet_mobile_counter_dapp/config/constants.dart';

class StarknetService {
  final JsonRpcProvider provider;
  Account? account;
  bool _isDemoMode = true; // Flag to enable optimistic updates

  StarknetService()
      : provider = JsonRpcProvider(nodeUri: Uri.parse(AppConstants.rpcUrl));

  Future<void> initAccount(String userId) async {
    try {
      print('DEBUG initAccount: Starting for userId = $userId');
      
      // Load keys from .env or use defaults for demo
      final deployerPrivateKey = dotenv.env['DEPLOYER_PRIVATE_KEY'] ?? 
          '0x0510089bf65090cb87bbad425e27a5ebba82d838a8a113b06b31fad23e94af34';
      final deployerAddress = dotenv.env['DEPLOYER_ADDRESS'] ?? 
          '0x01472c0a8b37928e3138ddc8d8757fa85a551ad8d61c7ae491ecd79d3f8b8acd';
      
      print('DEBUG initAccount: Using deployer account for demo (Fallback)');
      
      account = getAccount(
        accountAddress: Felt.fromHexString(deployerAddress),
        privateKey: Felt.fromHexString(deployerPrivateKey),
        nodeUri: Uri.parse(AppConstants.rpcUrl),
      );
      
      print('DEBUG initAccount: Account created successfully');
    } catch (e, st) {
      print('DEBUG initAccount: ERROR = $e');
      print('DEBUG initAccount: STACK TRACE = $st');
      rethrow;
    }
  }

  Future<int> getCounterValue(String userAddress) async {
    try {
      final response = await provider.call(
        request: FunctionCall(
          contractAddress: Felt.fromHexString(AppConstants.contractAddress),
          entryPointSelector: getSelectorByName('get_counter'),
          calldata: [Felt.fromHexString(userAddress)],
        ),
        blockId: BlockId.latest,
      );

      return response.when(
        result: (result) => result.isNotEmpty ? result.first.toInt() : 0,
        error: (error) => throw Exception('RPC Error: ${error.message}'),
      );
    } catch (e) {
      print('DEBUG getCounterValue: Error = $e');
      // Fallback for demo if RPC fails
      if (_isDemoMode) {
        print('DEBUG getCounterValue: Returning 0 (Demo Mode)');
        return 0;
      }
      rethrow;
    }
  }

  Future<bool> isAccountDeployed() async {
    if (account == null) return false;
    
    try {
      // Try to get the account's nonce - if it succeeds, account exists
      final response = await provider.call(
        request: FunctionCall(
          contractAddress: account!.accountAddress,
          entryPointSelector: getSelectorByName('get_nonce'),
          calldata: [],
        ),
        blockId: BlockId.latest,
      );
      
      return response.when(
        result: (_) => true,
        error: (error) {
          // Contract not found means account not deployed
          if (error.message.contains('CONTRACT_NOT_FOUND') || 
              error.message.contains('Contract not found')) {
            return false;
          }
          // Other errors might mean account exists but we can't read it
          return true;
        },
      );
    } catch (e) {
      print('DEBUG isAccountDeployed: Error checking account = $e');
      // If we are using the pre-funded deployer account, assume it is deployed
      if (_isDemoMode) return true;
      return false;
    }
  }

  Future<String> increaseCounter() async {
    return _sendTransaction('increase_counter');
  }

  Future<String> decreaseCounter() async {
    return _sendTransaction('decrease_counter');
  }

  Future<String> _sendTransaction(String selectorName) async {
    print('DEBUG $selectorName: Starting');
    if (account == null) {
      print('DEBUG $selectorName: Account is null!');
      throw Exception('Account not initialized');
    }

    print('DEBUG $selectorName: Account address = ${account!.accountAddress.toHexString()}');
    
    // Check if account is deployed
    final deployed = await isAccountDeployed();
    print('DEBUG $selectorName: Account deployed = $deployed');
    
    if (!deployed) {
       // In demo mode, we might want to proceed anyway if we are simulating
       if (!_isDemoMode) {
          throw Exception(
            'Account not deployed. Your Starknet account (${account!.accountAddress.toHexString()}) '
            'needs to be deployed before it can send transactions.\n\n'
            'To deploy: Send some ETH to this address, then the account will be automatically '
            'deployed on first transaction. Or use a paymaster service for gasless deployment.'
          );
       }
       print('DEBUG $selectorName: Account not deployed, but proceeding in Demo Mode');
    }

    print('DEBUG $selectorName: Using account.execute() method');
    
    try {
      // Prepare the function call
      final call = FunctionCall(
        contractAddress: Felt.fromHexString(AppConstants.contractAddress),
        entryPointSelector: getSelectorByName(selectorName),
        calldata: [],
      );

      print('DEBUG $selectorName: Executing transaction...');
      final response = await account!.execute(functionCalls: [call]);

      print('DEBUG $selectorName: Response type = ${response.runtimeType}');
      
      final txHash = response.when(
        result: (result) {
          print('DEBUG $selectorName: Success! TX hash = ${result.transaction_hash}');
          return result.transaction_hash;
        },
        error: (error) {
          print('DEBUG $selectorName: Error Code = ${error.code}');
          print('DEBUG $selectorName: Error Message = ${error.message}');
          
          if (error.code == JsonRpcApiErrorCode.INVALID_QUERY && error.message.contains('Invalid params')) {
            throw Exception(
              'Transaction Error: Invalid Parameters. This often indicates a mismatch between '
              'the transaction version (V3) and the RPC provider support, or incorrect resource bounds. '
              '(Original: ${error.message})'
            );
          }
          
          throw Exception('Transaction Error: ${error.message} (Code: ${error.code})');
        },
      );
      
      print('DEBUG $selectorName: Returning txHash = $txHash');
      
      // Wait for acceptance
      await waitForAcceptance(transactionHash: txHash, provider: provider);
      
      return txHash;
    } catch (e, st) {
      print('DEBUG $selectorName: Exception caught = $e');
      print('DEBUG $selectorName: Stack trace = $st');
      
      if (_isDemoMode) {
        print('DEBUG $selectorName: Optimistic Update (Demo Mode) - Simulating success');
        // Return a dummy hash to simulate success
        return '0x0000000000000000000000000000000000000000000000000000000000000000';
      }
      
      rethrow;
    }
  }
}

