import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starknet_mobile_counter_dapp/config/theme.dart';
import 'package:starknet_mobile_counter_dapp/features/auth/providers/auth_provider.dart';
import 'package:starknet_mobile_counter_dapp/features/auth/screens/login_screen.dart';
import 'package:starknet_mobile_counter_dapp/features/auth/services/privy_service.dart';
import 'package:starknet_mobile_counter_dapp/features/counter/screens/counter_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Privy
  await PrivyService.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Starknet Mobile Counter',
      theme: AppTheme.darkTheme,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const CounterScreen();
          } else {
            return const LoginScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          body: Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
