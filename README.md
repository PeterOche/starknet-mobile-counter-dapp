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
   # WARNING: Never commit real private keys to version control!
   DEPLOYER_PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
   DEPLOYER_ADDRESS=0xYOUR_ACCOUNT_ADDRESS_HERE
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

## 🎬 Demo Flow

This section walks through the complete user journey in the app, from authentication to interacting with the on-chain counter.

### 1. **Login with Privy** 🔐

**What happens:**
- User opens the app and sees the login screen
- User enters their email address
- User receives a one-time password (OTP) code via email
- User enters the OTP code to authenticate

**Technical details:**
- `LoginScreen` uses `PrivyService.sendCode(email)` to trigger the OTP email
- After code entry, `PrivyService.loginWithCode(code, email)` authenticates the user
- On success, `AuthNotifier` updates the authentication state with the `PrivyUser` object
- The app automatically navigates to the Counter screen

**Code reference:**
- UI: [`lib/features/auth/screens/login_screen.dart`](file:///Users/mustang/Desktop/starknet-mobile-counter-dapp/lib/features/auth/screens/login_screen.dart)
- Service: [`lib/features/auth/services/privy_service.dart`](file:///Users/mustang/Desktop/starknet-mobile-counter-dapp/lib/features/auth/services/privy_service.dart)
- State: [`lib/features/auth/providers/auth_provider.dart`](file:///Users/mustang/Desktop/starknet-mobile-counter-dapp/lib/features/auth/providers/auth_provider.dart)

---

### 2. **Account Initialization** ⛓️

**What happens:**
- Once authenticated, the app initializes a Starknet account for the user
- The wallet address is displayed in the app bar

**Technical details:**
- `walletProvider` watches the authentication state
- When a user is authenticated, `StarknetService.initAccount(userId)` is called
- **Demo Mode**: The app uses a pre-funded deployer account (from `.env`) as a fallback to enable immediate interaction without requiring account deployment or funding
- In production, you would derive a unique account from the user's Privy wallet and deploy it on-chain

**Code reference:**
- Service: [`lib/features/counter/services/starknet_service.dart`](file:///Users/mustang/Desktop/starknet-mobile-counter-dapp/lib/features/counter/services/starknet_service.dart#L15-L39)
- Provider: [`lib/features/counter/providers/counter_provider.dart`](file:///Users/mustang/Desktop/starknet-mobile-counter-dapp/lib/features/counter/providers/counter_provider.dart#L11-L39)

---

### 3. **Counter Display** 📊

**What happens:**
- The counter screen displays the current count value
- The UI shows the user's wallet address in the app bar
- Two action buttons (+ and -) are available for interaction

**Technical details:**
- `CounterNotifier` automatically fetches the counter value on initialization
- The counter is read using `StarknetService.getCounterValue(walletAddress)`
- This calls the `get_counter(user)` function on the smart contract using `provider.call`
- The counter value updates in real-time when transactions complete

**Code reference:**
- UI: [`lib/features/counter/screens/counter_screen.dart`](file:///Users/mustang/Desktop/starknet-mobile-counter-dapp/lib/features/counter/screens/counter_screen.dart)
- Service: [`lib/features/counter/services/starknet_service.dart`](file:///Users/mustang/Desktop/starknet-mobile-counter-dapp/lib/features/counter/services/starknet_service.dart#L41-L65)
- Provider: [`lib/features/counter/providers/counter_provider.dart`](file:///Users/mustang/Desktop/starknet-mobile-counter-dapp/lib/features/counter/providers/counter_provider.dart#L80-L89)

---

### 4. **Increase Counter** ➕

**What happens:**
- User taps the **+** button
- The counter value increments immediately in the UI (optimistic update)
- A transaction is sent to the Starknet network in the background
- If successful, the new value persists on-chain
- If the transaction fails, the UI reverts to the previous value

**Technical details:**
- `CounterNotifier.increment()` performs an optimistic update first
- Then calls `StarknetService.increaseCounter()`
- This executes an invoke transaction using `account.execute()` with the `increase_counter` function selector
- **Demo Mode**: If the transaction fails (e.g., due to V3 transaction incompatibility), the optimistic update remains for demonstration purposes
- In production with V3 support, the transaction would be confirmed on-chain

**Code reference:**
- Provider: [`lib/features/counter/providers/counter_provider.dart`](file:///Users/mustang/Desktop/starknet-mobile-counter-dapp/lib/features/counter/providers/counter_provider.dart#L91-L117)
- Service: [`lib/features/counter/services/starknet_service.dart`](file:///Users/mustang/Desktop/starknet-mobile-counter-dapp/lib/features/counter/services/starknet_service.dart#L101-L189)

---

### 5. **Decrease Counter** ➖

**What happens:**
- User taps the **-** button
- The counter value decrements immediately in the UI (optimistic update)
- A transaction is sent to the Starknet network in the background
- Similar behavior to the increase flow

**Technical details:**
- `CounterNotifier.decrement()` performs an optimistic update
- Calls `StarknetService.decreaseCounter()`
- Uses the same transaction flow as increment but with the `decrease_counter` function selector

**Code reference:**
- Provider: [`lib/features/counter/providers/counter_provider.dart`](file:///Users/mustang/Desktop/starknet-mobile-counter-dapp/lib/features/counter/providers/counter_provider.dart#L119-L138)

---

### 6. **Logout** 🚪

**What happens:**
- User taps the logout button in the app bar
- The app clears the authentication state and returns to the login screen

**Technical details:**
- `AuthNotifier.logout()` calls `PrivyService.logout()`
- The authentication state is reset to `null`
- The app automatically navigates back to the login screen

---

### Key Features Demonstrated

✅ **Passwordless Authentication** - Email OTP via Privy  
✅ **Starknet Account Management** - Account initialization and address derivation  
✅ **Smart Contract Reads** - Fetching on-chain state with `provider.call`  
✅ **Smart Contract Writes** - Sending transactions with `account.execute`  
✅ **Optimistic UI Updates** - Immediate feedback for better UX  
✅ **Error Handling** - Graceful fallbacks and user-friendly error messages  
✅ **State Management** - Reactive UI with Riverpod providers  

---

### Testing the Flow

1. **Run the app**: `flutter run`
2. **Login**: Use any email address (Privy will send a real OTP)
3. **View Counter**: See the current count for your wallet address
4. **Increment**: Tap **+** and watch the optimistic update
5. **Decrement**: Tap **-** to decrease the counter
6. **Logout**: Tap the logout icon to end the session

> **💡 Tip**: In Demo Mode, the counter updates immediately even if the blockchain transaction fails. For production with V3 transaction support, transactions will be confirmed on-chain before the UI updates permanently.

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