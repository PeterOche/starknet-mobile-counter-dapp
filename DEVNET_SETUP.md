# Local Starknet Devnet Setup

## Problem
The `starknet` Dart package (v0.2.0) has incomplete V3 transaction support (missing `l1_data_gas` field), and all free public RPC endpoints either:
- Require V3 transactions (Alchemy)
- Are deprecated (BlastAPI)
- Have DNS/compatibility issues (Nethermind, Lava)

## Solution: Run Local Devnet

### Step 1: Install Starknet Devnet
```bash
# Using Docker (recommended)
docker pull shardlabs/starknet-devnet-rs:latest

# OR using cargo
cargo install starknet-devnet
```

### Step 2: Run Devnet
```bash
# Using Docker
docker run -p 5050:5050 shardlabs/starknet-devnet-rs:latest

# OR using cargo
starknet-devnet --host 0.0.0.0 --port 5050
```

### Step 3: Update Your App Configuration

1. **Update `lib/config/constants.dart`:**
   ```dart
   static const String rpcUrl = 'http://YOUR_COMPUTER_IP:5050';
   ```
   Replace `YOUR_COMPUTER_IP` with your computer's local IP address (e.g., `192.168.1.100`)

2. **Deploy your contract to devnet** (you'll need to redeploy since it's a fresh network)

3. **Fund your deployer account** using devnet's predeployed accounts

### Step 4: Get Your Computer's IP
```bash
# On macOS/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1

# On Windows
ipconfig
```

### Alternative: Use Infura (Requires Free Signup)
1. Sign up at https://www.infura.io/
2. Create a new Starknet project
3. Get your API key
4. Update RPC URL to: `https://starknet-sepolia.infura.io/v3/YOUR_API_KEY`

Note: Infura may also require V3 transactions, so local devnet is the most reliable option.
