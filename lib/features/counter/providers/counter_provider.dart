import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:starknet_mobile_counter_dapp/features/auth/providers/auth_provider.dart';
import 'package:starknet_mobile_counter_dapp/features/counter/services/starknet_service.dart';

final starknetServiceProvider = Provider<StarknetService>((ref) {
  return StarknetService();
});

final walletProvider = FutureProvider<String?>((ref) async {
  final authState = ref.watch(authProvider);
  final starknetService = ref.watch(starknetServiceProvider);

  print('DEBUG walletProvider: authState type = ${authState.runtimeType}');
  
  return authState.when(
    data: (user) async {
      print('DEBUG walletProvider: user = $user');
      if (user == null) {
        print('DEBUG walletProvider: user is null, returning null');
        return null;
      }
      print('DEBUG walletProvider: initializing account for user ${user.id}');
      await starknetService.initAccount(user.id);
      final address = starknetService.account?.accountAddress.toHexString();
      print('DEBUG walletProvider: wallet address = $address');
      return address;
    },
    loading: () {
      print('DEBUG walletProvider: authState is loading');
      return null;
    },
    error: (e, st) {
      print('DEBUG walletProvider: authState error = $e');
      return null;
    },
  );
});

final counterProvider = StateNotifierProvider<CounterNotifier, AsyncValue<int>>((ref) {
  final starknetService = ref.watch(starknetServiceProvider);
  final walletAsync = ref.watch(walletProvider);
  
  print('DEBUG counterProvider: walletAsync = ${walletAsync.runtimeType}');
  
  // Wait for wallet to be ready
  final walletAddress = walletAsync.when(
    data: (address) {
      print('DEBUG counterProvider: wallet data = $address');
      return address;
    },
    loading: () {
      print('DEBUG counterProvider: wallet loading');
      return null;
    },
    error: (e, st) {
      print('DEBUG counterProvider: wallet error = $e');
      return null;
    },
  );
  
  return CounterNotifier(starknetService, walletAddress);
});

class CounterNotifier extends StateNotifier<AsyncValue<int>> {
  final StarknetService _starknetService;
  final String? _walletAddress;

  CounterNotifier(this._starknetService, this._walletAddress) : super(const AsyncValue.loading()) {
    print('DEBUG CounterNotifier: wallet address = $_walletAddress');
    if (_walletAddress != null) {
      print('DEBUG CounterNotifier: calling refresh()');
      refresh();
    } else {
      print('DEBUG CounterNotifier: wallet address is null, not refreshing');
    }
  }

  Future<void> refresh() async {
    if (_walletAddress == null) return;
    state = const AsyncValue.loading();
    try {
      final value = await _starknetService.getCounterValue(_walletAddress!);
      state = AsyncValue.data(value);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> increment() async {
    if (_walletAddress == null) return;
    
    // Store current value to revert if needed
    final previousValue = state.value;
    
    // Optimistic update: Increment immediately
    if (previousValue != null) {
      state = AsyncValue.data(previousValue + 1);
    } else {
      state = const AsyncValue.loading();
    }

    try {
      await _starknetService.increaseCounter();
      // In a real app, we would wait for the tx to be accepted.
      // In demo mode, we just keep the optimistic value.
      // If we refresh immediately, we might get the old value from the chain if the tx isn't mined yet.
      // So we skip refresh() for now or delay it significantly.
    } catch (e, st) {
      // Revert on error
      if (previousValue != null) {
        state = AsyncValue.data(previousValue);
      }
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> decrement() async {
    if (_walletAddress == null) return;

    final previousValue = state.value;
    
    if (previousValue != null) {
      state = AsyncValue.data(previousValue - 1);
    } else {
      state = const AsyncValue.loading();
    }

    try {
      await _starknetService.decreaseCounter();
    } catch (e, st) {
      if (previousValue != null) {
        state = AsyncValue.data(previousValue);
      }
      state = AsyncValue.error(e, st);
    }
  }
}
