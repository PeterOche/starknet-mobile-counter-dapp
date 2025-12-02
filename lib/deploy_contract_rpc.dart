import 'dart:io';
import 'dart:convert';
import 'package:starknet/starknet.dart';
import 'package:starknet_provider/starknet_provider.dart';

void main() async {
  print('Deploying Counter Contract to Local Devnet via RPC...\n');
  
  final provider = JsonRpcProvider(nodeUri: Uri.parse('http://localhost:5050'));
  
  // Devnet predeployed account
  final deployerAddress = Felt.fromHexString('0x01346c1b579a994541dc0bef3e6427c31c8df892115825139dc60c09aa925d04');
  final deployerPrivateKey = Felt.fromHexString('0x00000000000000000000000000000000ef0125d1158ba6e7d5b5bd24082062fc');
  
  final account = getAccount(
    accountAddress: deployerAddress,
    privateKey: deployerPrivateKey,
    nodeUri: Uri.parse('http://localhost:5050'),
  );
  
  print('Using account: ${deployerAddress.toHexString()}\n');
  
  // Read the compiled contract
  final contractClassFile = File('contracts/target/dev/starknet_mobile_counter_Counter.contract_class.json');
  final contractClassJson = jsonDecode(await contractClassFile.readAsString());
  
  final casmFile = File('contracts/target/dev/starknet_mobile_counter_Counter.compiled_contract_class.json');
  final casmJson = jsonDecode(await casmFile.readAsString());
  
  print('Step 1: Declaring contract...');
  
  try {
    final declareResult = await account.declare(
      contractClass: contractClassJson,
      compiledClassHash: BigInt.parse(casmJson['class_hash'].toString().replaceFirst('0x', ''), radix: 16),
      casmCompiledContract: casmJson,
    );
    
    declareResult.when(
      result: (result) async {
        final classHash = result.class_hash;
        print('✅ Contract declared! Class hash: ${classHash.toHexString()}\n');
        
        print('Step 2: Deploying contract...');
        
        // Deploy using UDC (Universal Deployer Contract)
        final deployResult = await account.execute(
          functionCalls: [
            FunctionCall(
              contractAddress: Felt.fromHexString('0x041a78e741e5af2fec34b695679bc6891742439f7afb8484ecd7766661ad02bf'), // UDC address
              entryPointSelector: getSelectorByName('deployContract'),
              calldata: [
                classHash, // class_hash
                Felt.zero, // salt
                Felt.zero, // unique
                Felt.zero, // calldata_len (no constructor params)
              ],
            ),
          ],
        );
        
        deployResult.when(
          result: (txResult) async {
            print('✅ Deploy transaction sent! TX hash: ${txResult.transaction_hash}\n');
            print('Waiting for transaction to be accepted...');
            
            await waitForAcceptance(
              transactionHash: txResult.transaction_hash,
              provider: provider,
            );
            
            // Get the deployed contract address from the transaction receipt
            final receipt = await provider.getTransactionReceipt(txResult.transaction_hash);
            receipt.when(
              result: (r) {
                // Find the contract_deployed event
                for (final event in r.events) {
                  if (event.keys != null && event.keys!.isNotEmpty && 
                      event.keys![0].toHexString().contains('contract_deployed')) {
                    if (event.data != null && event.data!.isNotEmpty) {
                      final contractAddress = event.data![0];
                      print('\n✅ Contract deployed successfully!');
                      print('Contract Address: ${contractAddress.toHexString()}');
                      print('\nUpdate lib/config/constants.dart with:');
                      print('static const String contractAddress = \'${contractAddress.toHexString()}\';');
                      return;
                    }
                  }
                }
                print('Could not find deployed contract address in receipt');
              },
              error: (e) => print('Error getting receipt: ${e.message}'),
            );
          },
          error: (e) => print('Deploy error: ${e.message}'),
        );
      },
      error: (e) => print('Declare error: ${e.message}'),
    );
  } catch (e, st) {
    print('Exception: $e');
    print('Stack trace: $st');
  }
}
