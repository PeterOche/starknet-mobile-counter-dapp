This is a comprehensive system design and architecture for the Starknet Mobile Counter dApp. This blueprint allows an AI agent (or developer) to build the application module by module.

1. High-Level Architecture
We will use Clean Architecture combined with Riverpod for state management. This ensures the code is testable, scalable, and easy to fork—exactly what a template needs.

The Three Layers
Presentation Layer (UI):

Screens: LoginScreen, CounterScreen.

Widgets: ActionButtons, WalletBadge, LoadingOverlay.

State: Riverpod Providers (consuming the Logic Layer).

Domain/Logic Layer (State Management):

AuthNotifier: Manages Privy login state (Unauthenticated vs. Authenticated).

WalletNotifier: Manages the Starknet Account object (derived from Auth).

ContractNotifier: Manages the counter state (fetching, optimistically updating).

Data/Infrastructure Layer (Services):

PrivyService: Direct calls to privy_flutter SDK.

StarknetService: Wraps starknet.dart (RPC calls, Account execution).

2. Directory Structure
The agent should create this exact folder structure to ensure the project is "template-ready."

Plaintext

lib/
├── main.dart                 # App Entry (Initializes ProviderScope & Privy)
├── config/
│   ├── assets.dart           # Image paths
│   ├── theme.dart            # Starknet/Privy branding colors
│   └── constants.dart        # RPC URL, Contract Address, ABIs
├── core/
│   ├── errors/               # Custom Failure classes
│   └── utils/                # formatting_utils.dart (e.g., shortenAddress)
├── features/
│   ├── auth/
│   │   ├── services/         # privy_service.dart
│   │   ├── providers/        # auth_provider.dart (Riverpod)
│   │   └── screens/          # login_screen.dart
│   └── counter/
│       ├── services/         # starknet_service.dart
│       ├── providers/        # counter_provider.dart
│       └── screens/          # counter_screen.dart
└── shared/
    └── widgets/              # primary_button.dart, loader.dart
3. Key Integration Strategy (The "Bridge")
The biggest challenge is connecting Privy (Auth) to Starknet (Chain) in Flutter. Since the Privy Flutter SDK may not yet have native Starknet signing exposed like the React SDK, we use a Deterministic Key Derivation strategy for this template.

The Workflow:

Auth: User logs in via Privy (Email/Social).

Identity: Privy returns a unique, stable user_id.

Derivation (The "Glue"): We use the user_id (hashed with a salt) to deterministically generate a Starknet Private Key.

Account: We initialize a starknet.dart Account using this key and a pre-deployed account address (or deploy one on the fly).

Flow Diagram:

Code snippet

sequenceDiagram
    participant User
    participant App_UI
    participant Privy_SDK
    participant Starknet_Service
    participant Blockchain

    User->>App_UI: Clicks "Login"
    App_UI->>Privy_SDK: Login()
    Privy_SDK-->>App_UI: Returns User ID (e.g., "did:privy:123...")
    
    App_UI->>Starknet_Service: Initialize Wallet(User ID)
    Note right of Starknet_Service: Hash(UserID) = PrivateKey
    Starknet_Service->>Starknet_Service: Create Account Object
    
    User->>App_UI: Clicks "Increment (+)"
    App_UI->>Starknet_Service: execute(increment)
    Starknet_Service->>Blockchain: Signed Transaction
    Blockchain-->>Starknet_Service: Tx Hash
    Starknet_Service-->>App_UI: Success
4. Detailed Module Specs for the Agent
Give these specifications to the AI/Developer building the app.

A. Configuration (constants.dart)
Contract Address: (You need to deploy a counter contract on Starknet Sepolia).

RPC URL: Use a free Starknet RPC (e.g., blastapi or infura) or the default public one.

Contract ABI:

Dart

const List<Map<String, dynamic>> counterAbi = [
  {
    "name": "get_current_count",
    "type": "function",
    "inputs": [],
    "outputs": [{"name": "res", "type": "felt"}],
    "stateMutability": "view"
  },
  {
    "name": "increment",
    "type": "function",
    "inputs": [],
    "outputs": [],
    "stateMutability": "external"
  },
  {
    "name": "decrement",
    "type": "function",
    "inputs": [],
    "outputs": [],
    "stateMutability": "external"
  }
];
B. Auth Feature (auth_provider.dart)
State: AsyncValue<PrivyUser?>

Methods:

login(): Calls privy.login().

logout(): Calls privy.logout() and clears Starknet state.

Logic: Upon successful login, read the user.id and pass it to the WalletProvider.

C. Starknet Service (starknet_service.dart)
This is the core logic. It requires starknet and starknet_provider packages.

initAccount(String userId):

Generate a private key: sha256(userId + app_secret).

Create Account object from starknet.dart using the key.

getCounterValue():

Use provider.callContract(...).

Selector: get_selector_from_name('get_current_count').

increment() / decrement():

Use account.execute(...).

Calls: [Call(contractAddress: ..., selector: ..., calldata: [])].

Return: The Transaction Hash.

D. The UI (Counter Screen)
Layout:

Top Bar: Shows "Connected: 0x123...456" (Wallet Badge) & Logout Icon.

Center: Big Text displaying the Counter Value.

Bottom: Row of two buttons ( - and + ).

UX Rules:

While fetching: Show a spinner.

After clicking +: Show "Transaction Pending..." toast/snackbar.

After Tx confirmation: Refresh the counter value.

5. Implementation Steps for the Agent
Scaffold: Run flutter create starknet_privy_counter.

Dependencies: Add privy_flutter, starknet, flutter_riverpod, crypto (for key derivation).

Privy Setup: Initialize Privy in main.dart with the App ID.

Authentication: Build LoginScreen that triggers Privy.

Blockchain Connection: Implement StarknetService to handle the call and execute methods.

State Wiring: Use Riverpod to make the Counter UI listen to StarknetService.

Refine: Add error handling (e.g., if the user has no funds for gas) and polish the UI.