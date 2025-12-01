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
    // Deterministic key derivation
    const salt = 'starknet-mobile-counter-salt';
    final bytes = utf8.encode('$userId$salt');
    final digest = sha256.convert(bytes);
    final privateKeyInt = BigInt.parse(digest.toString(), radix: 16);
    // Felt.fromInt takes int, but we have BigInt, so use Felt constructor directly
    final privateKey = Felt(privateKeyInt);

    // Simplified: Generate a public key from private key
    final signer = Signer(privateKey: privateKey);
    final publicKey = signer.publicKey;
    
    // Placeholder class hash for OpenZeppelin Account (Sepolia)
    final ozAccountClassHash = Felt.fromHexString('0x05400e90f7e0ae78bd02c77cd75527280470e2fe19c54970dd79dc37a9dce7cf');
    
    final contractAddress = Contract.computeAddress(
      classHash: ozAccountClassHash,
      calldata: [publicKey],
      salt: privateKey, 
    );

    account = Account(
      provider: provider,
      signer: signer,
      accountAddress: contractAddress,
      chainId: StarknetChainId.testNet,
    );
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

  Future<String> increaseCounter() async {
    if (account == null) throw Exception('Account not initialized');

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
