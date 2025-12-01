# Starknet Mobile Counter dApp

A Flutter mobile application demonstrating authentication with Privy and smart contract interaction on Starknet. This template showcases how to build a production-ready mobile dApp with email-based authentication and on-chain state management.

![Starknet Counter](https://img.shields.io/badge/Starknet-Sepolia-purple) ![Flutter](https://img.shields.io/badge/Flutter-3.24+-blue) ![Privy](https://img.shields.io/badge/Privy-Auth-green)

## 📋 Overview

This template provides a complete mobile dApp implementation featuring:

- **🔐 Email OTP Authentication** via Privy Flutter SDK
- **⛓️ Starknet Integration** with on-chain counter contract
- **🎨 Modern UI** with dark theme and smooth animations
- **📱 iOS Support** (iOS 16.0+)
- **🔄 State Management** using Riverpod
- **🚀 Production-Ready** architecture and error handling

## 🏗️ Architecture

### Project Structure

```
starknet-mobile-counter-dapp/
├── lib/
│   ├── config/
│   │   ├── constants.dart       # Contract address, RPC URL, Privy config
│   │   └── theme.dart           # App theme configuration
│   ├── features/
│   │   ├── auth/
│   │   │   ├── providers/       # Authentication state management
│   │   │   ├── screens/         # Login screen with OTP flow
│   │   │   └── services/        # Privy service wrapper
│   │   └── counter/
│   │       ├── providers/       # Counter state management
│   │       ├── screens/         # Counter display and interaction
│   │       ├── services/        # Starknet service for contract calls
│   │       └── widgets/         # Reusable UI components
│   └── main.dart                # App entry point
├── contracts/
│   ├── src/lib.cairo            # Counter smart contract
│   ├── Counter_ABI.json         # Contract ABI
│   └── Scarb.toml               # Cairo project config
└── ios/                         # iOS-specific configuration
```

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                     Flutter App                         │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐         ┌──────────────┐            │
│  │ LoginScreen  │────────▶│ CounterScreen│            │
│  └──────────────┘         └──────────────┘            │
│         │                        │                     │
│         ▼                        ▼                     │
│  ┌──────────────┐         ┌──────────────┐            │
│  │ AuthNotifier │         │CounterNotifier│           │
│  └──────────────┘         └──────────────┘            │
│         │                        │                     │
│         ▼                        ▼                     │
│  ┌──────────────┐         ┌──────────────┐            │
│  │ PrivyService │         │StarknetService│           │
│  └──────────────┘         └──────────────┘            │
└─────────┬────────────────────────┬────────────────────┘
          │                        │
          ▼                        ▼
    ┌──────────┐            ┌──────────────┐
    │  Privy   │            │   Starknet   │
    │   API    │            │   Sepolia    │
    └──────────┘            └──────────────┘
```

### Key Components

- **PrivyService**: Handles email OTP authentication flow
- **StarknetService**: Manages account derivation and contract interactions
- **AuthNotifier**: Manages authentication state with Riverpod
- **CounterNotifier**: Manages counter state and contract calls

## 🚀 Setup & Installation

### Prerequisites

- **Flutter SDK**: 3.24.0 or higher
- **Dart**: 3.0.0 or higher
- **iOS**: Xcode 15+ (for iOS development)
- **Privy Account**: Sign up at [dashboard.privy.io](https://dashboard.privy.io)

### Step 1: Clone and Install Dependencies

```bash
# Clone the repository
git clone <your-repo-url>
cd starknet-mobile-counter-dapp

# Install Flutter dependencies
flutter pub get

# Install iOS dependencies (macOS only)
cd ios && pod install && cd ..
```

### Step 2: Configure Privy

1. **Create a Privy App**:
   - Go to [dashboard.privy.io](https://dashboard.privy.io)
   - Create a new app
   - Copy your **App ID** and **Client ID**

2. **Enable Email Authentication**:
   - Navigate to **User Management** → **Authentication**
   - Toggle **Email** authentication ON

3. **Register iOS Bundle Identifier**:
   - Go to **Configuration** → **App Settings** → **Clients**
   - Add iOS Bundle Identifier: `com.example.starknetMobileCounter`

4. **Update Configuration**:
   - Open `lib/config/constants.dart`
   - Replace `privyAppId` and `privyAppClientId` with your credentials

```dart
static const String privyAppId = 'your-app-id-here';
static const String privyAppClientId = 'your-client-id-here';
```

### Step 3: Run the App

```bash
# Run on iOS simulator
flutter run

# Or specify a device
flutter devices
flutter run -d <device-id>
```

## 🔐 Privy Integration

### How It Works

The app uses **Privy Flutter SDK** for passwordless authentication via email OTP.

#### 1. Initialization

In `main.dart`, Privy is initialized before the app starts:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrivyService.init();
  runApp(const ProviderScope(child: MyApp()));
}
```

#### 2. Email OTP Flow

The `PrivyService` wraps the Privy SDK:

```dart
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
    final result = await privy.email.sendCode(email);
    return result is Success;
  }

  Future<PrivyUser?> loginWithCode(String code, String email) async {
    final result = await privy.email.loginWithCode(code: code, email: email);
    return result is Success ? (result as Success).value : null;
  }
}
```

#### 3. UI Flow

1. User enters email → `sendCode()` is called
2. User receives OTP via email
3. User enters code → `loginWithCode()` is called
4. On success, user is authenticated and navigated to Counter screen

### State Management

Authentication state is managed with Riverpod:

```dart
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<PrivyUser?>>((ref) {
  return AuthNotifier();
});
```

The `MyApp` widget watches this provider and navigates accordingly:

```dart
authState.when(
  data: (user) => user != null ? CounterScreen() : LoginScreen(),
  loading: () => LoadingScreen(),
  error: (e, _) => ErrorScreen(error: e),
)
```

## ⛓️ Starknet Contract Integration

### Smart Contract

The Counter contract is written in Cairo and deployed on Starknet Sepolia:

```cairo
#[starknet::contract]
mod Counter {
    #[storage]
    struct Storage {
        counter: felt252,
    }

    #[abi(embed_v0)]
    impl CounterImpl of super::ICounter<ContractState> {
        fn get_counter(self: @ContractState, user: felt252) -> felt252 {
            self.counter.read()
        }

        fn increase_counter(ref self: ContractState) {
            let current = self.counter.read();
            self.counter.write(current + 1);
        }
    }
}
```

**Contract Address**: `0x02d2a4804f83c34227314dba41d5c2f8a546a500d34e30bb5078fd36b5af2d77`

### StarknetService Implementation

The `StarknetService` handles all blockchain interactions:

#### 1. Account Derivation

Each user gets a deterministic Starknet account derived from their Privy User ID:

```dart
Future<void> initAccount(String userId) async {
  // Derive private key from user ID
  const salt = 'starknet-mobile-counter-salt';
  final bytes = utf8.encode('$userId$salt');
  final digest = sha256.convert(bytes);
  final privateKey = Felt(BigInt.parse(digest.toString(), radix: 16));

  // Create signer
  final signer = Signer(privateKey: privateKey);
  final publicKey = signer.publicKey;

  // Compute account address
  final accountAddress = Contract.computeAddress(
    classHash: ozAccountClassHash,
    calldata: [publicKey],
    salt: privateKey,
  );

  // Initialize account
  account = Account(
    provider: provider,
    signer: signer,
    accountAddress: accountAddress,
    chainId: StarknetChainId.testNet,
  );
}
```

#### 2. Reading Contract State

```dart
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
```

#### 3. Writing to Contract

```dart
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
```

### RPC Provider

The app connects to Starknet Sepolia via public RPC:

```dart
final provider = JsonRpcProvider(
  nodeUri: Uri.parse('https://starknet-sepolia.public.blastapi.io/rpc/v0_7')
);
```

## 🔧 Customization Guide

### Changing Contract Address

1. Open `lib/config/constants.dart`
2. Update the `contractAddress`:

```dart
static const String contractAddress = '0xYOUR_CONTRACT_ADDRESS_HERE';
```

### Adding New Contract Functions

#### 1. Update the ABI

Add your function to `counterAbi` in `constants.dart`:

```dart
{
  "type": "function",
  "name": "your_function_name",
  "inputs": [
    {"name": "param1", "type": "core::felt252"}
  ],
  "outputs": [{"type": "core::felt252"}],
  "state_mutability": "view"  // or "external"
}
```

#### 2. Add Method to StarknetService

For **view functions** (read-only):

```dart
Future<int> yourFunctionName(String param1) async {
  final response = await provider.call(
    request: FunctionCall(
      contractAddress: Felt.fromHexString(AppConstants.contractAddress),
      entryPointSelector: getSelectorByName('your_function_name'),
      calldata: [Felt.fromHexString(param1)],
    ),
    blockId: BlockId.latest,
  );

  return response.when(
    result: (result) => result.first.toInt(),
    error: (error) => throw Exception('Error: ${error.message}'),
  );
}
```

For **external functions** (write):

```dart
Future<String> yourFunctionName(String param1) async {
  if (account == null) throw Exception('Account not initialized');

  final response = await account!.execute(
    functionCalls: [
      FunctionCall(
        contractAddress: Felt.fromHexString(AppConstants.contractAddress),
        entryPointSelector: getSelectorByName('your_function_name'),
        calldata: [Felt.fromHexString(param1)],
      ),
    ],
  );

  return response.when(
    result: (result) => result.transaction_hash,
    error: (error) => throw Exception('Error: ${error.message}'),
  );
}
```

#### 3. Update UI

Add UI elements in `CounterScreen` to call your new function.

### Changing RPC Provider

Update `rpcUrl` in `constants.dart`:

```dart
// Sepolia Testnet
static const String rpcUrl = 'https://starknet-sepolia.public.blastapi.io/rpc/v0_7';

// Mainnet
static const String rpcUrl = 'https://starknet-mainnet.public.blastapi.io/rpc/v0_7';
```

## 📱 Usage

### 1. Login Flow

1. Launch the app
2. Enter your email address
3. Click "Send Code"
4. Check your email for the 6-digit OTP
5. Enter the code and click "Verify & Login"

### 2. Counter Interaction

1. After login, you'll see the Counter screen
2. View your current counter value
3. Click "Increase Counter" to increment (requires Sepolia ETH for gas)
4. Your derived Starknet account address is displayed at the top

### 3. Funding Your Account

To interact with the contract (increment counter), you need Sepolia ETH:

1. Copy your Starknet address from the app
2. Get testnet ETH from a Sepolia faucet:
   - [Starknet Faucet](https://faucet.goerli.starknet.io/)
   - [Alchemy Sepolia Faucet](https://sepoliafaucet.com/)
3. Wait for confirmation
4. Try incrementing the counter

## 🛠️ Development

### Running Tests

```bash
flutter test
```

### Building for Production

```bash
# iOS
flutter build ios --release

# Android (when supported)
flutter build apk --release
```

### Hot Reload

While developing, use hot reload for instant updates:

```bash
# In the terminal where flutter run is active
r  # Hot reload
R  # Hot restart
```

## 📚 Dependencies

### Flutter Packages

- `flutter_riverpod: ^3.0.3` - State management
- `privy_flutter: ^0.4.0` - Authentication
- `starknet: ^0.2.0` - Starknet SDK
- `starknet_provider: ^0.2.0` - RPC provider
- `crypto: ^3.0.3` - Cryptographic functions
- `google_fonts: ^6.1.0` - Typography
- `url_launcher: ^6.2.2` - External links

### Cairo Packages

- `starknet: ^2.9.0` - Starknet Cairo library

## 🐛 Troubleshooting

### "Failed to send code" Error

- Verify your Privy App ID and Client ID are correct
- Ensure Email authentication is enabled in Privy Dashboard
- Check that iOS Bundle Identifier is registered in Privy

### Widget Unmounting Issues

- Ensure you're not updating auth state unnecessarily
- The `sendCode()` method should not trigger auth state changes

### Contract Call Failures

- Verify contract address is correct
- Ensure your account has Sepolia ETH for gas
- Check RPC endpoint is accessible

## 📄 License

MIT License - feel free to use this template for your projects!

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Check [Privy Documentation](https://docs.privy.io)
- Check [Starknet Documentation](https://docs.starknet.io)

---

Built with ❤️ using Flutter, Privy, and Starknet