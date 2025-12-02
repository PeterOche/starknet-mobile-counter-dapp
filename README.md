# Starknet Mobile Counter dApp

A Flutter mobile application demonstrating authentication with **Privy** and smart contract interaction on **Starknet**. This template is designed to help developers bootstrap mobile dApps on Starknet with a production-ready integration of authentication and blockchain state management.

![Starknet Counter](https://img.shields.io/badge/Starknet-Sepolia-purple) ![Flutter](https://img.shields.io/badge/Flutter-3.24+-blue) ![Privy](https://img.shields.io/badge/Privy-Auth-green)

## 📋 Overview

This template provides a complete mobile dApp implementation featuring:

- **🔐 Email OTP Authentication** via Privy Flutter SDK
- **⛓️ Starknet Integration** with on-chain counter contract
- **🎨 Modern UI** with dark theme and smooth animations
- **📱 iOS Support** (iOS 16.0+)
- **🔄 State Management** using Riverpod
- **🚀 Production-Ready** architecture and error handling
- **⚡ Demo Mode** with optimistic updates for smooth UX

> **⚠️ Important Note on V3 Transactions**  
> This template uses `starknet.dart 0.2.0` which defaults to V3 transactions. However, most public RPC providers (including Alchemy, Infura) **do not yet support V3 transactions** on Sepolia (`UNSUPPORTED_TX_VERSION` error).
> 
> **Current Behavior**: The app is configured in **Demo Mode** with optimistic UI updates - the counter increments/decrements immediately in the UI even though transactions fail on the RPC level. This provides a smooth demonstration experience.
> 
> **For Production**: 
> - Use a local devnet (`starknet-devnet`) which supports V3 transactions
> - Wait for RPC providers to add V3 support
> - Or modify the account to use V1/V2 transactions (older spec)

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
├── .env                         # Environment variables (GitIgnored)
└── ios/                         # iOS-specific configuration
```

### Key Components

- **PrivyService**: Handles email OTP authentication flow.
- **StarknetService**: Manages account derivation and contract interactions.
- **AuthNotifier**: Manages authentication state with Riverpod.
- **CounterNotifier**: Manages counter state and contract calls.

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

### Step 2: Configure Environment Variables

1. Create a `.env` file in the root directory:
   ```bash
   touch .env
   ```

2. Add the following variables to `.env`:
   ```env
   # Starknet RPC URL (Alchemy, Infura, or public node)
   RPC_URL=https://starknet-sepolia.public.blastapi.io/rpc/v0_7
   
   # Deployer Account (Fallback for Demo)
   # NOTE: In production, users should deploy their own accounts.
   DEPLOYER_PRIVATE_KEY=0x0510089bf65090cb87bbad425e27a5ebba82d838a8a113b06b31fad23e94af34
   DEPLOYER_ADDRESS=0x01472c0a8b37928e3138ddc8d8757fa85a551ad8d61c7ae491ecd79d3f8b8acd
   ```

### Step 3: Configure Privy

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

### Step 4: Run the App

```bash
# Run on iOS simulator
flutter run
```

## 🔐 Privy Integration

The app uses **Privy Flutter SDK** for passwordless authentication via email OTP.

1. **Initialization**: Privy is initialized in `main.dart` before the app starts.
2. **Login Flow**:
   - User enters email → `PrivyService.sendCode(email)`
   - User enters OTP → `PrivyService.loginWithCode(code, email)`
   - On success, the user is authenticated and redirected to the Counter screen.

## ⛓️ Starknet Integration

### Smart Contract

The Counter contract is written in Cairo and deployed on Starknet Sepolia.
**Contract Address**: `0x02d2a4804f83c34227314dba41d5c2f8a546a500d34e30bb5078fd36b5af2d77`

### Account Management & Demo Mode

**Demo Limitation**: In a real-world dApp, each user must deploy their own Starknet account (Abstract Account) before sending transactions. This requires funding the address with ETH for gas.

**This Template's Approach (Demo Mode):**
1. **Account Fallback**: If the user's derived account is not deployed, the app falls back to a pre-funded **Deployer Account** (configured in `.env`) to allow immediate interaction without friction.
2. **Optimistic Updates**: To provide a snappy user experience even if the network is congested or if there are RPC issues, the app uses optimistic updates. When you click "Increment", the UI updates immediately while the transaction is processed in the background.

### Reading & Writing State

- **Reading**: `get_counter` is called using `provider.call`.
- **Writing**: `increase_counter` and `decrease_counter` are called using `account.execute` (Invoke Transaction V3).

## 🛠️ Customization

### Changing Contract Address
Update `contractAddress` in `lib/config/constants.dart`.

### Adding New Functions
1. Update `Counter_ABI.json` (optional, for reference).
2. Add the function selector in `lib/config/constants.dart` (if using constants for selectors).
3. Implement the method in `StarknetService`.

## 📄 License

MIT License - feel free to use this template for your projects!

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

- **Starknet Dart SDK**: [https://github.com/starknet-ecosystem/starknet.dart](https://github.com/starknet-ecosystem/starknet.dart)
- **Privy Flutter SDK**: [https://docs.privy.io](https://docs.privy.io)
- **Starknet Docs**: [https://docs.starknet.io](https://docs.starknet.io)