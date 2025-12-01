import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:privy_flutter/privy_flutter.dart';
import 'package:starknet_mobile_counter_dapp/features/auth/services/privy_service.dart';

// Provider for authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<PrivyUser?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<PrivyUser?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    final user = await PrivyService.privy.getUser();
    state = AsyncValue.data(user);
  }

  Future<bool> sendCode(String email) async {
    // Don't update state here - sending code doesn't change auth status
    try {
      final success = await PrivyService().sendCode(email);
      return success;
    } catch (e, st) {
      print('Error in sendCode: $e');
      return false;
    }
  }

  Future<void> loginWithCode(String code, String email) async {
    state = const AsyncValue.loading();
    try {
      final user = await PrivyService().loginWithCode(code, email);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await PrivyService().logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
