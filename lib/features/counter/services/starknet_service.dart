import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:starknet/starknet.dart';
import 'package:starknet_provider/starknet_provider.dart';
import 'package:starknet_mobile_counter_dapp/config/constants.dart';

class StarknetService {
  final JsonRpcProvider provider;
  Account? account;

  StarknetService()
      : provider = JsonRpcProvider(nodeUri: Uri.parse(AppConstants.rpcUrl));

  Future<void> initAccount(String userId) async {
    try {
      print('DEBUG initAccount: Starting for userId = $userId');
      
      // Derive private key from user ID (deterministic)
      const salt = 'starknet-mobile-counter-salt';
      final bytes = utf8.encode('$userId$salt');
      final digest = sha256.convert(bytes);
      final privateKeyInt = BigInt.parse(digest.toString(), radix: 16);
      
      print('DEBUG initAccount: privateKeyInt = $privateKeyInt');
      
      // Ensure the private key fits within the Starknet field
      // Field size is 2^251 + 17 * 2^192 + 1
      final fieldSize = BigInt.parse('800000000000011000000000000000000000000000000000000000000000001', radix: 16);
      final reducedPrivateKey = privateKeyInt % fieldSize;
      
      print('DEBUG initAccount: reducedPrivateKey = $reducedPrivateKey');
      
      final privateKey = Felt(reducedPrivateKey);
      print('DEBUG initAccount: Created Felt privateKey');

      // Simplified: Generate a public key from private key
      final signer = Signer(privateKey: privateKey);
      final publicKey = signer.publicKey;
      
      print('DEBUG initAccount: publicKey = ${publicKey.toHexString()}');
      
      // Placeholder class hash for OpenZeppelin Account (Sepolia)
      final ozAccountClassHash = Felt.fromHexString('0x05400e90f7e0ae78bd02c77cd75527280470e2fe19c54970dd79dc37a9dce7cf');
      
      final contractAddress = Contract.computeAddress(
        classHash: ozAccountClassHash,
        calldata: [publicKey],
        salt: privateKey, 
      );
      
      print('DEBUG initAccount: contractAddress = ${contractAddress.toHexString()}');

      account = Account(
        provider: provider,
        signer: signer,
        accountAddress: contractAddress,
        chainId: StarknetChainId.testNet,
      );
      
      print('DEBUG initAccount: Account created successfully');
    } catch (e, st) {
      print('DEBUG initAccount: ERROR = $e');
      print('DEBUG initAccount: STACK TRACE = $st');
      rethrow;
    }
  }

  Future<int> getCounterValue(String userAddress) async {
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
      return false;
    }
  }

  Future<String> increaseCounter() async {
    if (account == null) throw Exception('Account not initialized');

    // Check if account is deployed
    final deployed = await isAccountDeployed();
    if (!deployed) {
      throw Exception(
        'Account not deployed. Your Starknet account (${account!.accountAddress.toHexString()}) '
        'needs to be deployed before it can send transactions.\n\n'
        'To deploy: Send some ETH to this address, then the account will be automatically '
        'deployed on first transaction. Or use a paymaster service for gasless deployment.'
      );
    }

    final response = await account!.execute(
      functionCalls: [
        FunctionCall(
          contractAddress: Felt.fromHexString(AppConstants.contractAddress),
          entryPointSelector: getSelectorByName('increase_counter'),
          calldata: [],
        ),
      ],
    );

    return response.when(
      result: (result) => result.transaction_hash,
      error: (error) => throw Exception('Transaction Error: ${error.message}'),
    );
  }
}
