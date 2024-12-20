# 🏗️ Smart Assembly Scaffold

## Introduction
EVE Frontier Smart Assembly Scaffold is a streamlined framework designed for interfacing with the EVE Frontier game. It focuses on providing information about basic blockchain primitives, such as smart assembly info and ownership details, without delving into further module-specific information. Built with MUD, React, Rainbowkit, TypeScript, Tailwind CSS, and Vite, it ensures efficient and scalable development. It utilizes the `example` MUD namespace for contract management.

### 🚀 User Flow
The Smart Assembly Scaffold provides a minimal example to toggle the state of an item on or off.

## 🛠️ Deployment and Testing

### Step 0: 🚢 Deploy Contracts to the Existing World
Copy the World Contract Address from the Docker logs, then use the following commands to set up the contracts:

1. Navigate to the `smart-assembly-scaffold` contract folder:
   ```bash
   cd smart-assembly-scaffold/packages/contracts
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
pnpm configure-toggle
```

---

## 🖥️ Client UI

The client UI for the Extraction Protocol Depot is built using MUD tooling (`@latticexyz`) with built-in devtools for debugging and Eveworld tooling (`@eveworld`) for managing contexts, smart assembly state, and UI components, creating a seamless integration with EVE Frontier's in-game systems.

### Step 4: 🌐 Launch the Client UI
To start the client, navigate to the `client` directory and run the following command:

```bash
cd ../client
pnpm run dev
```

This launches a local development server at `http://localhost:3000`, connected to the world address you set in Step 1. Using MUD devtools, you can inspect interactions and debug in real time, while the Eveworld context layers components manage in-game state and display contextual data, providing a consistent experience aligned with EVE Frontier’s UI standards.

### Step 5: 📝 Configure Client Environment Variables
Update the following values in the `.env` file located in `./packages/client/` to ensure synchronization with the contract settings:

```bash
VITE_SMARTASSEMBLY_ID=<SSU_ID>
```

These values should match those configured in `./packages/contracts/.env` to ensure the client accurately interfaces with the on-chain environment.

- **`VITE_SMARTASSEMBLY_ID`**: The SSU ID, aligning with your deployment.

### Step 6: 🧪 Running and Testing the Client
Once the client is running, you can interact with the Extraction Protocol Depot through the browser interface. This UI supports live simulations of item purchases, token transactions, and in-game interactions within an immersive EVE Frontier UI framework.