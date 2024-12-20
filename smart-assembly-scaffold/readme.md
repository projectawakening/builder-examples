# 🏗️ Smart Assembly Scaffold

## Introduction

EVE Frontier Smart Assembly Scaffold is a streamlined framework designed for interfacing with the EVE Frontier game. It focuses on providing information about basic blockchain primitives, such as smart assembly info and ownership details, without delving into further module-specific details. Built with MUD, React, Rainbowkit, TypeScript, Tailwind CSS, and Vite, it ensures efficient and scalable development. It utilizes the `example` MUD namespace for contract management.

### 🚀 User Flow

The Smart Assembly Scaffold provides a minimal example to toggle the state of an item on or off.

---

## 🛠️ Development & Deployment Steps

### Step 1: 🏗️ Local Development with Docker, Anvil, Contracts, and World Explorer

From the project’s root directory, run:

```bash
pnpm run dev
```

This command will:

- **Fork a Docker instance of Anvil**: This creates a local blockchain environment.
- **Run a Local Instance of the World Explorer**: Enables you to visually inspect and debug the game state.
- **Deploy Contracts to the Existing Docker World**: Deploys your contracts to the local environment so you can begin interacting with them immediately.

**Environment Variables**:  
For this step, ensure you have the appropriate `.env` files configured.

- A copy of required environment variables can be found in `./packages/client/.envsample`. Duplicate `.envsample` into `.env` and then adjust the values accordingly.

### Step 2: 🔭 Develop Against the World Explorer

You can use the World Explorer, a GUI tool for visualizing and inspecting and manipulating the state of your deployed world, by visiting:

```
http://localhost:13690/anvil/worlds/<worldAddress>/explore
```

With the World Explorer, you can interactively view tables, query on-chain data, and better understand how your smart contracts and front-end components work together in real time.

### Step 3: 🏗️ Devnet/Production Deployment

When the contracts are ready to be deployed beyond the local environment:

1. Obtain the appropriate World address from the relevant configuration (e.g. Stillness, Nova).
2. To deploy to Garnet:

   ```bash
   pnpm deploy:garnet --worldAddress <worldAddress>
   ```

**Environment Variables**:

- Ensure that your `.env` files in `packages/contracts` and `packages/client` point to the correct deployed instances. For Garnet or other devnets, the `WORLD_ADDRESS` and related RPC endpoints must match the environment you are deploying to.

### Step 4: 🌐 dApp Environment Variables and Considerations

The Smart Assembly Scaffold’s client UI (dApp) leverages a `<SmartObjectContext>` to provide read-only blockchain primitives, such as smart assembly info. These primitives require access to a deployed world instance and a corresponding World API service to function correctly. This typically means working against an environment like Nova or Stillness, where dedicated API HTTP and WebSocket endpoints are available.

By connecting to these endpoints, the dApp can stream real-time updates over WebSockets, enabling dynamic state changes and real-time feedback within your dApp. To fully realize this functionality, you’ll need properly configured environment variables that point to a running instance of the World API service.

### Step 5: 💻 Configuring dApp Environment Variables

1. Copy the `.envsample` file in `./packages/client/` to `.env`:
   ```bash
   cp ./packages/client/.envsample ./packages/client/.env
   ```
2. Update the following environment variables in `./packages/client/.env`:
   - **`VITE_SMARTASSEMBLY_ID`**: The ID obtained from your deployed smart assembly in-game.
   - **`VITE_GATEWAY_HTTP`**: The HTTP endpoint of a deployed World API instance (e.g., Nova or Stillness).
   - **`VITE_GATEWAY_WS`**: The WebSocket endpoint corresponding to `VITE_GATEWAY_HTTP`, enabling real-time data streams.

With these variables set, you can view the dApp at `localhost:3000`. Make sure your wallet is connected to the Garnet chain to fully interact with the deployed contracts.

The dApp uses Stash and the `useRecord` hook to fetch table data from your deployed contracts. Additionally, the World Explorer UI can be accessed to visually inspect states and updates in real time, streamlining your development and debugging workflows.

---

## 🖥️ dApp Overview

The dApp leverages MUD tooling (`@latticexyz`) and Eveworld tooling (`@eveworld`) to integrate with EVE Frontier’s in-game systems. The UI dynamically updates as on-chain data changes, providing an immersive and real-time experience.

With the environment variables set correctly and the right blockchain gateway URLs in place, you’ll be able to toggle states, inspect game entities, and interact directly with the contracts deployed via your chosen environment.
