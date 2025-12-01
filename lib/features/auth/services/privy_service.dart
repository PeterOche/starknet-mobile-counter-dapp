import 'package:privy_flutter/privy_flutter.dart';
import 'package:privy_flutter/src/models/privy_config/privy_config.model.dart';
import 'package:starknet_mobile_counter_dapp/config/constants.dart';

class PrivyService {
  static late Privy privy;

  static Future<Privy> init() async {
    privy = Privy.init(
      config: PrivyConfig(
        appId: AppConstants.privyAppId,
        appClientId: AppConstants.privyAppClientId,
      ),
    );
    return privy;
  }

  Future<bool> sendCode(String email) async {
    print('Attempting to send code to: $email');
    final result = await privy.email.sendCode(email);
    print('Privy sendCode result type: ${result.runtimeType}');
    
    if (result is Success) {
      print('Success sending code');
      return true;
    } else if (result is Failure) {
      final error = (result as Failure).error;
      print('Failed to send code: ${error.message}');
      print('Error details: $error');
      return false;
    }
    return false;
  }

  Future<PrivyUser?> loginWithCode(String code, String email) async {
    final result = await privy.email.loginWithCode(code: code, email: email);
    return switch (result) {
      Success(:final value) => value,
      Failure() => null,
    };
  }

  Future<void> logout() async {
    await privy.logout();
  }

  Future<PrivyUser?> getUser() async {
    return privy.getUser();
  }
}
