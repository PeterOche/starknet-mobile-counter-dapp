import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starknet_mobile_counter_dapp/config/theme.dart';
import 'package:starknet_mobile_counter_dapp/features/auth/providers/auth_provider.dart';
import 'package:starknet_mobile_counter_dapp/features/counter/providers/counter_provider.dart';
import 'package:starknet_mobile_counter_dapp/shared/widgets/widgets.dart';

class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAddress = ref.watch(walletProvider);
    final counterState = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: walletAddress.when(
          data: (address) => address != null
              ? WalletBadge(address: address)
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Current Count',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            counterState.when(
              data: (value) => Text(
                '$value',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text(
                'Error: $e',
                style: const TextStyle(color: AppTheme.errorColor),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Note: Decrease is not implemented in the demo contract, so we disable it or omit it.
                // Keeping it disabled for visual balance if desired, or removing it.
                // For this template, we'll show it but disabled with a tooltip.
                Tooltip(
                  message: "Decrease counter",
                  child: ActionButton(
                    icon: Icons.remove,
                    onPressed: () {
                      ref.read(counterProvider.notifier).decrement();
                    },
                  ),
                ),
                const SizedBox(width: 32),
                ActionButton(
                  icon: Icons.add,
                  onPressed: () {
                    ref.read(counterProvider.notifier).increment();
                  },
                  isLoading: counterState.isLoading, // Simple loading state check
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
