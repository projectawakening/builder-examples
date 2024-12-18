# 🏗️ Extraction Protocol Depot

## Introduction
This guide provides the steps for building, deploying, and testing contracts for the Extraction Protocol Depot. This Smart Storage Unit (SSU) is designed to support in-game item exchanges for ERC20 tokens, utilizing the `itemtrade` MUD namespace for contract management.

### 🚀 User Flow
The Extraction Protocol Depot allows players to exchange ERC20 tokens for items and vice versa. It includes two types of inventory for seamless in-game transactions:

- **Inventory**: Main storage controlled by the SSU owner.
- **Ephemeral Inventory**: Temporary player-specific storage for item interactions. Players can deposit and withdraw items here, moving them to their ship’s hangar after each transaction.

## 🛠️ Deployment and Testing

### Step 0: 🚢 Deploy Contracts to the Existing World
Copy the World Contract Address from the Docker logs, then use the following commands to set up the contracts:

1. Navigate to the `itemtrade` contract folder:
   ```bash
   cd item-trade/packages/contracts
   ```

2. Install dependencies:
   ```bash
   pnpm install
   ```

3. **Local Deployment**:
   ```bash
   pnpm deploy:local --worldAddress <worldAddress>
   ```

4. **Devnet/Production Deployment**:
   Get the world address from the appropriate config link (e.g., Nova or Nebula) and replace `<worldAddress>`.

   ```bash
   pnpm deploy:garnet --worldAddress <worldAddress>
   ```

After deployment, copy the ERC20 token address for future reference. You should see an output similar to the screenshot below:

![alt text](./readme-imgs/deployment.png)

---

### Step 1: 🔑 Set Up Environment Variables
Edit the `.env` file in `./packages/contracts` to configure deployment values:

```bash
# For Local
WORLD_ADDRESS=<WORLD_ADDRESS_FROM_LOGS>
ERC20_TOKEN_ADDRESS=<ERC20_TOKEN_ADDRESS_FROM_DEPLOYMENT>

# Smart Storage Unit (SSU) ID
SSU_ID=34818344039668088032259299209624217066809194721387714788472158182502870248994
```

### Step 2: 🔍 Mock Data for Local Testing (Local Development Only)
Use this command to generate mock data, including items and ERC20 tokens:

```bash
pnpm mock-data
```

### Step 3: ⚙️ Configure Item Trade
Specify which items to trade for the ERC20 token:

```bash
pnpm configure-item-trade
```

### Step 4: 🛒 Test Item Purchases (Optional)
To test item purchases, ensure the player has sufficient tokens, then run:

```bash
pnpm approve
pnpm purchase-item
```

### Step 5: 💱 Test Item Sales (Optional)
To test selling items, make sure the player has items to trade:

```bash
pnpm sell-item
```

---

## 🖥️ Client UI

The client UI for the Extraction Protocol Depot is built using MUD tooling (`@latticexyz`) with built-in devtools for debugging and Eveworld tooling (`@eveworld`) for managing contexts, smart assembly state, and UI components, creating a seamless integration with EVE Frontier's in-game systems.

### Step 6: 🌐 Launch the Client UI
To start the client, navigate to the `client` directory and run the following command:

```bash
cd ../client
pnpm run dev
```

This launches a local development server at `http://localhost:3000`, connected to the world address you set in Step 1. Using MUD devtools, you can inspect interactions and debug in real time, while the Eveworld context layers components manage in-game state and display contextual data, providing a consistent experience aligned with EVE Frontier’s UI standards.

### Step 7: 📝 Configure Client Environment Variables
Update the following values in the `.env` file located in `./packages/client/` to ensure synchronization with the contract settings:

```bash
VITE_PURCHASE_ITEM_ID=<ITEM_OUT_ID>
VITE_SELL_ITEM_ID=<ITEM_IN_ID>
VITE_SMARTASSEMBLY_ID=<SSU_ID>
VITE_ERC20_TOKEN_ADDRESS=<ERC20_TOKEN_ADDRESS>
```

These values should match those configured in `./packages/contracts/.env` to ensure the client accurately interfaces with the on-chain environment.

- **`VITE_PURCHASE_ITEM_ID`**: The ID of the item being bought by the player from the SSU.
- **`VITE_SELL_ITEM_ID`**: The ID of the item the player is selling to, and accepted by the SSU.
- **`VITE_SMARTASSEMBLY_ID`**: The SSU ID, aligning with your deployment.
- **`VITE_ERC20_TOKEN_ADDRESS`**: The ERC20 token contract address for transactions.

### Step 8: 🧪 Running and Testing the Client
Once the client is running, you can interact with the Extraction Protocol Depot through the browser interface. This UI supports live simulations of item purchases, token transactions, and in-game interactions within an immersive EVE Frontier UI framework.