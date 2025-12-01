import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privy_flutter/privy_flutter.dart';
import 'package:starknet_mobile_counter_dapp/config/theme.dart';
import 'package:starknet_mobile_counter_dapp/features/auth/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isCodeSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Starknet Counter',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Powered by Privy & Starknet.dart',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              if (!_isCodeSent) ...[
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.black12,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send Code'),
                  ),
                ),
              ] else ...[
                Text(
                  'Enter code sent to ${_emailController.text}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Code',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.black12,
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loginWithCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verify & Login'),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _isCodeSent = false),
                  child: const Text('Back to Email'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendCode() async {
    print('DEBUG: _sendCode called');
    if (_emailController.text.isEmpty) {
      print('DEBUG: Email is empty, returning');
      return;
    }
    print('DEBUG: Setting loading to true');
    setState(() => _isLoading = true);
    try {
      print('DEBUG: About to call sendCode');
      final success = await ref.read(authProvider.notifier).sendCode(_emailController.text);
      print('DEBUG: sendCode returned: $success');
      if (mounted) {
        print('DEBUG: Widget is mounted, updating state');
        setState(() {
          _isLoading = false;
          if (success) {
            _isCodeSent = true;
            print('DEBUG: UI updated - _isCodeSent = $_isCodeSent');
          } else {
            print('DEBUG: sendCode returned false');
          }
        });
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send code')),
          );
        }
      } else {
        print('DEBUG: Widget not mounted!');
      }
    } catch (e) {
      print('DEBUG: Exception caught: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
    print('DEBUG: _sendCode completed');
  }

  Future<void> _loginWithCode() async {
    if (_codeController.text.isEmpty) return;
    setState(() => _isLoading = true);
    await ref.read(authProvider.notifier).loginWithCode(_codeController.text, _emailController.text);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
